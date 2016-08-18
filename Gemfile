source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  gem 'rake',                   :require => false
  gem 'rspec','< 3.2.0',        :require => false
  gem 'rspec-puppet','~> 2.2',  :require => false
  gem 'puppetlabs_spec_helper', :require => false
  gem 'puppet-lint',            :require => false
  gem 'simplecov',              :require => false
  gem 'puppet_facts',           :require => false
  gem 'json_pure','~> 1.8',     :require => false
  gem 'json',                   :require => false
  gem 'metadata-json-lint',     :require => false
  gem 'rspec-puppet-facts', '~> 0.10'
end

group :system_tests do
  gem 'beaker-rspec',        :require => false
  gem 'serverspec',          :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
