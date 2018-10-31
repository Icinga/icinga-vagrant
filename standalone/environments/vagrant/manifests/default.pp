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
      "graphite" => {
        listen_ip => lookup('graphite::carbon::listen_ip'),
        listen_port => lookup('graphite::carbon::listen_port'),
      }
    }
  }
  ->
  class { '::profiles::icinga::icingaweb2':
    node_name => lookup('icinga::icinga2::node_name'),
    modules => {
      "graphite" => {
        "listen_ip"   => lookup('graphite::web::listen_ip'),
        "listen_port" => lookup('graphite::web::listen_port')
      },
      "director" => {
        "git_revision" => lookup('icinga::director::version')
      },
      "businessprocess" => {},
      "cube" => {},
      "map" => {}
    },
    themes => {
      "company"       => {},
      "unicorn"       => {},
      "always-green"  => {},
      "lsd"           => {},
      "april"         => {},
      "batman"        => {},
      "nordlicht"     => {},
      "spring"        => {}
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
    icingaweb2_listen_ip => lookup('icinga::dashing::icingaweb2::listen_ip'),
  }

}
