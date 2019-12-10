require 'spec_helper'

describe 'docker::run', type: :define do
  let(:title) { 'sample' }
  let(:pre_condition) { 'class { \'docker\': docker_ee => true }' }
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

  context 'with restart policy set to no' do
    let(:params) { { 'restart' => 'no', 'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4' } }

    it { is_expected.to contain_exec('run sample with docker') }
    it { is_expected.to contain_exec('run sample with docker').with_unless(%r{sample}) }
    it { is_expected.to contain_exec('run sample with docker').with_unless(%r{inspect}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{--cidfile=C:\/Users\/Administrator\/AppData\/Local\/Temp\/docker-sample.cid}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{-c 4}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{--restart="no"}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{base command}) }
    it { is_expected.to contain_exec('run sample with docker').with_timeout(3000) }
  end

  context 'with restart policy set to always' do
    let(:params) { { 'restart' => 'always', 'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4' } }

    it { is_expected.to contain_exec('run sample with docker') }
    it { is_expected.to contain_exec('run sample with docker').with_unless(%r{sample}) }
    it { is_expected.to contain_exec('run sample with docker').with_unless(%r{inspect}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{--cidfile=C:\/Users\/Administrator\/AppData\/Local\/Temp\/docker-sample.cid}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{-c 4}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{--restart="always"}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{base command}) }
    it { is_expected.to contain_exec('run sample with docker').with_timeout(3000) }
    it { is_expected.to contain_exec('start sample with docker').with_command(%r{docker start sample}) }
  end

  context 'with restart policy set to on-failure' do
    let(:params) { { 'restart' => 'on-failure', 'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4' } }

    it { is_expected.to contain_exec('run sample with docker') }
    it { is_expected.to contain_exec('run sample with docker').with_unless(%r{sample}) }
    it { is_expected.to contain_exec('run sample with docker').with_unless(%r{inspect}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{--cidfile=C:\/Users\/Administrator\/AppData\/Local\/Temp\/docker-sample.cid}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{-c 4}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{--restart="on-failure"}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{base command}) }
    it { is_expected.to contain_exec('run sample with docker').with_timeout(3000) }
  end

  context 'with restart policy set to on-failure:3' do
    let(:params) { { 'restart' => 'on-failure:3', 'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4' } }

    it { is_expected.to contain_exec('run sample with docker') }
    it { is_expected.to contain_exec('run sample with docker').with_unless(%r{sample}) }
    it { is_expected.to contain_exec('run sample with docker').with_unless(%r{inspect}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{--cidfile=C:\/Users\/Administrator\/AppData\/Local\/Temp\/docker-sample.cid}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{-c 4}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{--restart="on-failure:3"}) }
    it { is_expected.to contain_exec('run sample with docker').with_command(%r{base command}) }
    it { is_expected.to contain_exec('run sample with docker').with_timeout(3000) }
  end

  context 'with ensure absent' do
    let(:params) { { 'ensure' => 'absent', 'command' => 'command', 'image' => 'base' } }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('stop container docker-sample').with_command('docker stop --time=0 sample') }
    it { is_expected.to contain_exec('remove container docker-sample').with_command('docker rm -v sample') }
    it { is_expected.not_to contain_file('C:/Users/Administrator/AppData/Local/Temp/docker-sample.cid"') }
  end

  context 'with ensure absent and restart policy' do
    let(:params) { { 'ensure' => 'absent', 'command' => 'command', 'image' => 'base', 'restart' => 'always' } }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('stop sample with docker').with_command('docker stop --time=0 sample') }
    it { is_expected.to contain_exec('remove sample with docker').with_command('docker rm -v sample') }
    it { is_expected.not_to contain_file('C:/Users/Administrator/AppData/Local/Temp/docker-sample.cid"') }
  end

  context 'with ensure present and running false' do
    let(:params) { { 'ensure' => 'present', 'image' => 'base', 'restart' => 'always', 'running' => false } }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('stop sample with docker').with_command('docker stop --time=0 sample') }
  end

  context 'with ensure present and no restart policy' do
    let(:params) { { 'ensure' => 'present', 'image' => 'base' } }

    it do
      expect {
        is_expected.not_to contain_file('C:/Users/Administrator/AppData/Local/Temp/docker-sample.cid"')
      }.to raise_error(Puppet::Error)
    end
  end
end
