require 'spec_helper'

describe 'selinux::restorecond' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to contain_class('selinux::restorecond') }
      it { is_expected.to contain_class('selinux::restorecond::config') }
      it { is_expected.to contain_class('selinux::restorecond::service') }
    end
  end
end
