node default {
  class { '::profiles::base::system': }
  ->
  class { '::profiles::base::mysql': }
  ->
  class { '::profiles::base::apache': }
  ->
  class { '::profiles::icinga::icinga2':
    node_name => lookup('icinga::icinga2::node_name'),
    features => {
      "influxdb" => {
        "listen_ip"   => lookup('influxdb::server::listen_ip'),
        "listen_port" => lookup('influxdb::server::listen_port')
      }
    }
  }
  ->
  class { '::profiles::icinga::icingaweb2':
    icingaweb2_listen_ip => lookup('icinga::icingaweb2::listen_ip'),
    icingaweb2_fqdn => lookup('icinga::icingaweb2::fqdn'),
    node_name => lookup('icinga::icinga2::node_name'),
    modules => {
      "grafana" => {
        "datasource"  => "influxdb",
        "listen_ip"   => lookup('grafana::server::listen_ip'),
        "listen_port" => lookup('grafana::server::listen_port')
      }
    }
  }
  ->
  class { '::profiles::influxdb::server':
  }
  ->
  class { '::profiles::grafana::server':
    listen_ip => lookup('grafana::server::listen_ip'),
    listen_port => lookup('grafana::server::listen_port'),
    backend => "influxdb",
    backend_port => lookup('influxdb::server::listen_port')
  }
}
