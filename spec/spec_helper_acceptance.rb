require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  install_module_from_forge('puppetlabs-vcsrepo', '>= 1.3.0 <= 3.0.0')
  install_module_from_forge('puppetlabs-mysql', '>= 2.2.0 <= 5.0.0')
  install_module_from_forge('puppetlabs-apache', '>= 1.11.0 <= 3.0.0')
  install_module_from_forge('puppet-zypprepo', '>= 2.0.0 <= 3.0.0')
  install_module_from_forge('puppetlabs-apt', '>= 2.0.0 <= 3.0.0')

  c.before :suite do
    hosts.each do |host|
      copy_module_to(host, source: proj_root, module_name: 'icingaweb2')
      if fact('osfamily') == 'RedHat'
        # Soft dep on epel for Passenger
        install_package(host, 'epel-release')
      end
    end
  end
end
