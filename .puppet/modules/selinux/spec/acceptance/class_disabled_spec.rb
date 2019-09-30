require 'spec_helper_acceptance'

describe 'selinux class - enforcing to disabled' do
  before(:all) do
    shell('sed -i "s/SELINUX=.*/SELINUX=enforcing/" /etc/selinux/config')
    shell('setenforce Enforcing && test "$(getenforce)" = "Enforcing"')
  end

  let(:pp) do
    <<-EOS
      class { 'selinux': mode => 'disabled' }
    EOS
  end

  context 'before reboot' do
    it_behaves_like 'a idempotent resource'

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

  context 'after reboot' do
    before(:all) do
      hosts.each(&:reboot)
    end

    it 'applies without changes' do
      apply_manifest(pp, catch_changes: true)
    end

    describe command('getenforce') do
      its(:stdout) { is_expected.to match(%r{^Disabled$}) }
    end
  end
end
