source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place_or_version, fake_version = nil)
  git_url_regex = %r{\A(?<url>(https?|git)[:@][^#]*)(#(?<branch>.*))?}
  file_url_regex = %r{\Afile:\/\/(?<path>.*)}

  if place_or_version && (git_url = place_or_version.match(git_url_regex))
    [fake_version, { git: git_url[:url], branch: git_url[:branch], require: false }].compact
  elsif place_or_version && (file_url = place_or_version.match(file_url_regex))
    ['>= 0', { path: File.expand_path(file_url[:path]), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

group :development do
  gem "json", '= 2.1.0',                                                       require: false if Gem::Requirement.create(['>= 2.5.0', '< 2.7.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "json", '= 2.3.0',                                                       require: false if Gem::Requirement.create(['>= 2.7.0', '< 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "json", '= 2.5.1',                                                       require: false if Gem::Requirement.create(['>= 3.0.0', '< 3.0.5']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "json", '= 2.6.1',                                                       require: false if Gem::Requirement.create(['>= 3.1.0', '< 3.1.3']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "json", '= 2.6.3',                                                       require: false if Gem::Requirement.create(['>= 3.2.0', '< 4.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "racc", '~> 1.4.0',                                                      require: false if Gem::Requirement.create(['>= 2.7.0', '< 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "deep_merge", '~> 1.0',                                                  require: false
  gem "voxpupuli-puppet-lint-plugins", '~> 5.0',                               require: false
  gem "facterdb", '~> 1.18',                                                   require: false
  gem "metadata-json-lint", '~> 4.0',                                          require: false
  gem "rspec-puppet-facts", '~> 3.0',                                          require: false
  gem "dependency_checker", '~> 1.0.0',                                        require: false
  gem "parallel_tests", '= 3.12.1',                                            require: false
  gem "pry", '~> 0.10',                                                        require: false
  gem "simplecov-console", '~> 0.9',                                           require: false
  gem "puppet-debugger", '~> 1.0',                                             require: false
  gem "rubocop", '~> 1.50.0',                                                  require: false
  gem "rubocop-performance", '= 1.16.0',                                       require: false
  gem "rubocop-rspec", '= 2.19.0',                                             require: false
  gem "rb-readline", '= 0.5.5',                                                require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "beaker", *location_for(ENV['BEAKER_VERSION'] || '~> 6.0')
  gem "beaker-abs", *location_for(ENV['BEAKER_ABS_VERSION'] || '~> 1.0')
  gem "beaker-hostgenerator"
  gem "beaker-rspec"
  gem "beaker-puppet", *location_for(ENV['BEAKER_PUPPET_VERSION'] || '~> 4.0') if Gem::Requirement.create('< 3.2.0').satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "async", '~> 1',                                                         require: false
  gem "beaker-module_install_helper",                                          require: false
  gem "nokogiri",                                                              require: false
end
group :development, :release_prep do
  gem "puppet-strings", '~> 4.0',         require: false
  gem "puppetlabs_spec_helper", '~> 7.0', require: false
end
group :system_tests do
  gem "CFPropertyList", '< 3.0.7', require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "serverspec", '~> 2.41',     require: false
  gem "voxpupuli-acceptance",      require: false
end

gems = {}
puppet_version = ENV.fetch('PUPPET_GEM_VERSION', nil)
facter_version = ENV.fetch('FACTER_GEM_VERSION', nil)
hiera_version = ENV.fetch('HIERA_GEM_VERSION', nil)

# If PUPPET_FORGE_TOKEN is set then use authenticated source for both puppet and facter, since facter is a transitive dependency of puppet
# Otherwise, do as before and use location_for to fetch gems from the default source
if !ENV['PUPPET_FORGE_TOKEN'].to_s.empty?
  gems['puppet'] = ['~> 8.11', { require: false, source: 'https://rubygems-puppetcore.puppet.com' }]
  gems['facter'] = ['~> 4.11', { require: false, source: 'https://rubygems-puppetcore.puppet.com' }]
else
  gems['puppet'] = location_for(puppet_version)
  gems['facter'] = location_for(facter_version) if facter_version
end

gems['hiera'] = location_for(hiera_version) if hiera_version

gems.each do |gem_name, gem_params|
  gem gem_name, *gem_params
end

# Evaluate Gemfile.local and ~/.gemfile if they exist
extra_gemfiles = [
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
]

extra_gemfiles.each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding)
  end
end
# vim: syntax=ruby
