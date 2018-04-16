require 'spec_helper_acceptance'
require 'zone_util'

RSpec.context 'Zone:IP ip-type and ip configuration' do
  after(:all) do
    solaris_agents.each do |agent|
      ZoneUtils.clean(agent)
    end
  end

  solaris_agents.each do |agent|
    context "on #{agent}" do
      it 'manages IP related properties' do
        # See
        # https://hg.openindiana.org/upstream/illumos/illumos-gate/file/03d5725cda56/usr/src/lib/libinetutil/common/ifspec.c
        # for the funciton ifparse_ifspec. This is the only documentation that exists
        # as to what the zone interface can be.
        #-----------------------------------
        step 'Zone: ip - make it configured'
        apply_manifest_on(agent, <<-MANIFEST) do |result|
          zone { 'tstzone':
            ensure => configured,
            iptype => shared,
            path   => "/tstzones/mnt"
          }
          MANIFEST
          assert_match(%r{ensure: created}, result.stdout, "err: #{agent}")
        end

        step 'Zone: ip - ip switch: verify that the change from shared to exclusive works.'
        apply_manifest_on(agent, <<-MANIFEST) do |result|
          zone { 'tstzone':
            ensure => configured,
            iptype => exclusive,
            path => "/tstzones/mnt"
          }
          MANIFEST
          assert_match(%r{iptype changed 'shared'.* to 'exclusive'}, result.stdout, "err: #{agent}")
        end

        step 'Zone: ip - ip switch: verify that we can change it back'
        apply_manifest_on(agent, <<-MANIFEST) do |result|
          zone { 'tstzone':
            ensure => configured,
            iptype => shared,
            path   => "/tstzones/mnt"
          }
          MANIFEST
          assert_match(%r{iptype changed 'exclusive'.* to 'shared'}, result.stdout, "err: #{agent}")
        end

        step 'Zone: ip - assign: ensure that our ip assignment works.'
        apply_manifest_on(agent, <<-MANIFEST) do |result|
          zone { 'tstzone':
            ensure => configured,
            iptype => shared,
            path   => "/tstzones/mnt",
            ip     => "ip.if.1:1.1.1.1"
          }
          MANIFEST
          assert_match(%r{defined 'ip' as .'ip.if.1:1.1.1.1'.}, result.stdout, "err: #{agent}")
        end

        step 'Zone: ip - assign: arrays should be created'
        apply_manifest_on(agent, <<-MANIFEST) do |result|
          zone { 'tstzone':
            ensure => configured,
            iptype => shared,
            path   => "/tstzones/mnt",
            ip=>["ip.if.1:1.1.1.1", "ip.if.2:1.1.1.2"]
          }
          MANIFEST
          assert_match(%r{ip changed ip.if.1:1.1.1.1 to \['ip.if.1:1.1.1.1', 'ip.if.2:1.1.1.2'\]}, result.stdout, "err: #{agent}")
        end

        step 'Zone: ip - assign: arrays should be modified'
        apply_manifest_on(agent, <<-MANIFEST) do |result|
          zone { 'tstzone':
            ensure => configured,
            iptype => shared,
            path   => "/tstzones/mnt",
            ip => ["ip.if.1:1.1.1.1", "ip.if.2:1.1.1.3"]
          }
          MANIFEST
          assert_match(%r{ip changed ip.if.1:1.1.1.1,ip.if.2:1.1.1.2 to \['ip.if.1:1.1.1.1', 'ip.if.2:1.1.1.3'\]}, result.stdout, "err: #{agent}")
        end

        step 'Zone: ip - idempotency: arrays'
        apply_manifest_on(agent, <<-MANIFEST) do |result|
          zone { 'tstzone':
            ensure => configured,
            iptype => shared,
            path   => "/tstzones/mnt",
            ip => ["ip.if.1:1.1.1.1", "ip.if.2:1.1.1.3"]
          }
          MANIFEST
          assert_no_match(%r{ip changed}, result.stdout, "err: #{agent}")
        end
      end
    end
  end
end
