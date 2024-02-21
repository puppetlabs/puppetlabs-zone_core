require 'puppet'
require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'voxpupuli/acceptance/spec_helper_acceptance'

$LOAD_PATH << File.join(__dir__, 'acceptance/lib')

def solaris_agents
  agents.select { |agent| agent['platform'].include?('solaris') }
end

RSpec.configure do |c|
  c.before :suite do
    unless ENV['BEAKER_provision'] == 'no'
      hosts.each { |host| host[:type] = 'aio' }
      run_puppet_install_helper
      install_module_on(hosts)
      install_module_dependencies_on(hosts)
    end
  end
end
