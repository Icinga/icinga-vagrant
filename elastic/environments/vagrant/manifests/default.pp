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
      "elasticsearch" => {
        "listen_ip"   => lookup('elastic::elasticsearch::listen_ip'),
        "listen_port" => lookup('elastic::elasticsearch::listen_port')
      },
    }
  }
  ->
  class { '::profiles::icinga::icingaweb2':
    node_name => lookup('icinga::icinga2::node_name'),
    modules => {
      "elasticsearch" => {
        "listen_ip"   => lookup('elastic::elasticsearch::listen_ip'),
        "listen_port" => lookup('elastic::elasticsearch::listen_port')
      },
      "x509" => {},
      "businessprocess" => {},
      "cube" => {},
      "map" => {}
    }
  }
  ->
  class { '::profiles::elastic::elasticsearch':
    repo_version => lookup('elastic::repo::version'),
    elasticsearch_revision => lookup('elastic::elasticsearch::version')
  }
  ->
  class { '::profiles::elastic::kibana':
    kibana_revision => lookup('elastic::kibana::version'),
    kibana_host => lookup('elastic::kibana::listen_ip'),
    kibana_port => lookup('elastic::kibana::listen_port'),
    kibana_default_app_id => lookup('elastic::kibana::default_app_id')
  }
  ->
  class { '::profiles::elastic::httpproxy':
    node_name => lookup('icinga::icinga2::node_name'),
    listen_ports => {
      'kibana' => 5602,
      'kibana_tls' => 5603,
      'elasticsearch' => 9202,
      'elasticsearch_tls' => 9203
    }
  }
  ->
  class { '::profiles::elastic::filebeat':
    filebeat_major_version => '6'
  }
  ->
  class { '::profiles::elastic::icingabeat':
    icingabeat_version => lookup('elastic::icingabeat::version'),
    kibana_version => lookup('elastic::kibana::version'),
    elasticsearch_host => lookup('elastic::elasticsearch::listen_ip'),
    elasticsearch_port => lookup('elastic::elasticsearch::listen_port'),
    kibana_host => lookup('elastic::kibana::listen_ip'), # needed for dashboard provisioning
    kibana_port => lookup('elastic::kibana::listen_port'),
  }
}
