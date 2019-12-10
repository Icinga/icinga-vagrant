require 'spec_helper'

describe 'docker::exec', type: :define do
  let(:title) { 'sample' }
  let(:facts) do
    {
      architecture: 'amd64',
      osfamily: 'windows',
      operatingsystem: 'windows',
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

  context 'when running detached' do
    let(:params) { { 'command' => 'command', 'container' => 'container', 'detach' => true } }

    it { is_expected.to contain_exec('docker exec --detach=true container command') }
  end

  context 'when running with tty' do
    let(:params) { { 'command' => 'command', 'container' => 'container', 'tty' => true } }

    it { is_expected.to contain_exec('docker exec --tty=true container command') }
  end

  context 'when running with interactive' do
    let(:params) { { 'command' => 'command', 'container' => 'container', 'interactive' => true } }

    it { is_expected.to contain_exec('docker exec --interactive=true container command') }
  end

  context 'when running with onlyif "running"' do
    let(:params) { { 'command' => 'command', 'container' => 'container', 'interactive' => true, 'onlyif' => 'running' } }

    it { is_expected.to contain_exec('docker exec --interactive=true container command').with_onlyif 'docker ps --no-trunc --format=\'table {{.Names}}\' | grep \'^container$\'' }
  end

  context 'when running without onlyif custom command' do
    let(:params) { { 'command' => 'command', 'container' => 'container', 'interactive' => true, 'onlyif' => 'custom' } }

    it { is_expected.to contain_exec('docker exec --interactive=true container command').with_onlyif 'custom' }
  end

  context 'when running without onlyif' do
    let(:params) { { 'command' => 'command', 'container' => 'container', 'interactive' => true } }

    it { is_expected.to contain_exec('docker exec --interactive=true container command').with_onlyif nil }
  end

  context 'when running with unless' do
    let(:params) { { 'command' => 'command', 'container' => 'container', 'interactive' => true, 'unless' => 'some_command arg1' } }

    it { is_expected.to contain_exec('docker exec --interactive=true container command').with_unless 'docker exec --interactive=true container some_command arg1' }
  end

  context 'when running without unless' do
    let(:params) { { 'command' => 'command', 'container' => 'container', 'interactive' => true } }

    it { is_expected.to contain_exec('docker exec --interactive=true container command').with_unless nil }
  end

  context 'with title that need sanitisation' do
    let(:params) { { 'command' => 'command', 'container' => 'container_sample/1', 'detach' => true, 'sanitise_name' => true } }

    it { is_expected.to contain_exec('docker exec --detach=true container_sample-1 command') }
  end
end
