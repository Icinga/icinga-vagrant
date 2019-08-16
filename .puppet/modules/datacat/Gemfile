#!ruby
source 'https://rubygems.org'

group :development, :test do
  if RUBY_VERSION =~ /^1.8\./
    # Rake 11.0 removes support for ruby 1.8; pin to previous version.
    gem 'rake', '~> 10.4.2'
  else
    gem 'rake'
  end
  gem 'puppetlabs_spec_helper', :require => false
  gem 'puppet-lint'
end

group :integration do
  gem 'test-kitchen'
  gem 'kitchen-docker'
  gem 'kitchen-inspec'
  gem 'kitchen-puppet'
end

# json/json_pure are transitive dependences of puppet.
# They dropped support for ruby 1.8 and 1.9 in their 2.0 releases
# https://github.com/flori/json/blob/master/CHANGES.md#2015-09-11-200
gem 'json', '~> 1.8.0', :platform => [:ruby_18, :ruby_19]
gem 'json_pure', '~> 1.8.0', :platform => [:ruby_18, :ruby_19]

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
