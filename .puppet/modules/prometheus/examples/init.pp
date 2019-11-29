include prometheus
include prometheus::node_exporter
include prometheus::alertmanager
include prometheus::alerts
include prometheus::statsd_exporter
include prometheus::process_exporter
include prometheus::blackbox_exporter
include prometheus::beanstalkd_exporter

class { 'prometheus::postgres_exporter' :
  group                => 'postgres',
  user                 => 'postgres',
  postgres_auth_method => 'custom',
  data_source_custom   => {
    'DATA_SOURCE_NAME' => 'user=postgres host=/var/run/postgresql/ sslmode=disable',
  },
}
