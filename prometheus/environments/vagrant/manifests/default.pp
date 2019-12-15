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
    }
  }
  ->
  class { '::profiles::icinga::icingaweb2':
    node_name => lookup('icinga::icinga2::node_name'),
    modules => {
      "x509" => {},
      "businessprocess" => {},
    },
    themes => {
      "unicorn"       => {},
      "lsd"           => {},
    }
  }
  ->
  class { '::profiles::prometheus::server':

  }
  ->
  class { '::profiles::prometheus::node_exporter':

  }
  ->
  class { '::profiles::prometheus::blackbox_exporter':

  }
  ->
  class { '::profiles::grafana::server':
    listen_ip     => lookup('grafana::server::listen_ip'),
    listen_port   => lookup('grafana::server::listen_port'),
    version       => lookup('grafana::version'),
    backend       => "prometheus",
    backend_port  => lookup('prometheus::server::listen_port')
  }
}
