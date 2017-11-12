require 'spec_helper'

describe 'php', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      describe 'when called with no parameters' do
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.not_to contain_class('php::global') }
          it { is_expected.to contain_class('php::fpm') }
          it { is_expected.to contain_package('php5-cli').with_ensure('present') }
          it { is_expected.to contain_package('php5-fpm').with_ensure('present') }
          it { is_expected.to contain_package('php5-dev').with_ensure('present') }
          it { is_expected.to contain_package('php-pear').with_ensure('present') }
          it { is_expected.to contain_class('php::composer') }
        when 'Suse'
          it { is_expected.to contain_class('php::global') }
          it { is_expected.to contain_package('php5').with_ensure('present') }
          it { is_expected.to contain_package('php5-devel').with_ensure('present') }
          it { is_expected.to contain_package('php5-pear').with_ensure('present') }
          it { is_expected.not_to contain_package('php5-cli') }
          it { is_expected.not_to contain_package('php5-dev') }
          it { is_expected.not_to contain_package('php-pear') }
        end
      end

      describe 'when called with package_prefix parameter' do
        let(:params) { { package_prefix: 'myphp-' } }
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.not_to contain_class('php::global') }
          it { is_expected.to contain_class('php::fpm') }
          it { is_expected.to contain_package('myphp-cli').with_ensure('present') }
          it { is_expected.to contain_package('myphp-fpm').with_ensure('present') }
          it { is_expected.to contain_package('myphp-dev').with_ensure('present') }
          it { is_expected.to contain_package('php-pear').with_ensure('present') }
          it { is_expected.to contain_class('php::composer') }
        when 'Suse'
          it { is_expected.to contain_class('php::global') }
          it { is_expected.to contain_package('php5').with_ensure('present') }
          it { is_expected.to contain_package('myphp-devel').with_ensure('present') }
          it { is_expected.to contain_package('myphp-pear').with_ensure('present') }
          it { is_expected.not_to contain_package('myphp-cli') }
          it { is_expected.not_to contain_package('myphp-dev') }
          it { is_expected.not_to contain_package('php-pear') }
        end
      end

      describe 'when fpm is disabled' do
        let(:params) { { fpm: false } }
        it { is_expected.not_to contain_class('php::fpm') }
      end
      describe 'when composer is disabled' do
        let(:params) { { composer: false } }
        it { is_expected.not_to contain_class('php::composer') }
      end
    end
  end
end
