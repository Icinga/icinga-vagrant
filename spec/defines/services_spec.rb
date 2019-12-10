require 'spec_helper'

describe 'docker::services', type: :define do
  let(:title) { 'test_service' }
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

  context 'with ensure => present and service create' do
    let(:params) do
      {
        'create' => true,
        'service_name' => 'foo',
        'image'        => 'foo:bar',
        'publish'      => '80:80',
        'replicas'     => '5',
        'extra_params' => ['--update-delay 1m', '--restart-window 30s'],
        'env'          => ['MY_ENV=1', 'MY_ENV2=2'],
        'label'        => ['com.example.foo="bar"', 'bar=baz'],
        'mounts'       => ['type=bind,src=/tmp/a,dst=/tmp/a', 'type=bind,src=/tmp/b,dst=/tmp/b,readonly'],
        'networks'     => ['overlay'],
        'command'      => 'echo hello world',
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('test_service docker service create').with_command(%r{docker service create}) }
    it { is_expected.to contain_exec('test_service docker service create').with_command(%r{--env MY_ENV=1}) }
    it { is_expected.to contain_exec('test_service docker service create').with_command(%r{--label bar=baz}) }
    it { is_expected.to contain_exec('test_service docker service create').with_command(%r{--mount type=bind,src=\/tmp\/b,dst=\/tmp\/b,readonly}) }
    it { is_expected.to contain_exec('test_service docker service create').with_command(%r{--network overlay}) }
    it { is_expected.to contain_exec('test_service docker service create').with_command(%r{echo hello world}) }

    context 'multiple services declaration' do
      let(:pre_condition) do
        "
        docker::services { 'test_service_2':
          service_name => 'foo_2',
          image        => 'foo:bar',
          command      => ['echo', 'hello', 'world'],
        }
        "
      end

      it { is_expected.to contain_exec('test_service docker service create').with_command(%r{docker service create}) }
      it { is_expected.to contain_exec('test_service_2 docker service create').with_command(%r{docker service create}) }
      it { is_expected.to contain_exec('test_service_2 docker service create').with_command(%r{echo hello world}) }
    end

    context 'multiple publish ports and multiple networks' do
      let(:pre_condition) do
        "
        docker::services { 'test_service_3':
          service_name => 'foo_3',
          image        => 'foo:bar',
          publish      => ['80:8080', '9000:9000' ],
          networks     => ['foo_1', 'foo_2'],
        }
        "
      end

      it { is_expected.to contain_exec('test_service_3 docker service create').with_command(%r{--publish 80:8080}) }
      it { is_expected.to contain_exec('test_service_3 docker service create').with_command(%r{--publish 9000:9000}) }
      it { is_expected.to contain_exec('test_service_3 docker service create').with_command(%r{--network foo_1}) }
      it { is_expected.to contain_exec('test_service_3 docker service create').with_command(%r{--network foo_2}) }
    end
  end

  context 'with ensure => present and service update' do
    let(:params) do
      {
        'create'         => false,
        'update'         => true,
        'service_name'   => 'foo',
        'image'          => 'bar:latest',
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('test_service docker service update').with_command(%r{docker service update}) }
  end

  context 'with ensure => present and service scale' do
    let(:params) do
      {
        'create'         => false,
        'scale'          => true,
        'service_name'   => 'bar',
        'replicas'       => '5',
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('test_service docker service scale').with_command(%r{docker service scale}) }
  end

  context 'with ensure => absent' do
    let(:params) do
      {
        'ensure'         => 'absent',
        'service_name' => 'foo',
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('test_service docker service remove').with_command(%r{docker service rm}) }
  end

  context 'when adding a system user' do
    let(:params) do
      {
        'user' => ['user1'],
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.not_to contain_exec('docker-systemd-reload-before-service') }
  end
end
