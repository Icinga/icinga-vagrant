require 'spec_helper'

describe 'docker', type: :class do
  osfamily = 'windows'
  context "on #{osfamily}" do
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
    let(:params) { { 'docker_ee' => true } }
    let(:service_config_file) { 'C:/ProgramData/docker/config/daemon.json' }

    it { is_expected.to compile.with_all_deps }
    it {
      is_expected.to contain_file('C:/ProgramData/docker/').with('ensure' => 'directory')
    }
    it { is_expected.to contain_file('C:/ProgramData/docker/config/') }
    it { is_expected.to contain_exec('service-restart-on-failure') }
    it { is_expected.to contain_exec('install-docker-package').with_command(%r{Install-PackageProvider NuGet -Force}) }
    it { is_expected.to contain_exec('install-docker-package').with_command(%r{Install-Module \$dockerProviderName -Force}) }
    it { is_expected.to contain_class('docker::repos').that_comes_before('Class[docker::install]') }
    it { is_expected.to contain_class('docker::install').that_comes_before('Class[docker::config]') }
    it { is_expected.to contain_class('docker::config').that_comes_before('Class[docker::service]') }

    it { is_expected.to contain_file(service_config_file).without_content(%r{icc=}) }

    context 'with dns' do
      let(:params) do
        {
          'dns' => '8.8.8.8',
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"dns": \["8.8.8.8"\],}) }
    end

    context 'with multi dns' do
      let(:params) do
        {
          'dns' => ['8.8.8.8', '8.8.4.4'],
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"dns": \["8.8.8.8","8.8.4.4"\],}) }
    end

    context 'with dns search' do
      let(:params) do
        {
          'dns_search' => ['my.domain.local'],
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"dns-search": \["my.domain.local"\],}) }
    end

    context 'with multi dns search' do
      let(:params) do
        {
          'dns_search' => ['my.domain.local', 'other-domain.de'],
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"dns-search": \["my.domain.local","other-domain.de"\],}) }
    end

    context 'with log_driver' do
      let(:params) do
        {
          'log_driver' => 'etwlogs',
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"log-driver": "etwlogs"}) }
    end

    context 'with invalid log_driver' do
      let(:params) do
        {
          'log_driver' => 'invalid',
          'docker_ee' => true,
        }
      end

      it do
        expect {
          is_expected.to contain_package('docker')
        }.to raise_error(Puppet::Error, %r{log_driver must be one of none, json-file, syslog, gelf, fluentd, splunk, awslogs or etwlogs})
      end
    end

    context 'with invalid journald log_driver' do
      let(:params) do
        {
          'log_driver' => 'journald',
          'docker_ee' => true,
        }
      end

      it do
        expect {
          is_expected.to contain_package('docker')
        }.to raise_error(Puppet::Error, %r{log_driver must be one of none, json-file, syslog, gelf, fluentd, splunk, awslogs or etwlogs})
      end
    end

    context 'with mtu' do
      let(:params) do
        {
          'mtu' => '1450',
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"mtu": 1450}) }
    end

    context 'with log_level' do
      let(:params) do
        {
          'log_level' => 'debug',
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"log-level": "debug"}) }
    end

    context 'with invalid log_level' do
      let(:params) do
        {
          'log_level' => 'verbose',
          'docker_ee' => true,
        }
      end

      it do
        expect {
          is_expected.to contain_package('docker')
        }.to raise_error(Puppet::Error, %r{log_level must be one of debug, info, warn, error or fatal})
      end
    end

    context 'with storage_driver' do
      let(:params) do
        {
          'storage_driver' => 'windowsfilter',
          'docker_ee' => true,
        }
      end

      it { is_expected.to compile.with_all_deps }
    end

    context 'with an invalid storage_driver' do
      let(:params) do
        {
          'storage_driver' => 'invalid',
          'docker_ee' => true,
        }
      end

      it do
        expect {
          is_expected.to contain_package('docker')
        }.to raise_error(Puppet::Error, %r{Valid values for storage_driver on windows are windowsfilter})
      end
    end

    context 'with tcp_bind' do
      let(:params) do
        {
          'tcp_bind' => 'tcp://0.0.0.0:2376',
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"hosts": \["tcp:\/\/0.0.0.0:2376"\]}) }
    end

    context 'with multiple tcp_bind' do
      let(:params) do
        {
          'tcp_bind' => ['tcp://0.0.0.0:2376', 'npipe://'],
          'docker_ee'  => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"hosts": \["tcp:\/\/0.0.0.0:2376","npipe:\/\/"\]}) }
    end

    context 'with tls_enable, tcp_bind and tls configuration' do
      let(:params) do
        {
          'tls_enable' => true,
          'tcp_bind'   => ['tcp://0.0.0.0:2376'],
          'docker_ee'  => true,
        }
      end

      it {
        is_expected.to contain_file(service_config_file).with_content(
          %r{"hosts": \["tcp:\/\/0.0.0.0:2376"]},
        ).with_content(
          %r{"tlsverify": true},
        ).with_content(
          %r{"tlscacert": "C:\/ProgramData\/docker\/certs.d\/ca.pem"},
        ).with_content(
          %r{"tlscert": "C:\/ProgramData\/docker\/certs.d\/server-cert.pem"},
        ).with_content(
          %r{"tlskey": "C:\/ProgramData\/docker\/certs.d\/server-key.pem"},
        )
      }
    end

    context 'with tls_enable, tcp_bind and custom tls cacert' do
      let(:params) do
        {
          'tls_enable' => true,
          'tcp_bind'   => ['tcp://0.0.0.0:2376'],
          'tls_cacert' => 'C:/certs/ca.pem',
          'docker_ee'  => true,
        }
      end

      it {
        is_expected.to contain_file(service_config_file).with_content(
          %r{"tlscacert": "C:\/certs\/ca.pem"},
        )
      }
    end

    context 'with tls_enable, tcp_bind and custom tls cert' do
      let(:params) do
        {
          'tls_enable' => true,
          'tcp_bind'   => ['tcp://0.0.0.0:2376'],
          'tls_cert'   => 'C:/certs/server-cert.pem',
          'docker_ee'  => true,
        }
      end

      it {
        is_expected.to contain_file(service_config_file).with_content(
          %r{"tlscert": "C:\/certs\/server-cert.pem"},
        )
      }
    end

    context 'with tls_enable, tcp_bind and custom tls key' do
      let(:params) do
        {
          'tls_enable' => true,
          'tcp_bind' => ['tcp://0.0.0.0:2376'],
          'tls_key' => 'C:/certs/server-key.pem',
          'docker_ee' => true,
        }
      end

      it {
        is_expected.to contain_file(service_config_file).with_content(
          %r{"tlskey": "C:\/certs\/server-key.pem"},
        )
      }
    end

    context 'with custom socket group' do
      let(:params) do
        {
          'socket_group' => 'custom',
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"group": "custom"}) }
    end

    context 'with custom bridge' do
      let(:params) do
        {
          'bridge' => 'l2bridge',
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"bridge": "l2bridge"}) }
    end

    context 'with invalid bridge' do
      let(:params) do
        {
          'bridge' => 'invalid',
          'docker_ee' => true,
        }
      end

      it do
        expect {
          is_expected.to contain_package('docker')
        }.to raise_error(Puppet::Error, %r{bridge must be one of none, nat, transparent, overlay, l2bridge or l2tunnel on Windows.})
      end
    end

    context 'with custom fixed cidr' do
      let(:params) do
        {
          'fixed_cidr' => '10.0.0.0/24',
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"fixed-cidr": "10.0.0.0\/24"}) }
    end

    context 'with custom registry mirror' do
      let(:params) do
        {
          'registry_mirror' => 'https://mirror.gcr.io',
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"registry-mirrors": \["https:\/\/mirror.gcr.io"\]}) }
    end

    context 'with custom label' do
      let(:params) do
        {
          'labels' => ['mylabel'],
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_file(service_config_file).with_content(%r{"labels": \["mylabel"\]}) }
    end

    context 'with default package name' do
      let(:params) do
        {
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_exec('install-docker-package').with_command(%r{ Docker }) }
    end

    context 'with custom package name' do
      let(:params) do
        {
          'docker_ee_package_name' => 'mydockerpackage',
          'docker_ee' => true,
        }
      end

      it { is_expected.to contain_exec('install-docker-package').with_command(%r{ mydockerpackage }) }
    end

    context 'without docker_ee' do
      let(:params) { { 'docker_ee' => false } }

      it do
        expect {
          is_expected.to contain_package('docker')
        }.to raise_error(Puppet::Error, %r{This module only work for Docker Enterprise Edition on Windows.})
      end
    end
  end
end
