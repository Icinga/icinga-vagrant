#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'icingaweb2 with apache2' do
  it 'with basic settings and apache2' do
    pp = "
        class { 'apache':
          mpm_module => 'prefork'
        }

        class { 'apache::mod::php': }

        case $::osfamily {
          'redhat': {
            file {'/etc/httpd/conf.d/icingaweb2.conf':
              source  => 'puppet:///modules/icingaweb2/examples/apache2/icingaweb2.conf',
              require => Class['apache'],
              notify  => Service['httpd'],
            }

            package { 'centos-release-scl':
              before => Class['icingaweb2']
            }
          }
          'debian': {
            class { 'apache::mod::rewrite': }

            file {'/etc/apache2/conf.d/icingaweb2.conf':
              source  => 'puppet:///modules/icingaweb2/examples/apache2/icingaweb2.conf',
              require => Class['apache'],
              notify  => Service['apache2'],
            }
          }
        }

        class {'icingaweb2':
          manage_repo   => true,
        }
    "

    apply_manifest(pp, catch_failures: true)
  end

  if fact('osfamily') == 'Debian'
    describe service('apache2') do
      it { is_expected.to be_running }
    end
  end

  if fact('osfamily') == 'RedHat'
    describe service('httpd') do
      it { is_expected.to be_running }
    end
  end

  describe command('curl -I http://localhost/icingaweb2/') do
    its(:stdout) { should match(%r{302 Found}) }
  end
end
