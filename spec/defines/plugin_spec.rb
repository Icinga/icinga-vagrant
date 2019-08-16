require 'spec_helper'

describe 'yum::plugin' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:prefix) { facts[:os]['release']['major'] == '5' ? 'yum' : 'yum-plugin' }

      context 'with no parameters' do
        let(:title) { 'fastestmirror' }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package("#{prefix}-#{title}").with_ensure('present') }
      end

      context 'when explicitly set to install' do
        let(:title) { 'fastestmirror' }
        let(:params) { { ensure: 'present' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package("#{prefix}-#{title}").with_ensure('present') }
      end

      context 'when explicitly set to remove' do
        let(:title) { 'fastestmirror' }
        let(:params) { { ensure: 'absent' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package("#{prefix}-#{title}").with_ensure('absent') }
      end
    end
  end
end
