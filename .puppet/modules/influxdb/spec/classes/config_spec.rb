require 'spec_helper'

def esc_regex(v)
  Regexp.new(Regexp.escape(v))
end

describe 'influxdb::config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with default params' do
        let(:pre_condition) do
          <<-EOS
include influxdb
          EOS
        end

        it { is_expected.to contain_class('influxdb') }
        it { is_expected.to contain_class('influxdb::service') }
        it { is_expected.to compile.with_all_deps }
      end

      context 'when Fact[:influxdb_version] = 1.x' do
        let(:facts) do
          facts.merge(influxdb_version: '1.0.0')
        end

        let(:pre_condition) do
          <<-EOS

class { 'influxdb':
  influxd_opts => 'foo bar',
}

          EOS
        end

        describe 'influxdb.conf' do
          let(:conf) { '/etc/influxdb/influxdb.conf' }

          template_data = {
            'global' => {
              'bind-address' => '":8088"',
              'reporting-disabled' => true
            },
            'meta' => {
              'dir' => esc_regex('"/var/lib/influxdb/meta"'),
              'retention-autocreate' => true,
              'logging-enabled'      => true
            },
            'data' => {
              'dir' => esc_regex('"/var/lib/influxdb/data"'),
              'wal-dir'                            => esc_regex('"/var/lib/influxdb/wal"'),
              'trace-logging-enabled'              => false,
              'query-log-enabled'                  => true,
              'cache-max-memory-size'              => 1_048_576_000,
              'cache-snapshot-memory-size'         => 26_214_400,
              'cache-snapshot-write-cold-duration' => esc_regex('"10m"'),
              'compact-full-write-cold-duration'   => esc_regex('"4h"'),
              'max-series-per-database'            => 1_000_000,
              'max-values-per-tag'                 => 100_000
            },
            'coordinator' => {
              'write-timeout' => esc_regex('"10s"'),
              'max-concurrent-queries' => 0,
              'query-timeout'          => esc_regex('"0s"'),
              'log-queries-after'      => esc_regex('"0s"'),
              'max-select-point'       => 0,
              'max-select-series'      => 0,
              'max-select-buckets'     => 0
            },
            'retention' => {
              'enabled'        => true,
              'check-interval' => esc_regex('"30m"')
            },
            'shard_precreation' => {
              'enabled'        => true,
              'check-interval' => esc_regex('"10m"'),
              'advance-period' => esc_regex('"30m"')
            },
            'monitor' => {
              'store-enabled'  => true,
              'store-database' => esc_regex('"_internal"'),
              'store-interval' => esc_regex('"10s"')
            },
            'admin' => {
              'enabled' => false,
              'bind-address'      => esc_regex('":8083"'),
              'https-enabled'     => false,
              'https-certificate' => esc_regex('"/etc/ssl/influxdb.pem"')
            },
            'http' => {
              'enabled'              => true,
              'bind-address'         => esc_regex('":8086"'),
              'auth-enabled'         => false,
              'realm'                => esc_regex('"InfluxDB"'),
              'log-enabled'          => true,
              'write-tracing'        => false,
              'pprof-enabled'        => true,
              'https-enabled'        => false,
              'https-certificate'    => esc_regex('"/etc/ssl/influxdb.pem"'),
              'https-private-key'    => '',
              'shared-sercret'       => '',
              'max-row-limit'        => 0,
              'max-connection-limit' => 0,
              'unix-socket-enabled'  => false,
              'bind-socket'          => esc_regex('"/var/run/influxdb.sock"')
            },
            'subscriber' => {
              'enabled'              => true,
              'http-timeout'         => esc_regex('"30s"'),
              'insecure-skip-verify' => false,
              'ca-certs'             => '""',
              'write-concurrency'    => 40,
              'write-buffer-size'    => 1000
            },
            'continuous' => {
              'enabled' => true,
              'log-enabled'  => true,
              'run-interval' => esc_regex('"1s"')
            }
          }

          toml_section_data = {
            'graphite' => {
              'default' => {
                'enabled'           => false,
                'database'          => esc_regex('"graphite"'),
                'retention-policy'  => '',
                'bind-address'      => esc_regex('":2003"'),
                'protocol'          => esc_regex('"tcp"'),
                'consistency-level' => esc_regex('"one"'),
                'batch-size'        => 5000,
                'batch-pending'     => 10,
                'batch-timeout'     => esc_regex('"1s"'),
                'udp-read-buffer'   => 0,
                'separator'         => esc_regex('"."'),
                'tags'              => esc_regex('[]'),
                'templates'         => esc_regex('[]')
              }
            },
            'collectd' => {
              'default' => {
                'enabled'          => false,
                'bind-address'     => esc_regex('":25826"'),
                'database'         => esc_regex('"collectd"'),
                'retention-policy' => esc_regex('""'),
                'typesdb'          => esc_regex('"/usr/share/collectd/types.db"'),
                'batch-size'       => 5000,
                'batch-pending'    => 10,
                'batch-timeout'    => esc_regex('"10s"'),
                'read-buffer'      => 0
              }
            },
            'opentsdb' => {
              'default' => {
                'enabled'           => false,
                'bind-address'      => esc_regex('":4242"'),
                'database'          => esc_regex('"opentsdb"'),
                'retention-policy'  => esc_regex('""'),
                'consistency-level' => esc_regex('"one"'),
                'tls-enabled'       => false,
                'certificate'       => esc_regex('"/etc/ssl/influxdb.pem"'),
                'log-point-errors'  => true,
                'batch-size'        => 1000,
                'batch-pending'     => 5,
                'batch-timeout'     => esc_regex('"1s"')
              }
            },
            'udp' => {
              'default' => {
                'enabled'          => false,
                'bind-address'     => esc_regex('":8089"'),
                'database'         => esc_regex('"udp"'),
                'retention-policy' => '""',
                'batch-size'       => 5000,
                'batch-pending'    => 10,
                'batch-timeout'    => esc_regex('"1s"'),
                'read-buffer'      => 0
              }
            },
            'hinted_handoff' => {}
          }

          it do
            is_expected.to contain_file(conf).with(ensure: 'file',
                                                   owner: 'root',
                                                   group: 'root',
                                                   mode: '0644')
          end

          template_data.each do |section, section_data|
            describe "Section #{section}" do
              section_data.each do |setting, expectation|
                it { is_expected.to contain_file(conf).with_content(%r{#{setting} = #{expectation}}) }
              end
            end
          end

          toml_section_data.each do |section, toml_data|
            describe "Section #{section}" do
              toml_data.each do |_name, section_data|
                section_data.each do |setting, expectation|
                  it { is_expected.to contain_file(conf).with_content(%r{#{setting} = #{expectation}}) }
                end
              end
            end
          end
        end

        describe 'startup config' do
          let(:startup_conf) do
            if facts[:operatingsystemmajrelease].to_i < 7 && (facts[:osfamily] == 'RedHat')
              '/etc/sysconfig/influxdb'
            else
              '/etc/default/influxdb'
            end
          end

          stderr_expected = esc_regex('/var/log/influxdb/influxd.log')
          stdout_expected = esc_regex('/var/log/influxdb/influxd.log')
          influxd_opts_expected = esc_regex('"foo bar"')

          it do
            is_expected.to contain_file(startup_conf).with(ensure: 'file',
                                                           owner: 'root',
                                                           group: 'root',
                                                           mode: '0644')
          end

          it "STDERR=#{stderr_expected}" do
            is_expected.to contain_file(startup_conf).with_content(%r{STDERR=#{stderr_expected}})
          end

          it "STDOUT=#{stdout_expected}" do
            is_expected.to contain_file(startup_conf).with_content(%r{STDOUT=#{stdout_expected}})
          end

          it "INFLUXD_OPTS=#{influxd_opts_expected}" do
            is_expected.to contain_file(startup_conf).with_content(%r{INFLUXD_OPTS=#{influxd_opts_expected}})
          end
        end
      end
    end
  end
end
