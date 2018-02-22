require 'spec_helper'

describe 'selinux::fcontext::equivalence' do
  let(:title) { '/opt/some/path' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'ordering on ensure => present' do
        let(:params) do
          {
            target: '/opt/some/other/path'
          }
        end

        it { is_expected.to contain_selinux__fcontext__equivalence('/opt/some/path').that_requires('Anchor[selinux::module post]') }
        it { is_expected.to contain_selinux__fcontext__equivalence('/opt/some/path').that_comes_before('Anchor[selinux::end]') }
        it { is_expected.to contain_selinux_fcontext_equivalence('/opt/some/path').with(target: '/opt/some/other/path') }
      end
      context 'ordering on ensure => absent' do
        let(:params) do
          {
            ensure: 'absent',
            target: '/opt/some/other/path'
          }
        end

        it { is_expected.to contain_selinux__fcontext__equivalence('/opt/some/path').that_requires('Anchor[selinux::start]') }
        it { is_expected.to contain_selinux__fcontext__equivalence('/opt/some/path').that_comes_before('Anchor[selinux::module pre]') }
        it { is_expected.to contain_selinux_fcontext_equivalence('/opt/some/path').with(ensure: 'absent', target: '/opt/some/other/path') }
      end
    end
  end
end
