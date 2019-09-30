require 'spec_helper'

describe 'wget' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('wget::install') }
      it { is_expected.to contain_class('wget::config') }

      describe 'wget::config' do
        it { is_expected.to have_resource_count(3) }
      end

      describe 'wget::install' do
        let(:params) do
          {
            package_ensure: 'present',
            package_name: 'wget',
            package_manage: true,
          }
        end

        it {
          is_expected.to contain_package('wget').with(
            ensure: 'present',
          )
        }

        describe 'is_expected.to allow package ensure to be overridden' do
          let(:params) do
            {
              package_ensure: 'latest',
              package_name: 'wget',
              package_manage: true,
            }
          end

          it {
            is_expected.to contain_package('wget').with_ensure('latest')
          }
        end

        describe 'is_expected.to allow the package name to be overridden' do
          let(:params) do
            {
              package_ensure: 'present',
              package_name: 'hambaby',
              package_manage: true,
            }
          end

          it {
            is_expected.to contain_package('hambaby')
          }
        end

        describe 'is_expected.to allow the package to be unmanaged' do
          let(:params) do
            {
              package_manage: false,
              package_name: 'wget',
            }
          end

          it {
            is_expected.not_to contain_package('wget')
          }
        end
      end
    end
  end
end
