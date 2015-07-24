source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :unit_tests do
  gem 'rake',                    :require => false
  # https://github.com/rspec/rspec-core/issues/1864
  gem 'rspec', '< 3.2.0', {"platforms"=>["ruby_18"]}
  gem 'rspec-puppet', '~> 2.1',  :require => false
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'puppet-lint', '~> 1.0',    :require => false
  gem 'puppet-syntax',           :require => false
  gem 'metadata-json-lint',      :require => false
  gem 'json',                    :require => false
end

group :development do
  gem 'simplecov',   :require => false
  gem 'guard-rake',  :require => false
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
