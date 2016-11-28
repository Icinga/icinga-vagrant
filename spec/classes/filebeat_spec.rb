require 'spec_helper'

describe 'filebeat', :type => :class do
  context 'defaults' do
    context 'on a system without filebeat installed' do
      describe 'on a Debian system' do
        let :facts do
          {
            :kernel => 'Linux',
            :osfamily => 'Debian',
            :lsbdistid => 'Ubuntu',
            :lsbdistrelease => '16.04',
            :rubyversion => '2.3.1',
            :puppetversion   => Puppet.version,
            :filebeat_version => nil
          }
        end

        it { is_expected.to contain_package('filebeat') }
        it { is_expected.to contain_file('filebeat.yml').with(
          :path => '/etc/filebeat/filebeat.yml',
          :mode => '0644',
        )}
        it { is_expected.to contain_file('filebeat-config-dir').with(
          :ensure => 'directory',
          :path   => '/etc/filebeat/conf.d',
          :mode   => '0755',
          :recurse => true,
        )}
        it { is_expected.to contain_service('filebeat').with(
          :enable => true,
          :ensure => 'running',
          :provider => nil, # Provider should use the resource default
        )}
        it { is_expected.to contain_apt__source('beats').with(
          :location => 'https://artifacts.elastic.co/packages/5.x/apt',
          :key      => {
            'id'     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
            'source' => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          }
        )}
      end

      describe 'on a RHEL system' do
        let :facts do
          {
            :kernel => 'Linux',
            :osfamily => 'RedHat',
            :rubyversion => '2.3.1',
            :puppetversion   => Puppet.version,
            :filebeat_version => nil
          }
        end

        it { is_expected.to contain_yumrepo('beats').with(
          :baseurl => 'https://artifacts.elastic.co/packages/5.x/yum',
          :gpgkey  => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
        ) }

        it { is_expected.to contain_service('filebeat').with(
          :enable => true,
          :ensure => 'running',
          :provider => 'redhat',
        )}

      end

      describe 'on a Windows system' do
        let :facts do
          {
            :kernel => 'Windows',
            :rubyversion => '2.3.1',
            :puppetversion   => Puppet.version,
            :filebeat_version => nil
          }
        end

        it { is_expected.to contain_file('filebeat.yml').with(
          :path => 'C:/Program Files/Filebeat/filebeat.yml',
        )}
        it { is_expected.to contain_file('filebeat-config-dir').with(
          :ensure => 'directory',
          :path   => 'C:/Program Files/Filebeat/conf.d',
          :recurse => true,
        )}
        it { is_expected.to contain_service('filebeat').with(
          :enable => true,
          :ensure => 'running',
          :provider => nil, # Provider should use the resource default
        )}
      end
    end

    context 'on a system with 5.x already installed' do
      describe 'on a Debian system' do
        let :facts do
          {
            :kernel => 'Linux',
            :osfamily => 'Debian',
            :lsbdistid => 'Ubuntu',
            :lsbdistrelease => '16.04',
            :rubyversion => '2.3.1',
            :puppetversion   => Puppet.version,
            :filebeat_version => '5.0.0'
          }
        end

        it { is_expected.to contain_package('filebeat') }
        it { is_expected.to contain_file('filebeat.yml').with(
          :path => '/etc/filebeat/filebeat.yml',
          :mode => '0644',
        )}
        it { is_expected.to contain_file('filebeat-config-dir').with(
          :ensure => 'directory',
          :path   => '/etc/filebeat/conf.d',
          :mode   => '0755',
          :recurse => true,
        )}
        it { is_expected.to contain_service('filebeat').with(
          :enable => true,
          :ensure => 'running',
          :provider => nil, # Provider should use the resource default
        )}
        it { is_expected.to contain_apt__source('beats').with(
          :location => 'https://artifacts.elastic.co/packages/5.x/apt',
          :key      => {
            'id'     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
            'source' => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          }
        )}
      end

      describe 'on a RHEL system' do
        let :facts do
          {
            :kernel => 'Linux',
            :osfamily => 'RedHat',
            :rubyversion => '2.3.1',
            :puppetversion   => Puppet.version,
            :filebeat_version => '5.0.0'
          }
        end

        it { is_expected.to contain_yumrepo('beats').with(
          :baseurl => 'https://artifacts.elastic.co/packages/5.x/yum',
          :gpgkey  => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
        ) }

        it { is_expected.to contain_service('filebeat').with(
          :enable => true,
          :ensure => 'running',
          :provider => 'redhat',
        )}

      end

      describe 'on a Windows system' do
        let :facts do
          {
            :kernel => 'Windows',
            :rubyversion => '2.3.1',
            :puppetversion   => Puppet.version,
            :filebeat_version => '5.0.0'
          }
        end

        it { is_expected.to contain_file('filebeat.yml').with(
          :path => 'C:/Program Files/Filebeat/filebeat.yml',
        )}
        it { is_expected.to contain_file('filebeat-config-dir').with(
          :ensure => 'directory',
          :path   => 'C:/Program Files/Filebeat/conf.d',
          :recurse => true,
        )}
        it { is_expected.to contain_service('filebeat').with(
          :enable => true,
          :ensure => 'running',
          :provider => nil, # Provider should use the resource default
        )}
      end
    end

    context 'on a system with 1.x already installed' do
      describe 'on a Debian system' do
        let :facts do
          {
            :kernel => 'Linux',
            :osfamily => 'Debian',
            :lsbdistid => 'Ubuntu',
            :lsbdistrelease => '16.04',
            :rubyversion => '2.3.1',
            :puppetversion   => Puppet.version,
            :filebeat_version => '1.3.1'
          }
        end

        it { is_expected.to contain_package('filebeat') }
        it { is_expected.to contain_file('filebeat.yml').with(
          :path => '/etc/filebeat/filebeat.yml',
          :mode => '0644',
        )}
        it { is_expected.to contain_file('filebeat-config-dir').with(
          :ensure => 'directory',
          :path   => '/etc/filebeat/conf.d',
          :mode   => '0755',
          :recurse => true,
        )}
        it { is_expected.to contain_service('filebeat').with(
          :enable => true,
          :ensure => 'running',
          :provider => nil, # Provider should use the resource default
        )}
        it { is_expected.to contain_apt__source('beats').with(
          :location => 'http://packages.elastic.co/beats/apt',
          :key      => {
            'id'     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
            'source' => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          }
        )}

      end

      describe 'on a RHEL system' do
        let :facts do
          {
            :kernel => 'Linux',
            :osfamily => 'RedHat',
            :rubyversion => '2.3.1',
            :puppetversion   => Puppet.version,
            :filebeat_version => '1'
          }
        end

        it { is_expected.to contain_yumrepo('beats').with(
          :baseurl => 'https://packages.elastic.co/beats/yum/el/$basearch',
          :gpgkey  => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
        ) }

        it { is_expected.to contain_service('filebeat').with(
          :enable => true,
          :ensure => 'running',
          :provider => 'redhat',
        )}

      end

      describe 'on a Windows system' do
        let :facts do
          {
            :kernel => 'Windows',
            :rubyversion => '2.3.1',
            :puppetversion   => Puppet.version,
            :filebeat_version => '1'
          }
        end

        it { is_expected.to contain_file('filebeat.yml').with(
          :path => 'C:/Program Files/Filebeat/filebeat.yml',
        )}
        it { is_expected.to contain_file('filebeat-config-dir').with(
          :ensure => 'directory',
          :path   => 'C:/Program Files/Filebeat/conf.d',
          :recurse => true,
        )}
        it { is_expected.to contain_service('filebeat').with(
          :enable => true,
          :ensure => 'running',
          :provider => nil, # Provider should use the resource default
        )}
      end
    end
  end

  describe 'on a Solaris system' do
    let :facts do
      {
        :osfamily => 'Solaris',
      }
    end
    context 'it should fail as unsupported' do
      it { expect { should raise_error(Puppet::Error) } }
    end
  end
end
