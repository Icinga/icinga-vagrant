require 'spec_helper'

describe 'mongodb::repo' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      describe 'without parameters' do
        it { is_expected.to raise_error(Puppet::Error, %r{unsupported}) }
      end

      describe 'with version set' do
        let :params do
          {
            version: '3.6.1'
          }
        end

        case facts[:osfamily]
        when 'RedHat'
          it { is_expected.to contain_class('mongodb::repo::yum') }
          it do
            is_expected.to contain_yumrepo('mongodb').
              with_baseurl('https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.6/$basearch/')
          end
        when 'Debian'
          it { is_expected.to contain_class('mongodb::repo::apt') }
          case facts[:operatingsystem]
          when 'Debian'
            it do
              is_expected.to contain_apt__source('mongodb').
                with_location('https://repo.mongodb.org/apt/debian').
                with_release("#{facts[:lsbdistcodename]}/mongodb-org/3.6")
            end
          when 'Ubuntu'
            it do
              is_expected.to contain_apt__source('mongodb').
                with_location('https://repo.mongodb.org/apt/ubuntu').
                with_release("#{facts[:lsbdistcodename]}/mongodb-org/3.6")
            end
          end
        else
          it { is_expected.to raise_error(Puppet::Error, %r{not supported}) }
        end
      end

      describe 'with proxy' do
        let :params do
          {
            version: '3.6.1',
            proxy: 'http://proxy-server:8080',
            proxy_username: 'proxyuser1',
            proxy_password: 'proxypassword1'
          }
        end

        case facts[:osfamily]
        when 'RedHat'
          it { is_expected.to contain_class('mongodb::repo::yum') }
          it do
            is_expected.to contain_yumrepo('mongodb').
              with_enabled('1').
              with_proxy('http://proxy-server:8080').
              with_proxy_username('proxyuser1').
              with_proxy_password('proxypassword1')
          end
        when 'Debian'
          it { is_expected.to contain_class('mongodb::repo::apt') }
        else
          it { is_expected.to raise_error(Puppet::Error, %r{not supported}) }
        end
      end
    end
  end
end
