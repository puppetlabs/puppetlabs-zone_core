require 'spec_helper_acceptance'
require 'zone_util'

RSpec.context 'zone manages path' do
  after(:all) do
    solaris_agents.each do |agent|
      ZoneUtils.clean(agent)
    end
  end

  # inherit /sbin on solaris10 until PUP-3722
  def config_inherit_string(agent)
    if agent['platform'] =~ %r{solaris-10}
      "inherit => '/sbin'"
    else
      ''
    end
  end

  solaris_agents.each do |agent|
    context "on #{agent}" do
      it 'starts and stops a zone' do
        step 'Zone: statemachine - create zone and make it running'
        step 'progress would be logged to agent:/var/log/zones/zoneadm.<date>.<zonename>.install'
        step 'install log would be at agent:/system/volatile/install.<id>/install_log'
        apply_manifest_on(agent, <<-MANIFEST) do |result|
          zone { 'tstzone':
            ensure => running,
            iptype => shared,
            path => '/tstzones/mnt',
            #{config_inherit_string(agent)}
          }
          MANIFEST
          assert_match(%r{ensure: created}, result.stdout, "err: #{agent}")
        end

        step 'Zone: statemachine - ensure zone is correct'
        on(agent, 'zoneadm -z tstzone verify') do |result|
          assert_no_match(%r{could not verify}, result.stdout, "err: #{agent}")
        end

        step 'Zone: statemachine - ensure zone is running'
        on(agent, 'zoneadm -z tstzone list -v') do |result|
          assert_match(%r{running}, result.stdout, "err: #{agent}")
        end

        step 'Zone: statemachine - stop and uninstall zone'
        apply_manifest_on(agent, <<-MANIFEST) do |result|
          zone { 'tstzone':
            ensure => configured,
            iptype => shared,
            path => '/tstzones/mnt'
          }
          MANIFEST
          assert_match(%r{ensure changed 'running' to 'configured'}, result.stdout, "err: #{agent}")
        end

        on(agent, 'zoneadm -z tstzone list -v') do |result|
          assert_match(%r{configured}, result.stdout, "err: #{agent}")
        end
      end
    end
  end
end
