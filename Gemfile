source ENV['GEM_SOURCE'] || "https://rubygems.org"

def location_for(place, version = nil)
  if place =~ /^((?:git|https?)[:@][^#]*)#(.*)/
    [version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, version, { :require => false }].compact
  end
end

gem 'puppetlabs_spec_helper', '>= 0.1.0', :require => false
gem 'puppet-lint', '>= 0.3.2',            :require => false
gem 'rspec-puppet', '>= 2.3.2',           :require => false
gem 'rspec-puppet-facts',                 :require => false
# rubi <1.9 versus rake 11.0.0 workaround
gem 'rake', '< 11.0.0',                   :require => false if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
gem 'json', '< 2.0.0',                    :require => false if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
gem 'json_pure', '<= 2.0.1',              :require => false if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
gem 'metadata-json-lint', '< 1.2.0',      :require => false if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')

gem 'puppet', *location_for(ENV['PUPPET_GEM_VERSION'])

# Only explicitly specify Facter/Hiera if a version has been specified.
# Otherwise it can lead to strange bundler behavior. If you are seeing weird
# gem resolution behavior, try setting `DEBUG_RESOLVER` environment variable
# to `1` and then run bundle install.
gem 'facter', *location_for(ENV['FACTER_GEM_VERSION']) if ENV['FACTER_GEM_VERSION']
gem 'hiera', *location_for(ENV['HIERA_GEM_VERSION']) if ENV['HIERA_GEM_VERSION']


# Evaluate Gemfile.local if it exists
if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

# Evaluate ~/.gemfile if it exists
if File.exists?(File.join(Dir.home, '.gemfile'))
  eval(File.read(File.join(Dir.home, '.gemfile')), binding)
end
