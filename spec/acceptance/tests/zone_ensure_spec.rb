require 'spec_helper_acceptance'
require 'zone_util'

RSpec.context 'Zone: should be created and removed' do
  after(:all) do
    solaris_agents.each do |agent|
      ZoneUtils.clean(agent)
    end
  end

  let(:running_manifest) do
    <<-MANIFEST
      zone { 'tstzone' :
        ensure => running,
        path   =>'/tstzones/mnt'
      }
    MANIFEST
  end

  let(:absent_manifest) do
    <<-MANIFEST
      zone { 'tstzone':
        ensure => absent
      }
    MANIFEST
  end

  solaris_agents.each do |agent|
    context "on #{agent}" do
      it 'creates and deletes a zone' do
        step 'Zone: make it running'
        step 'progress would be logged to agent:/var/log/zones/zoneadm.<date>.<zonename>.install'
        step 'install log would be at agent:/system/volatile/install.<id>/install_log'
        apply_manifest_on(agent, running_manifest) do |result|
          assert_match(%r{created}, result.stdout, "err: #{agent}")
        end

        on(agent, 'zoneadm list -cp') do |result|
          assert_match(%r{tstzone}, result.stdout, "err: #{agent}")
        end

        on(agent, 'zoneadm -z tstzone verify')

        # should be idempotent
        apply_manifest_on(agent, running_manifest) do |result|
          assert_no_match(%r{created|changed|removed}, result.stdout, "err: #{agent}")
        end

        step 'Zone: ensure can remove'
        step 'progress would be logged to agent:/var/log/zones/zoneadm.<date>.<zonename>.uninstall'
        apply_manifest_on(agent, absent_manifest) do |result|
          assert_match(%r{ensure: removed}, result.stdout, "err: #{agent}")
        end
        on(agent, 'zoneadm list -cp') do |result|
          assert_no_match(%r{tstzone}, result.stdout, "err: #{agent}")
        end
      end
    end
  end
end
