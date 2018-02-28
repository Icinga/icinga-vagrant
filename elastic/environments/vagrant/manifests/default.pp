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
    icingaweb2_listen_ip => lookup('icinga::icingaweb2::listen_ip'),
    icingaweb2_fqdn => lookup('icinga::icingaweb2::fqdn'),
    node_name => lookup('icinga::icinga2::node_name'),
    modules => {
      "elasticsearch" => {
        "listen_ip"   => lookup('elastic::elasticsearch::listen_ip'),
        "listen_port" => lookup('elastic::elasticsearch::listen_port')
      },
    }
  }
  ->
  class { '::profiles::elastic::elasticsearch':
    repo_version => lookup('elastic::repo::version'),
    elasticsearch_revision => lookup('elastic::elasticsearch::version')
  }
  ->
  class { '::profiles::elastic::kibana':
    repo_version => lookup('elastic::repo::version'),
    kibana_revision => lookup('elastic::kibana::version'),
    kibana_host => lookup('elastic::kibana::listen_ip'),
    kibana_port => lookup('elastic::kibana::listen_port'),
    kibana_default_app_id => lookup('elastic::kibana::default_app_id')
  }
  ->
  class { '::profiles::elastic::httpproxy':
    listen_ip => lookup('icinga::icingaweb2::listen_ip'),
    node_name => lookup('icinga::icinga2::node_name')
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
