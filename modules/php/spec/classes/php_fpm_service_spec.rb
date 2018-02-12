require 'spec_helper'

describe 'php::fpm::service', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      let(:pre_condition) { 'class {"php": fpm => true}' }

      describe 'when called with no parameters' do
        # rubocop:disable RSpec/RepeatedExample
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_service('php5-fpm').with_ensure('running') }
          if facts[:operatingsystem] == 'Ubuntu'
            if facts[:operatingsystemrelease] == '12.04'
              it { is_expected.to contain_service('php5-fpm').without_restart }
            else
              it { is_expected.to contain_service('php5-fpm').with_restart('service php5-fpm reload') }
            end
          end
        when 'Suse'
          it { is_expected.to contain_service('php-fpm').with_ensure('running') }
        when 'FreeBSD'
          it { is_expected.to contain_service('php-fpm').with_ensure('running') }
        else
          it { is_expected.to contain_service('php-fpm').with_ensure('running') }
        end
      end
    end
  end
end
