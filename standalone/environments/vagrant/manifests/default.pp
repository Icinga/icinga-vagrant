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
      "graphite" => {
        listen_ip => lookup('graphite::carbon::listen_ip'),
        listen_port => lookup('graphite::carbon::listen_port'),
      }
    }
  }
  ->
  class { '::profiles::icinga::icingaweb2':
    icingaweb2_listen_ip => lookup('icinga::icingaweb2::listen_ip'),
    icingaweb2_fqdn => lookup('icinga::icingaweb2::fqdn'),
    node_name => lookup('icinga::icinga2::node_name'),
    modules => {
      "director" => {
        "git_revision" => lookup('icinga::director::version')
      },
      "graphite" => {
        "listen_ip"   => lookup('graphite::web::listen_ip'),
        "listen_port" => lookup('graphite::web::listen_port')
      },
      "businessprocess" => {},
      "cube" => {},
      "map" => {}
    }
  }
  ->
  class { '::profiles::graphite::server':
    listen_ip => lookup('graphite::web::listen_ip'),
    listen_port => lookup('graphite::web::listen_port')
  }
  ->
  class { '::profiles::grafana::server':
    listen_ip     => lookup('grafana::server::listen_ip'),
    listen_port   => lookup('grafana::server::listen_port'),
    version       => lookup('grafana::version'),
    backend       => "graphite",
    backend_port  => lookup('graphite::web::listen_port')
  }
  ->
  class { '::profiles::dashing::icinga2':
  }

}
