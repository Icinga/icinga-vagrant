node default {
  class { '::profiles::base::system':
    icinga_repo => lookup('icinga::repo::type')
  }
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
    node_name => lookup('icinga::icinga2::node_name'),
    modules => {
      "grafana" => {
        "datasource"  => "influxdb",
        "listen_ip"   => lookup('grafana::server::listen_ip'),
        "listen_port" => lookup('grafana::server::listen_port')
      },
      "director" => {
        "git_revision" => lookup('icinga::director::version')
      },
      "businessprocess" => {},
      "cube" => {},
      "map" => {}
    }
  }
  ->
  class { '::profiles::influxdb::server':
  }
  ->
  class { '::profiles::grafana::server':
    listen_ip     => lookup('grafana::server::listen_ip'),
    listen_port   => lookup('grafana::server::listen_port'),
    version       => lookup('grafana::version'),
    backend       => "influxdb",
    backend_port  => lookup('influxdb::server::listen_port')
  }
}
