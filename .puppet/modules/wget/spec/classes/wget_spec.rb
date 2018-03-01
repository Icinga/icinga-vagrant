require 'spec_helper'

describe 'wget' do
  let(:facts) {{ :is_virtual => 'false' }}

  on_supported_os.select { |_, f| f[:os]['family'] != 'Solaris' }.each do |os, f|
    context "on #{os}" do
      let(:facts) do
        f.merge(super())
      end

      it { is_expected.to compile.with_all_deps }

      it { should contain_class('wget::install') }
      it { should contain_class('wget::config') }

      describe "wget::config" do
        it { is_expected.to have_resource_count(3) }
      end

      describe 'wget::install' do
        let(:params) {{ :package_ensure => 'present', :package_name => 'wget', :package_manage => true, }}

        it { should contain_package('wget').with(
          :ensure => 'present'
        )}

        describe 'should allow package ensure to be overridden' do
          let(:params) {{ :package_ensure => 'latest', :package_name => 'wget', :package_manage => true, }}
          it { should contain_package('wget').with_ensure('latest') }
        end

        describe 'should allow the package name to be overridden' do
          let(:params) {{ :package_ensure => 'present', :package_name => 'hambaby', :package_manage => true, }}
          it { should contain_package('hambaby') }
        end

        describe 'should allow the package to be unmanaged' do
          let(:params) {{ :package_manage => false, :package_name => 'wget', }}
          it { should_not contain_package('wget') }
        end
      end

    end
  end
end
