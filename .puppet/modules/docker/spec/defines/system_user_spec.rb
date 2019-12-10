require 'spec_helper'

describe 'docker::system_user', type: :define do
  let(:title) { 'testuser' }
  let(:facts) do
    {
      osfamily: 'Debian',
      operatingsystem: 'Debian',
      lsbdistid: 'Debian',
      lsbdistcodename: 'jessie',
      kernelrelease: '3.2.0-4-amd64',
      operatingsystemmajrelease: '8',
      os: { distro: { codename: 'wheezy' }, family: 'Debian', name: 'Debian', release: { major: '7', full: '7.0' } },
    }
  end

  context 'with default' do
    let(:params) { { 'create_user' => true } }

    it { is_expected.to contain_user('testuser') }
    it { is_expected.to contain_exec('docker-system-user-testuser').with_command(%r{docker testuser}) }
    it { is_expected.to contain_exec('docker-system-user-testuser').with_unless(%r{grep -qw testuser}) }
  end

  context 'with create_user => false' do
    let(:params) { { 'create_user' => false } }

    it { is_expected.to contain_exec('docker-system-user-testuser').with_command(%r{docker testuser}) }
  end
end
