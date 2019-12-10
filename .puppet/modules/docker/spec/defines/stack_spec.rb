require 'spec_helper'

['Debian', 'Windows'].each do |osfamily|
  describe 'docker::stack', type: :define do
    let(:title) { 'test_stack' }

    if osfamily == 'Debian'
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

    elsif osfamily == 'Windows'
      let(:facts) do
        {
          osfamily: 'windows',
          operatingsystem: 'windows',
          kernelrelease: '10.0.14393',
          operatingsystemmajrelease: '2016',
          docker_program_data_path: 'C:/ProgramData',
          docker_program_files_path: 'C:/Program Files',
          docker_systemroot: 'C:/Windows',
          docker_user_temp_path: 'C:/Users/Administrator/AppData/Local/Temp',
        }
      end

    end

    context 'Create stack with compose file' do
      let(:params) do
        {
          'stack_name' => 'foo',
          'compose_files' => ['/tmp/docker-compose.yaml'],
          'resolve_image' => 'always',
        }
      end

      it { is_expected.to contain_exec('docker stack create foo').with_command(%r{docker stack deploy}) }
      it { is_expected.to contain_exec('docker stack create foo').with_command(%r{--compose-file '\/tmp\/docker-compose.yaml'}) }
    end

    context 'Create stack with multiple compose files' do
      let(:params) do
        {
          'stack_name' => 'foo',
          'compose_files' => ['/tmp/docker-compose.yaml', '/tmp/docker-compose-2.yaml'],
          'resolve_image' => 'always',
        }
      end

      it { is_expected.to contain_exec('docker stack create foo').with_command(%r{docker stack deploy}) }
      it { is_expected.to contain_exec('docker stack create foo').with_command(%r{--compose-file '\/tmp\/docker-compose.yaml'}) }
      it { is_expected.to contain_exec('docker stack create foo').with_command(%r{--compose-file '\/tmp\/docker-compose-2.yaml'}) }
    end

    context 'with prune' do
      let(:params) do
        {
          'stack_name' => 'foo',
          'compose_files' => ['/tmp/docker-compose.yaml'],
          'prune' => true,
        }
      end

      it { is_expected.to contain_exec('docker stack create foo').with_command(%r{docker stack deploy}) }
      it { is_expected.to contain_exec('docker stack create foo').with_command(%r{--compose-file '\/tmp\/docker-compose.yaml'}) }
      it { is_expected.to contain_exec('docker stack create foo').with_command(%r{--prune}) }
    end

    context 'with ensure => absent' do
      let(:params) do
        {
          'ensure' => 'absent',
          'stack_name' => 'foo',
        }
      end

      it { is_expected.to contain_exec('docker stack destroy foo').with_command(%r{docker stack rm}) }
    end
  end
end
