require 'puppet'
require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

$LOAD_PATH << File.join(__dir__, 'acceptance/lib')

def beaker_opts
  { debug: true, trace: true, expect_failures: true, acceptable_exit_codes: (0...256) }
end

def solaris_agents
  agents.select { |agent| agent['platform'].include?('solaris') }
end

unless ENV['BEAKER_provision'] == 'no'
  run_puppet_install_helper
  install_module_on(hosts)
  install_module_dependencies_on(hosts)
end
