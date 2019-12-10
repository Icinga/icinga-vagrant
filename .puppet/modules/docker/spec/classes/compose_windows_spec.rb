require 'spec_helper'

describe 'docker::compose', type: :class do
  let(:facts) do
    {
      architecture: 'amd64',
      osfamily: 'windows',
      operatingsystem: 'windows',
      kernel: 'windows',
      kernelrelease: '10.0.14393',
      operatingsystemrelease: '2016',
      operatingsystemmajrelease: '2016',
      docker_program_data_path: 'C:/ProgramData',
      docker_program_files_path: 'C:/Program Files',
      docker_systemroot: 'C:/Windows',
      docker_user_temp_path: 'C:/Users/Administrator/AppData/Local/Temp',
      os: { family: 'windows', name: 'windows', release: { major: '2016', full: '2016' } },
    }
  end

  it { is_expected.to compile }

  context 'with defaults for all parameters' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_file('C:/Program Files/Docker/docker-compose.exe').with(
        'ensure'   => 'link',
        'target'   => 'C:/Program Files/Docker/docker-compose-1.21.2.exe',
        'require'  => 'Exec[Install Docker Compose 1.21.2]',
      )
    }
  end

  context 'with ensure => absent' do
    let(:params) { { ensure: 'absent' } }

    it { is_expected.to contain_file('C:/Program Files/Docker/docker-compose-1.21.2.exe').with_ensure('absent') }
    it { is_expected.to contain_file('C:/Program Files/Docker/docker-compose.exe').with_ensure('absent') }
  end

  context 'when no proxy is provided' do
    let(:params) { { version: '1.7.0' } }

    it { is_expected.to contain_exec('Install Docker Compose 1.7.0') }
  end

  context 'when proxy is provided' do
    let(:params) do
      { proxy: 'http://proxy.example.org:3128/',
        version: '1.7.0' }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0') }
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
        version: '1.7.0' }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0') }
  end

  context 'when proxy IP is provided' do
    let(:params) do
      { proxy: 'http://10.10.10.10:3128/',
        version: '1.7.0' }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0') }
  end
end
