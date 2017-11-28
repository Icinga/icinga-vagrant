require 'spec_helper_acceptance'

describe 'selinux class disabled' do
  let(:pp) do
    <<-EOS
      class { 'selinux': mode => 'disabled' }
    EOS
  end

  it 'runs without errors' do
    apply_manifest(pp, catch_failures: true)
  end

  describe package('selinux-policy-targeted') do
    it { is_expected.to be_installed }
  end

  describe file('/etc/selinux/config') do
    its(:content) { is_expected.to match(%r{^SELINUX=disabled$}) }
  end

  # Testing for Permissive brecause only after a reboot it's disabled
  describe command('getenforce') do
    its(:stdout) { is_expected.to match(%r{^Permissive$}) }
  end
end
