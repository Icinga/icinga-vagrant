node default {
  class { '::profiles::base::system':
    icinga_repo => lookup('icinga::repo::type')
  }
  ->
  class { '::profiles::base::mysql': }
  ->
  class { '::profiles::base::apache': }
  ->
  class { '::profiles::base::java': }
  ->
  class { '::profiles::icinga::icinga2':
    node_name => lookup('icinga::icinga2::node_name'),
    features => {
      "gelf" => {
        "listen_ip"   => lookup('graylog::gelf::listen_ip'),
        "listen_port" => lookup('graylog::gelf::listen_port')
      }
    }
  }
  ->
  class { '::profiles::icinga::icingaweb2':
    icingaweb2_listen_ip => lookup('icinga::icingaweb2::listen_ip'),
    icingaweb2_fqdn => lookup('icinga::icingaweb2::fqdn'),
    node_name => lookup('icinga::icinga2::node_name'),
    modules => {
#    "graylog" => {
#      "listen_ip"   => lookup('graylog::web::listen_ip'),
#      "listen_port" => lookup('graylog::web::listen_port')
#    }
    }
  }
  ->
  class { '::profiles::graylog::elasticsearch':
    repo_version => lookup('graylog::elasticsearch::repo_version'),
  }
  ->
  class { '::profiles::graylog::mongodb': }
  ->
  class { '::profiles::graylog::server':
    repo_version => lookup('graylog::repo::version'),
    listen_ip => lookup('graylog::web::listen_ip'),
    listen_port => lookup('graylog::web::listen_port')
  }
  ->
  class { '::profiles::graylog::plugin': }
}
