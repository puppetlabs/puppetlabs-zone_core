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
      it 'transitions between configured, installed and configured' do
        step 'Zone: steps - create'
        apply_manifest_on(agent, "zone {tstzone : ensure=>configured, iptype=>shared, path=>'/tstzones/mnt', #{config_inherit_string(agent)} }") do |result|
          assert_match(%r{ensure: created}, result.stdout, "err: #{agent}")
        end

        step 'Zone: steps - verify (create)'
        on(agent, 'zoneadm -z tstzone verify') do |result|
          assert_no_match(%r{could not verify}, result.stdout, "err: #{agent}")
        end

        step 'Zone: steps - configured -> installed'
        step 'progress would be logged to agent:/var/log/zones/zoneadm.<date>.<zonename>.install'
        step 'install log would be at agent:/system/volatile/install.<id>/install_log'
        apply_manifest_on(agent, "zone {tstzone : ensure=>installed, iptype=>shared, path=>'/tstzones/mnt' }") do |result|
          assert_match(%r{ensure changed 'configured' to 'installed'}, result.stdout, "err: #{agent}")
        end

        step 'Zone: steps - installed -> running'
        apply_manifest_on(agent, "zone {tstzone : ensure=>running, iptype=>shared, path=>'/tstzones/mnt' }") do |result|
          assert_match(%r{ensure changed 'installed' to 'running'}, result.stdout, "err: #{agent}")
        end

        step 'Zone: steps - running -> installed'
        apply_manifest_on(agent, "zone {tstzone : ensure=>installed, iptype=>shared, path=>'/tstzones/mnt' }") do |result|
          assert_match(%r{ensure changed 'running' to 'installed'}, result.stdout, "err: #{agent}")
        end

        step 'Zone: steps - installed -> configured'
        apply_manifest_on(agent, "zone {tstzone : ensure=>configured, iptype=>shared, path=>'/tstzones/mnt' }") do |result|
          assert_match(%r{ensure changed 'installed' to 'configured'}, result.stdout, "err: #{agent}")
        end
      end
    end
  end
end
