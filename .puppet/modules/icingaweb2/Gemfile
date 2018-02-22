source 'https://rubygems.org'

gem 'puppet', ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'].to_s : '>= 3.8'

gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet-lint', '>= 0.3.2'
gem 'facter', '>= 1.7.0'
gem 'rspec-puppet-facts', '>= 1.6.0'
gem 'metadata-json-lint'
gem 'semantic_puppet'

unless RUBY_VERSION < '2.0.0'
  group :system_tests do
    if (beaker_version = ENV['BEAKER_VERSION'])
      gem 'beaker', beaker_version
    end
    if (beaker_rspec_version = ENV['BEAKER_RSPEC_VERSION'])
      gem 'beaker-rspec', beaker_rspec_version
    else
      gem 'beaker-rspec',  :require => false
    end
    gem 'serverspec',                    :require => false
    gem 'beaker-puppet_install_helper',  :require => false
    gem 'beaker-module_install_helper',  :require => false
  end
end
