source 'https://rubygems.org'
ruby '1.9.3'

puppetversion = ENV['PUPPET_VERSION'] || '3.8.6'
gem 'puppet', puppetversion, :require => false

gem 'beaker'
gem 'beaker-rspec'

# REF: https://github.com/voxpupuli/metadata-json-lint/issues/10
# gem 'metadata-json-lint'

gem 'rspec-puppet'

gem 'pry'
gem 'pry-rescue'
gem 'docker-api', '~> 1.0'
gem 'rubysl-securerandom'
gem 'ci_reporter_rspec'
gem 'google-api-client', '0.9.4' # 0.9.5 needs Ruby 2.
gem 'rspec', '~> 3.0'
gem 'rake'
gem 'puppet-doc-lint'
gem 'puppet-lint'
gem 'puppet-strings' if puppetversion =~ /^(3\.[789]|4\.)/
gem 'puppetlabs_spec_helper'
gem 'puppet-syntax'
gem 'rspec-puppet-facts'
gem 'rubocop'
gem 'serverspec'
gem 'webmock'
gem 'redcarpet'

# Extra Puppet-lint gems
gem 'puppet-lint-appends-check', :require => false
gem 'puppet-lint-version_comparison-check', :require => false
gem 'puppet-lint-unquoted_string-check', :require => false
gem 'puppet-lint-undef_in_function-check', :require => false
gem 'puppet-lint-trailing_comma-check', :require => false
gem 'puppet-lint-leading_zero-check', :require => false
gem 'puppet-lint-file_ensure-check', :require => false
gem 'puppet-lint-empty_string-check', :require => false
