require 'spec_helper'

describe 'docker::machine', type: :class do
  let(:facts) do
    {
      kernel: 'Linux',
      osfamily: 'Debian',
      operatingsystem: 'Ubuntu',
      lsbdistid: 'Ubuntu',
      lsbdistcodename: 'maverick',
      kernelrelease: '3.8.0-29-generic',
      operatingsystemrelease: '10.04',
      operatingsystemmajrelease: '10',
    }
  end

  it { is_expected.to compile }

  context 'with defaults for all parameters' do
    it { is_expected.to compile.with_all_deps }
    it {
      is_expected.to contain_exec('Install Docker Machine 0.16.1').with(
        'path'    => '/usr/bin/',
        'cwd'     => '/tmp',
        'command' => 'curl -s -S -L  https://github.com/docker/machine/releases/download/v0.16.1/docker-machine-Linux-x86_64 -o /usr/local/bin/docker-machine-0.16.1',
        'creates' => '/usr/local/bin/docker-machine-0.16.1',
        'require' => 'Package[curl]',
      )
    }
    it {
      is_expected.to contain_file('/usr/local/bin/docker-machine-0.16.1').with(
        'owner'   => 'root',
        'mode'    => '0755',
        'require' => 'Exec[Install Docker Machine 0.16.1]',
      )
    }
    it {
      is_expected.to contain_file('/usr/local/bin/docker-machine').with(
        'ensure'   => 'link',
        'target'   => '/usr/local/bin/docker-machine-0.16.1',
        'require'  => 'File[/usr/local/bin/docker-machine-0.16.1]',
      )
    }
  end

  context 'with ensure => absent' do
    let(:params) { { ensure: 'absent' } }

    it { is_expected.to contain_file('/usr/local/bin/docker-machine-0.16.1').with_ensure('absent') }
    it { is_expected.to contain_file('/usr/local/bin/docker-machine').with_ensure('absent') }
  end

  context 'when no proxy is provided' do
    let(:params) { { version: '0.16.0' } }

    it {
      is_expected.to contain_exec('Install Docker Machine 0.16.0').with_command(
        'curl -s -S -L  https://github.com/docker/machine/releases/download/v0.16.0/docker-machine-Linux-x86_64 -o /usr/local/bin/docker-machine-0.16.0',
      )
    }
  end

  context 'when proxy is provided' do
    let(:params) do
      { proxy: 'http://proxy.example.org:3128/',
        version: '0.16.0' }
    end

    it { is_expected.to compile }
    it {
      is_expected.to contain_exec('Install Docker Machine 0.16.0').with_command(
        'curl -s -S -L --proxy http://proxy.example.org:3128/ https://github.com/docker/machine/releases/download/v0.16.0/docker-machine-Linux-x86_64 -o /usr/local/bin/docker-machine-0.16.0',
      )
    }
  end

  context 'when proxy is not a http proxy' do
    let(:params) { { proxy: 'this is not a URL' } }

    it do
      expect {
        is_expected.to compile
      }.to raise_error(%r{does not match})
    end
  end

  context 'when proxy contains username and password' do
    let(:params) do
      { proxy: 'http://user:password@proxy.example.org:3128/',
        version: '0.16.0' }
    end

    it { is_expected.to compile }
    it {
      is_expected.to contain_exec('Install Docker Machine 0.16.0').with_command(
        'curl -s -S -L --proxy http://user:password@proxy.example.org:3128/'\
        ' https://github.com/docker/machine/releases/download/v0.16.0/docker-machine-Linux-x86_64'\
        ' -o /usr/local/bin/docker-machine-0.16.0',
      )
    }
  end

  context 'when proxy IP is provided' do
    let(:params) do
      { proxy: 'http://10.10.10.10:3128/',
        version: '0.16.0' }
    end

    it { is_expected.to compile }
    it {
      is_expected.to contain_exec('Install Docker Machine 0.16.0').with_command(
        'curl -s -S -L --proxy http://10.10.10.10:3128/ https://github.com/docker/machine/releases/download/v0.16.0/docker-machine-Linux-x86_64 -o /usr/local/bin/docker-machine-0.16.0',
      )
    }
  end
end
