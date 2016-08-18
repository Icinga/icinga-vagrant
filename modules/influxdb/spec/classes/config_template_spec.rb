require 'spec_helper'

describe 'influxdb::server', :type => :class do

  default = {
    'meta_bind_address' => ':8088',
    'meta_http_bind_address' => ':8091',
    'retention_autocreate' => true,
    'election_timeout' => '1s',
    'heartbeat_timeout' => '1s',
    'leader_lease_timeout' => '500ms',
    'commit_timeout' => '50ms',
    'data_dir' => '/var/opt/influxdb/data',
    'max_wal_size' => 104857600,
    'wal_flush_interval' => '10m',
    'wal_partition_flush_delay' => '2s',
    'shard_writer_timeout' => '5s',
    'cluster_write_timeout' => '5s',
    'retention_enabled' => true,
    'retention_check_interval' => '10m',
    'admin_enabled' => true,
    'admin_bind_address' => ':8083',
    'admin_https_enabled' => false,
    'admin_https_certificate' => '/etc/ssl/influxdb.pem',
    'http_enabled' => true,
    'http_bind_address' => ':8086',
    'http_auth_enabled' => false,
    'http_log_enabled' => true,
    'http_write_tracing' => false,
    'http_pprof_enabled' => false,
    'http_https_enabled' => false,
    'http_https_certificate' => '/etc/ssl/influxdb.pem',
    'monitoring_enabled' => true,
    'monitoring_database' => '_internal',
    'monitoring_write_interval' => '24h',
    'continuous_queries_enabled' => true,
    'hinted_handoff_enabled' => true,
    'hinted_handoff_dir' => '/var/opt/influxdb/hh',
    'hinted_handoff_max_size' => 1073741824,
    'hinted_handoff_max_age' => '168h',
    'hinted_handoff_retry_rate_limit' => 0,
    'hinted_handoff_retry_interval' => '1s',
    'reporting_disabled' => false,
    'conf_template' => 'influxdb/influxdb.conf.erb',
    'config_file' => '/etc/opt/influxdb/influxdb.conf',
    'enable_snapshot' => false,
    'influxdb_stderr_log' => '/var/log/influxdb/influxd.log',
    'influxdb_stdout_log' => '/dev/null'

  }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to contain_file('/etc/influxdb/influxdb.conf') }
      it { is_expected.to contain_file('/etc/influxdb/influxdb.conf').with_content(/bind-address = ":8088"/) }
      it { is_expected.to contain_file('/etc/influxdb/influxdb.conf').with_content(/http-bind-address = ":8091"/) }
      it { is_expected.to contain_file('/etc/influxdb/influxdb.conf').with_content(/commit-timeout = "50ms"/) }

      case facts[:osfamily]
      when 'Debian'
        let (:params) {{
          :retention_check_interval => '20m',
          :collectd_options => {
            'enabled' => true,
            'batch-size' => 5000,
          }
        }}

        it { is_expected.to contain_file('/etc/influxdb/influxdb.conf') }
        it { is_expected.to contain_file('/etc/influxdb/influxdb.conf').with_content(/bind-address = ":8088"/) }
        it { is_expected.to contain_file('/etc/influxdb/influxdb.conf').with_content(/check-interval = "20m"/) }
        it { is_expected.to contain_file('/etc/influxdb/influxdb.conf').with_content(/wal-dir = "\/var\/lib\/influxdb\/wal"/) }
        it { is_expected.to contain_file('/etc/influxdb/influxdb.conf').with_content(/batch-size = 5000/) }
      end

    end
  end

end
