#!ruby
source 'https://rubygems.org'

group :development, :test do
  gem 'rake'
  gem 'puppetlabs_spec_helper', :require => false
  gem 'puppet-lint'
end

group :development do
  gem 'pry'
  gem 'pry-debugger'
  gem 'rb-readline'
  gem 'awesome_print'
  gem 'rspec-system-puppet', '~>2.0'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
