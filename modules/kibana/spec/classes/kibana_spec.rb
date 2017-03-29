# frozen_string_literal: true
require 'spec_helper'

describe 'kibana', :type => 'class' do
  let(:repo_baseurl)    { 'https://artifacts.elastic.co/packages' }
  let(:repo_key_id)     { '46095ACC8548582C1A2699A9D27D666CD88E42B4' }
  let(:repo_key_source) { 'https://artifacts.elastic.co/GPG-KEY-elasticsearch' }
  let(:repo_version)    { '5.x' }

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        describe 'installation' do
          context 'kibana class without any parameters' do
            it { is_expected.to compile.with_all_deps }

            it 'sets expected defaults' do
              is_expected.to contain_class('kibana').with(
                :ensure => 'present',
                :manage_repo => true
              )
            end
            it 'declares install before config' do
              is_expected.to contain_class('kibana::install')
                .that_comes_before('Class[kibana::config]')
            end
            it { is_expected.to contain_class('kibana::config') }
            it 'subscribes service to config' do
              is_expected.to contain_class('kibana::service')
                .that_subscribes_to('Class[kibana::config]')
            end

            it 'installs the kibana config file' do
              is_expected.to contain_file('/etc/kibana/kibana.yml')
                .with_content(/
                # Managed by Puppet..
                ---.
                /xm)
            end

            it 'enables and starts the service' do
              is_expected.to contain_service('kibana').with(
                :ensure => true,
                :enable => true
              )
            end
            it { is_expected.to contain_package('kibana').with_ensure('present') }

            describe "#{facts[:osfamily]} resources" do
              case facts[:osfamily]
              when 'Debian'
                it 'updates package cache before installing kibana' do
                  is_expected.to contain_class('apt::update')
                    .that_comes_before('Package[kibana]')
                end
                it 'installs the repo apt source' do
                  is_expected.to contain_apt__source('kibana')
                    .with(
                      :ensure   => 'present',
                      :location => "#{repo_baseurl}/#{repo_version}/apt",
                      :release  => 'stable',
                      :repos    => 'main',
                      :key      => {
                        'id'     => repo_key_id,
                        'source' => repo_key_source
                      },
                      :include => {
                        'src' => false,
                        'deb' => true
                      }
                    )
                    .that_comes_before('Package[kibana]')
                end
              when 'RedHat'
                it 'installs the yum repository' do
                  is_expected.to contain_yumrepo('kibana')
                    .with(
                      :ensure   => 'present',
                      :descr    => "Elastic #{repo_version} repository",
                      :baseurl  => "#{repo_baseurl}/#{repo_version}/yum",
                      :gpgcheck => 1,
                      :gpgkey   => repo_key_source,
                      :enabled  => 1
                    )
                    .that_comes_before(
                      'Package[kibana]'
                    )
                    .that_notifies(
                      'Exec[kibana_yumrepo_yum_clean]'
                    )
                  is_expected.to contain_exec('kibana_yumrepo_yum_clean')
                    .with(
                      :command     => 'yum clean metadata expire-cache --disablerepo="*" --enablerepo="kibana"',
                      :path        => ['/bin', '/usr/bin'],
                      :refreshonly => true,
                      :returns     => [0, 1]
                    )
                    .that_comes_before(
                      'Package[kibana]'
                    )
                end
              else
                pending "no tests for #{facts[:osfamily]}"
              end
            end
          end
        end

        describe 'removal' do
          let :params do
            {
              :ensure => 'absent'
            }
          end

          it { should compile.with_all_deps }
          it 'sets expected defaults' do
            is_expected.to contain_class('kibana').with(
              :ensure => 'absent'
            )
          end
          it 'manages service before config' do
            is_expected.to contain_class('kibana::service')
              .that_comes_before('Class[kibana::config]')
          end
          it 'manages config before install' do
            is_expected.to contain_class('kibana::config')
              .that_comes_before('Class[kibana::install]')
          end
          it { is_expected.to contain_class('kibana::install') }

          it 'stops and disables the service' do
            is_expected.to contain_service('kibana')
              .with(
                :ensure => false,
                :enable => false
              )
          end

          it 'removes the kibana config file' do
            is_expected.to contain_file('/etc/kibana/kibana.yml')
              .with(:ensure => 'absent')
          end

          it { is_expected.to contain_package('kibana').with_ensure('absent') }
        end

        describe 'parameter validation for' do
          describe 'ensure' do
            context 'valid parameter' do
              %w(present absent latest 5.2.1 5.2.2-1 5.2.2-bpo1).each do |param|
                context param do
                  let(:params) { { :ensure => param } }
                  it { should compile.with_all_deps }
                  it { is_expected.to contain_package('kibana')
                    .with_ensure(param) }
                end
              end
            end

            context 'bad parameters' do
              let(:params) { { :ensure => 'foo' } }
              it { should_not compile.with_all_deps }
            end
          end

          describe 'config' do
            context 'with valid parameters' do
              {
                'server.host' => 'localhost',
                'server.port' => 5601,
                'elasticsearch.ssl.verify' => true,
                'elasticsearch.requestHeadersWhitelist' => [ 'authorization' ]
              }.each do |key, val|
                context "'#{val}'" do
                  let(:params) { { :config => { key => val } } }
                  it { should compile.with_all_deps }
                end
              end
            end

            context 'with bad parameters' do
              {
                'server.host' => { 'foo' => 'bar' },
                'server.basePath' => '',
                5601 => nil,
                '' => nil
              }.each do |key, val|
                context "'#{val}'" do
                  let(:params) { { :config => { key => val } } }
                  it { should_not compile.with_all_deps }
                end
              end
            end
          end

          describe 'repo_version' do
            context 'valid parameter' do
              %w(5.x 4.1 4.4 4.5 4.6).each do |param|
                let(:params) { { :repo_version => param } }
                it { should compile.with_all_deps }
              end
            end

            context 'invalid parameter' do
              %w(foo 6.x 4.x 3.x 4.2 4.3).each do |param|
                let(:params) { { :repo_version => param } }
                it { should_not compile.with_all_deps }
              end
            end

            context '4.x repo URLs' do
              let(:repo_version) { '4.6' }
              let(:params) { { :repo_version => repo_version } }
              let(:repo_baseurl) { 'https://packages.elastic.co/kibana' }

              it { should contain_file('/opt/kibana/config/kibana.yml') }

              case facts[:osfamily]
              when 'Debian'
                it 'installs the 4.x repo apt source' do
                  is_expected
                    .to contain_apt__source('kibana')
                    .with(:location => "#{repo_baseurl}/#{repo_version}/debian")
                end
              when 'RedHat'
                it 'installs the 4.x yum repository' do
                  is_expected
                    .to contain_yumrepo('kibana')
                    .with(:baseurl => "#{repo_baseurl}/#{repo_version}/centos")
                end
              else
                pending "no 4.x repo tests for #{facts[:osfamily]}"
              end
            end
          end

          describe 'manage_repo' do
            let(:params) { { :manage_repo => false } }
            case facts[:osfamily]
            when 'Debian'
              it { is_expected.not_to contain_class('apt') }
              it { is_expected.not_to contain_package('apt-transport-https') }
              it { is_expected.not_to contain_apt__source('kibana') }
            when 'RedHat'
              it { is_expected.not_to contain_yumrepo('kibana') }
              it { is_expected.not_to contain_exec('kibana_yumrepo_yum_clean') }
            else
              pending "no tests for #{facts[:osfamily]}"
            end
          end
        end
      end
    end
  end
end
