require 'spec_helper'

describe 'docker::secrets', type: :define do
  let(:title) { 'test_secret' }
  let(:facts) do
    {
      osfamily: 'Debian',
      operatingsystem: 'Debian',
      lsbdistid: 'Debian',
      lsbdistcodename: 'jessie',
      kernelrelease: '3.2.0-4-amd64',
      operatingsystemmajrelease: '8',
    }
  end

  context 'with secret_name => test_secret and secret_path => /root/secret.txt and label => test' do
    let(:params) do
      {
        'secret_name' => 'test_secret',
        'secret_path' => '/root/secret.txt',
        'label' => ['test'],
      }
    end

    it { is_expected.to contain_exec('test_secret docker secret create').with_command(%r{docker secret create}) }
    context 'multiple secrets declaration' do
      let(:pre_condition) do
        "
        docker::secrets{'test_secret_2':
          secret_name => 'test_secret_2',
          secret_path => '/root/secret_2.txt',
        }
        "
      end

      it { is_expected.to contain_exec('test_secret docker secret create').with_command(%r{docker secret create}) }
      it { is_expected.to contain_exec('test_secret_2 docker secret create').with_command(%r{docker secret create}) }
    end
  end

  context 'with ensure => absent and secret_name => test_secret' do
    let(:params) do
      {
        'ensure' => 'absent',
        'secret_name' => 'test_secret',
      }
    end

    it { is_expected.to contain_exec('test_secret docker secret rm').with_command(%r{docker secret rm}) }
  end
end
