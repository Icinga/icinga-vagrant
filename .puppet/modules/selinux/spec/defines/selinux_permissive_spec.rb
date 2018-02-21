require 'spec_helper'

describe 'selinux::permissive' do
  let(:title) { 'mycontextp' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'ensure selinux_permissive oddjob_mkhomedir_t is present' do
        let(:params) do
          {
            seltype: 'oddjob_mkhomedir_t'
          }
        end

        it { is_expected.to contain_selinux_permissive('oddjob_mkhomedir_t').with(ensure: 'present') }
        it { is_expected.to contain_selinux__permissive('mycontextp').that_requires('Anchor[selinux::module post]') }
        it { is_expected.to contain_selinux__permissive('mycontextp').that_comes_before('Anchor[selinux::end]') }
      end

      context 'ensure selinux_permissive oddjob_mkhomedir_t is absent' do
        let(:params) do
          {
            seltype: 'oddjob_mkhomedir_t',
            ensure: 'absent'
          }
        end

        it { is_expected.to contain_selinux_permissive('oddjob_mkhomedir_t').with(ensure: 'absent') }
        it { is_expected.to contain_selinux__permissive('mycontextp').that_requires('Anchor[selinux::start]') }
        it { is_expected.to contain_selinux__permissive('mycontextp').that_comes_before('Anchor[selinux::module pre]') }
      end

      context 'selinux_permissive oddjob_mkhomedir_t with title only' do
        let(:title) do
          'oddjob_mkhomedir_t'
        end

        it { is_expected.to contain_selinux_permissive('oddjob_mkhomedir_t').with(ensure: 'present') }
        it { is_expected.to contain_selinux__permissive('oddjob_mkhomedir_t').that_requires('Anchor[selinux::module post]') }
        it { is_expected.to contain_selinux__permissive('oddjob_mkhomedir_t').that_comes_before('Anchor[selinux::end]') }
      end
    end
  end
end
