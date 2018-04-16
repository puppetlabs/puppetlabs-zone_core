require 'spec_helper_acceptance'
require 'zone_util'

RSpec.context 'zone manages path' do
  after(:all) do
    solaris_agents.each do |agent|
      ZoneUtils.clean(agent)
    end
  end

  let(:zone_with_path1) do
    <<-MANIFEST
    zone { 'tstzone':
      ensure => configured,
      iptype => shared,
      path   => '/tstzones/mnt'
    }
    MANIFEST
  end

  let(:zone_with_path2) do
    <<-MANIFEST
    zone { 'tstzone':
      ensure => configured,
      iptype => shared,
      path   => '/tstzones/mnt2'
    }
    MANIFEST
  end

  solaris_agents.each do |agent|
    context "on #{agent}" do
      it 'creates a zone with a path' do
        step 'Zone: path - required parameter (+)'
        apply_manifest_on(agent, zone_with_path1) do |result|
          assert_match(%r{ensure: created}, result.stdout, "err: #{agent}")
        end

        step 'Zone: path - should change the path if it is switched before install'
        apply_manifest_on(agent, zone_with_path2) do |result|
          assert_match(%r{path changed '.tstzones.mnt'.* to '.tstzones.mnt2'}, result.stdout, "err: #{agent}")
        end

        step 'Zone: path - verify the path is correct'
        on agent, '/usr/sbin/zonecfg -z tstzone export' do |result|
          assert_match(%r{set zonepath=.*mnt2}, result.stdout, "err: #{agent}")
        end

        step 'Zone: path - revert to original path'
        apply_manifest_on(agent, zone_with_path1) do |result|
          assert_match(%r{path changed '.tstzones.mnt2'.* to '.tstzones.mnt'}, result.stdout, "err: #{agent}")
        end

        step 'Zone: path - verify that we have correct path'
        on agent, '/usr/sbin/zonecfg -z tstzone export' do |result|
          assert_match(%r{set zonepath=.tstzones.mnt}, result.stdout, "err: #{agent}")
        end
      end
    end
  end
end
