require 'spec_helper'

describe 'prometheus' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      [{ manage_prometheus_server: true, version: '2.0.0-rc.1', bin_dir: '/usr/local/bin', install_method: 'url', rule_files: ['/etc/prometheus/rules.d/*.rules'] }].each do |parameters|
        context "with parameters #{parameters}" do
          let(:params) do
            parameters
          end

          # prometheus::install
          it {
            is_expected.to contain_file('/var/lib/prometheus').with(
              'ensure' => 'directory',
              'owner'  => 'prometheus',
              'group'  => 'prometheus',
              'mode'   => '0755'
            )
          }

          prom_version = parameters[:version] || '1.5.2'
          prom_major = prom_version[0]
          prom_os = facts[:kernel].downcase
          prom_arch = facts[:architecture] == 'i386' ? '386' : 'amd64'

          it {
            is_expected.to contain_archive("/tmp/prometheus-#{prom_version}.tar.gz").with(
              'ensure' => 'present',
              'extract' => true,
              'extract_path' => '/opt',
              'source' => "https://github.com/prometheus/prometheus/releases/download/v#{prom_version}/prometheus-#{prom_version}.#{prom_os}-#{prom_arch}.tar.gz",
              'checksum_verify' => false,
              'creates' => "/opt/prometheus-#{prom_version}.#{prom_os}-#{prom_arch}/prometheus",
              'cleanup' => true
            ).that_comes_before("File[/opt/prometheus-#{prom_version}.#{prom_os}-#{prom_arch}/prometheus]")
          }

          it {
            is_expected.to contain_file("/opt/prometheus-#{prom_version}.#{prom_os}-#{prom_arch}/prometheus").with(
              'owner'  => 'root',
              'group'  => 0,
              'mode'   => '0555'
            )
          }

          it {
            is_expected.to contain_file('/usr/local/bin/prometheus').with(
              'ensure' => 'link',
              'target' => "/opt/prometheus-#{prom_version}.#{prom_os}-#{prom_arch}/prometheus"
            ).that_notifies('Service[prometheus]')
          }

          it {
            is_expected.to contain_file('/usr/local/share/prometheus').with(
              'ensure'  => 'directory',
              'owner'   => 'prometheus',
              'group'   => 'prometheus',
              'mode'    => '0755'
            )
          }

          it {
            is_expected.to contain_file('/usr/local/share/prometheus/consoles').with(
              'ensure' => 'link',
              'target' => "/opt/prometheus-#{prom_version}.#{prom_os}-#{prom_arch}/consoles"
            ).that_notifies('Service[prometheus]')
          }

          it {
            is_expected.to contain_file('/usr/local/share/prometheus/console_libraries').with(
              'ensure' => 'link',
              'target' => "/opt/prometheus-#{prom_version}.#{prom_os}-#{prom_arch}/console_libraries"
            ).that_notifies('Service[prometheus]')
          }

          it {
            is_expected.to contain_user('prometheus').with(
              'ensure' => 'present',
              'system' => true,
              'groups' => []
            )
          }

          it {
            is_expected.to contain_group('prometheus').with(
              'ensure' => 'present',
              'system' => true
            )
          }

          # prometheus::config
          if ['debian-7-x86_64'].include?(os)
            # init_style = 'debian'

            it {
              is_expected.to contain_file('/etc/init.d/prometheus').with(
                'mode'   => '0555',
                'owner'  => 'root',
                'group'  => 'root',
                'content' => File.read(fixtures('files', "prometheus#{prom_major}.debian"))
              )
            }
          elsif ['centos-6-x86_64', 'redhat-6-x86_64'].include?(os)
            # init_style = 'sysv'

            it {
              is_expected.to contain_file('/etc/init.d/prometheus').with(
                'mode'   => '0555',
                'owner'  => 'root',
                'group'  => 'root',
                'content' => File.read(fixtures('files', "prometheus#{prom_major}.sysv"))
              )
            }
          elsif ['centos-7-x86_64', 'centos-8-x86_64', 'debian-8-x86_64', 'debian-9-x86_64', 'redhat-7-x86_64', 'redhat-8-x86_64', 'ubuntu-16.04-x86_64', 'ubuntu-18.04-x86_64', 'archlinux-5-x86_64'].include?(os)
            # init_style = 'systemd'

            it {
              is_expected.to contain_class('systemd')
            }

            it {
              is_expected.to contain_systemd__unit_file('prometheus.service').with(
                'content' => File.read(fixtures('files', "prometheus#{prom_major}.systemd"))
              )
            }
            describe 'max_open_files' do
              context 'by default' do
                it {
                  content = catalogue.resource('systemd::unit_file', 'prometheus.service').send(:parameters)[:content]
                  expect(content).not_to include('LimitNOFILE')
                }
              end
              context 'when set to 1000000' do
                let(:params) do
                  parameters.merge('max_open_files' => 1_000_000)
                end

                it {
                  content = catalogue.resource('systemd::unit_file', 'prometheus.service').send(:parameters)[:content]
                  expect(content).to include('LimitNOFILE=1000000')
                }
              end
            end
          elsif ['ubuntu-14.04-x86_64'].include?(os)
            # init_style = 'upstart'

            it {
              is_expected.to contain_file('/etc/init/prometheus.conf').with(
                'mode'    => '0444',
                'owner'   => 'root',
                'group'   => 'root',
                'content' => File.read(fixtures('files', "prometheus#{prom_major}.upstart"))
              )
            }

            it {
              is_expected.to contain_file('/etc/init.d/prometheus').with(
                'ensure' => 'link',
                'target' => '/lib/init/upstart-job',
                'owner' => 'root',
                'group' => 'root',
                'mode'  => '0755'
              )
            }
          else
            it {
              is_expected.to raise_error(Puppet::Error, %r{I don't know how to create an init script for style})
            }
          end

          it {
            is_expected.to contain_file('/etc/prometheus').with(
              'ensure'  => 'directory',
              'owner'   => 'root',
              'group'   => 'prometheus',
              'purge'   => true,
              'recurse' => true
            )
          }

          it {
            is_expected.to contain_file('prometheus.yaml').with(
              'ensure'  => 'file',
              'path'    => '/etc/prometheus/prometheus.yaml',
              'owner'   => 'root',
              'group'   => 'prometheus',
              'mode'    => '0640',
              'content' => File.read(fixtures('files', "prometheus#{prom_major}.yaml"))
            ).that_notifies('Class[prometheus::service_reload]')
          }

          # prometheus::alerts
          it {
            is_expected.not_to contain_file('/etc/prometheus/alert.rules')
          }

          # prometheus::run_service
          it {
            is_expected.to contain_service('prometheus').with(
              'ensure'     => 'running',
              'name'       => 'prometheus',
              'enable'     => true
            )
          }

          # prometheus::service_reload
          it {
            is_expected.to contain_exec('prometheus-reload').with(
              # 'command'     => 'systemctl reload prometheus',
              'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
              'refreshonly' => true
            )
          }
        end
      end

      context 'with alerts configured', alerts: true do
        [
          {
            manage_prometheus_server: true,
            version: '1.5.3',
            alerts: [{
              'name'         => 'alert_name',
              'condition'    => 'up == 0',
              'timeduration' => '5min',
              'labels'       => [{ 'name' => 'severity', 'content' => 'woops' }],
              'annotations'  => [{ 'name' => 'summary', 'content' => 'did a woops {{ $labels.instance }}' }]
            }]
          },
          {
            manage_prometheus_server: true,
            version: '2.0.0-rc.1',
            alerts: {
              'groups' => [{
                'name' => 'alert.rules',
                rules: [
                  {
                    'alert'       => 'alert_name',
                    'expr'        => 'up == 0',
                    'for'         => '5min',
                    'labels'      => { 'severity' => 'woops' },
                    'annotations' => {
                      'summary' => 'did a woops {{ $labels.instance }}'
                    }
                  }
                ]
              }]
            }
          }
        ].each do |parameters|
          context "with prometheus version #{parameters[:version]}" do
            let(:params) do
              parameters
            end

            prom_version = parameters[:version]
            prom_major = prom_version[0]

            it {
              is_expected.to compile
            }
            it {
              is_expected.to contain_file('/etc/prometheus/alert.rules').with(
                'ensure'  => 'file',
                'owner'   => 'root',
                'group'   => 'prometheus',
                'content' => File.read(fixtures('files', "prometheus#{prom_major}.alert.rules"))
              ).that_notifies('Class[prometheus::service_reload]')
            }
          end
        end
      end

      context 'with remote write configured' do
        [
          {
            manage_prometheus_server: true,
            version: '2.0.0-rc.1',
            remote_write_configs: [
              'url' => 'http://domain.tld/path'
            ]
          }
        ].each do |parameters|
          context "with prometheus version #{parameters[:version]}" do
            let(:params) do
              parameters
            end

            it {
              is_expected.to compile
            }
            it {
              is_expected.to contain_file('prometheus.yaml').with(
                'ensure'  => 'file',
                'path'    => '/etc/prometheus/prometheus.yaml',
                'owner'   => 'root',
                'group'   => 'prometheus',
                'content' => %r{http://domain.tld/path}
              )
            }
          end
        end
      end

      context 'with manage_config => false' do
        [
          {
            version: '1.5.3',
            manage_config: false
          },
          {
            version: '2.0.0-rc.1',
            manage_config: false
          }
        ].each do |parameters|
          context "with prometheus verions #{parameters[:version]}" do
            let(:params) do
              parameters
            end

            it {
              is_expected.not_to contain_file('/etc/prometheus/prometheus.yaml')
            }
          end
        end
      end
      context 'command-line flags' do
        context 'prometheus v2' do
          version = '2.13.0'
          context 'with all valid params' do
            let(:params) do
              {
                manage_prometheus_server: true,
                version: version,
                init_style: 'systemd',
                bin_dir: '/usr/local/bin',
                config_dir: '/etc/prometheus',
                configname: 'prometheus_123.yaml',
                shared_dir: '/opt/prometheus',
                external_url: 'https://prometheus.reverse-proxy.company.systems',
                web_listen_address: '127.0.0.1:9099',
                web_read_timeout: '2m',
                web_max_connections: '256',
                web_route_prefix: 'internal',
                web_user_assets: 'static',
                web_enable_lifecycle: true,
                web_enable_admin_api: true,
                web_page_title: 'My Company Prometheus',
                web_cors_origin: 'https?://(domain1|domain2)\.com',
                localstorage: '/opt/prometheus/data/',
                storage_retention: '14d',
                storage_retention_size: '50GB',
                storage_no_lockfile: true,
                storage_allow_overlapping_blocks: true,
                storage_wal_compression: true,
                storage_flush_deadline: '5m',
                storage_read_sample_limit: '5e8',
                storage_read_concurrent_limit: '8',
                storage_read_max_bytes_in_frame: '1000000',
                alert_for_outage_tolerance: '25m',
                alert_for_grace_period: '3m',
                alert_resend_delay: '2m',
                alertmanager_notification_queue_capacity: '10000',
                alertmanager_timeout: '10s',
                query_lookback_delta: '5m',
                query_timeout: '2m',
                query_max_concurrency: '30',
                query_max_samples: '10000000',
                log_level: 'info',
                log_format: 'json'
              }
            end

            it {
              is_expected.to contain_file('/etc/systemd/system/prometheus.service').with(
                'ensure'  => 'file',
                'mode'    => '0444',
                'owner'   => 'root',
                'group'   => 'root',
                'content' => File.read(fixtures('files/cli', 'prometheus2_all.systemd'))
              )
            }
          end
          context 'with extra args write-in' do
            let(:params) do
              {
                manage_prometheus_server: true,
                version: version,
                init_style: 'systemd',
                bin_dir: '/usr/local/bin',
                extra_options: '--web.enable-admin-api'
              }
            end

            it {
              is_expected.to contain_file('/etc/systemd/system/prometheus.service').with(
                'ensure'  => 'file',
                'mode'    => '0444',
                'owner'   => 'root',
                'group'   => 'root',
                'content' => File.read(fixtures('files/cli', 'prometheus2_extra.systemd'))
              )
            }
          end
        end
        context 'prometheus v2.6' do
          context 'with storage retention time' do
            let(:params) do
              {
                manage_prometheus_server: true,
                version: '2.6.0',
                init_style: 'systemd',
                bin_dir: '/usr/local/bin',
                storage_retention: '14d'
              }
            end

            it {
              is_expected.to contain_file('/etc/systemd/system/prometheus.service').with(
                'ensure'  => 'file',
                'mode'    => '0444',
                'owner'   => 'root',
                'group'   => 'root',
                'content' => File.read(fixtures('files/cli', 'prometheus2_6_retention.systemd'))
              )
            }
          end
        end
        context 'prometheus v1' do
          version = '1.7.0'
          context 'with extra args write-in' do
            let(:params) do
              {
                manage_prometheus_server: true,
                version: version,
                init_style: 'systemd',
                bin_dir: '/usr/local/bin',
                extra_options: '-web.telemetry-path=/metrics'
              }
            end

            it {
              is_expected.to contain_file('/etc/systemd/system/prometheus.service').with(
                'ensure'  => 'file',
                'mode'    => '0444',
                'owner'   => 'root',
                'group'   => 'root',
                'content' => File.read(fixtures('files/cli', 'prometheus1_extra.systemd'))
              )
            }
          end
          context 'with all valid params' do
            let(:params) do
              {
                manage_prometheus_server: true,
                version: version,
                init_style: 'systemd',
                bin_dir: '/usr/local/bin',
                config_dir: '/etc/prometheus',
                configname: 'prometheus_123.yaml',
                shared_dir: '/opt/prometheus',
                external_url: 'https://prometheus.reverse-proxy.company.systems',
                web_listen_address: '127.0.0.1:9099',
                web_read_timeout: '2m',
                web_max_connections: '256',
                web_route_prefix: 'internal',
                web_user_assets: 'static',
                web_telemetry_path: '/telemetry',
                web_enable_remote_shutdown: true,
                localstorage: '/opt/prometheus/data/',
                storage_retention: '14d',
                alertmanager_notification_queue_capacity: '10000',
                alertmanager_timeout: '10s',
                alertmanager_url: 'https://alertmanager.company.systems',
                query_timeout: '2m',
                query_max_concurrency: '30',
                query_staleness_delta: '5m',
                log_level: 'fatal'
              }
            end

            it {
              is_expected.to contain_file('/etc/systemd/system/prometheus.service').with(
                'ensure'  => 'file',
                'mode'    => '0444',
                'owner'   => 'root',
                'group'   => 'root',
                'content' => File.read(fixtures('files/cli', 'prometheus1_all.systemd'))
              )
            }
          end
        end
      end
    end
  end
end
