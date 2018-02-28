require 'spec_helper'

describe('icingaweb2::config::role', :type => :define) do
  let(:title) { 'myrole' }
  let(:pre_condition) { [
      "class { 'icingaweb2': }"
  ] }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context "#{os} with users => 'bob, pete' and permissions => '*'" do
        let(:params) { { :users => 'bob, pete', :permissions => '*' } }

        it { is_expected.to contain_icingaweb2__inisection('myrole')
                                .with_target('/etc/icingaweb2/roles.ini')
                                .with_settings({'users'=>'bob, pete', 'permissions' => '*'}) }

      end

      context "#{os} with users => 'bob, pete', permissions => 'module/monitoring', filters => {'monitoring/filter/objects' => 'host_name=linux-*'}" do
        let(:params) { { :users => 'bob, pete', :permissions => 'module/monitoring', :filters => {'monitoring/filter/objects' => 'host_name=linux-*'} } }

        it { is_expected.to contain_icingaweb2__inisection('myrole')
                                .with_target('/etc/icingaweb2/roles.ini')
                                .with_settings({'users'=>'bob, pete', 'permissions'=>'module/monitoring', 'monitoring/filter/objects'=>'host_name=linux-*'}) }

      end
    end
  end
end
