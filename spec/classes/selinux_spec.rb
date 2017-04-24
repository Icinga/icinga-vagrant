require 'spec_helper'

describe 'selinux' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { is_expected.to contain_class('selinux').without_mode }
      it { is_expected.to contain_class('selinux').without_type }
      it { is_expected.to contain_class('selinux::package') }
      it { is_expected.to contain_class('selinux::config') }
      it { is_expected.to contain_class('selinux::params') }
    end
  end
end
