# frozen_string_literal: true

require 'spec_helper'

describe 'kibana', :type => 'class' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge('scenario' => '', 'common' => '')
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
                .with(
                  :ensure => 'file',
                  :owner  => 'kibana',
                  :group  => 'kibana',
                  :mode   => '0660'
                )
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

            it do
              is_expected.to contain_class('elastic_stack::repo')
                .that_comes_before('Class[kibana::install]')
            end

            describe "#{facts[:os]['family']} resources" do
              case facts[:os]['family']
              when 'Debian'
                it 'updates package cache before installing kibana' do
                  is_expected.to contain_class('apt::update')
                    .that_comes_before('Package[kibana]')
                end
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
              %w[present absent latest 5.2.1 5.2.2-1 5.2.2-bpo1].each do |param|
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
                'elasticsearch.requestHeadersWhitelist' => ['authorization'],
                'tilemap' => { 'url' => 'https://test' }
              }.each do |key, val|
                context "'#{val}'" do
                  let(:params) { { :config => { key => val } } }
                  it { should compile.with_all_deps }
                end
              end
            end

            context 'with bad parameters' do
              {
                'server.basePath' => '',
                5601 => :undef,
                '' => :undef
              }.each do |key, val|
                context "'#{val}'" do
                  let(:params) { { :config => { key => val } } }
                  it { should_not compile.with_all_deps }
                end
              end
            end
          end

          describe 'manage_repo' do
            let(:params) { { :manage_repo => false } }
            it { is_expected.not_to contain_class('elastic_stack::repo') }
          end

          describe 'package_source' do
            describe 'validation' do
              [{ 'foo' => 'bar' }, true, []].each do |param|
                context "against #{param.class}" do
                  let(:params) { { :package_source => param } }
                  it { should_not compile.with_all_deps }
                end
              end
            end

            describe "on #{facts[:os]['family']}" do
              let(:package_source) { '/tmp/kibana-5.0.0-linux-x86_64.rpm' }
              let(:params) { { :package_source => package_source } }

              it { is_expected.to contain_package('kibana')
                .with_source(package_source) }

              case facts[:os]['family']
              when 'Debian'
                it { is_expected.to contain_package('kibana')
                  .with_provider('dpkg') }
              when 'RedHat'
                it { is_expected.to contain_package('kibana')
                  .with_provider('rpm') }
              else
                it { should_not compile.with_all_deps }
              end
            end
          end
        end
      end
    end
  end
end
