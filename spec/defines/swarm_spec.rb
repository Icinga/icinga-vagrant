require 'spec_helper'

['Debian', 'Windows'].each do |osfamily|
  describe 'docker::swarm', type: :define do
    let(:title) { 'create swarm' }

    context "on #{osfamily}" do
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
            osfamily: 'Windows',
            operatingsystem: 'Windows',
            kernelrelease: '10.0.14393',
            operatingsystemmajrelease: '2016',
            docker_program_data_path: 'C:/ProgramData',
            docker_program_files_path: 'C:/Program Files',
            docker_systemroot: 'C:/Windows',
            docker_user_temp_path: 'C:/Users/Administrator/AppData/Local/Temp',
          }
        end

      end

      context 'with ensure => present and swarm init' do
        let(:params) do
          {
            'init' => true,
            'advertise_addr' => '192.168.1.1',
            'listen_addr'    => '192.168.1.1',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_exec('Swarm init').with_command(%r{docker swarm init}) }
      end

      context 'with ensure => present and swarm init and default-addr-pool and default_addr_pool_mask_length' do
        let(:params) do
          {
            'init' => true,
            'advertise_addr'                => '192.168.1.1',
            'listen_addr'                   => '192.168.1.1',
            'default_addr_pool'             => ['30.30.0.0/16', '40.40.0.0/16'],
            'default_addr_pool_mask_length' => '24',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_exec('Swarm init').with_command(%r{docker swarm init}) }
      end

      context 'with ensure => present and swarm join' do
        let(:params) do
          {
            'join'           => true,
            'advertise_addr' => '192.168.1.1',
            'listen_addr'    => '192.168.1.1',
            'token'          => 'foo',
            'manager_ip'     => '192.168.1.2',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_exec('Swarm join').with_command(%r{docker swarm join}) }
      end

      context 'with ensure => absent' do
        let(:params) do
          {
            'ensure'         => 'absent',
            'join'           => true,
            'advertise_addr' => '192.168.1.1',
            'listen_addr'    => '192.168.1.1',
            'token'          => 'foo',
            'manager_ip'     => '192.168.1.2',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_exec('Leave swarm').with_command(%r{docker swarm leave --force}) }
      end
    end
  end
end
