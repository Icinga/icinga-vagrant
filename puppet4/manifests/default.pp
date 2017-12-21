####################################
# Global configuration
####################################

$nodeName = 'icinga2-puppet4' # TODO: Hiera.
$hostOnlyIP = '192.168.33.50'
$hostOnlyFQDN = 'puppet4.vagrant.demo.icinga.com'
$graphiteListenPort = 8003
$influxdbListenPort = 8086
$grafanaListenPort = 8004

# Elastic
# TODO: Wait for 6.x support in Icingabeat
#$elasticRepoVersion = '6.x'
#$elasticsearchVersion = '6.0.0'
#$kibanaVersion = '6.0.0'
#$icingabeatVersion = '1.1.1'
#$icingabeatDashboardsChecksum = '11f1f92e541f4256727137094d4d69efdd6f3862'
$elasticRepoVersion = '5.x'
$elasticsearchVersion = '5.6.4'
$kibanaVersion = '5.3.1'
$icingabeatVersion = '1.1.0'
$icingabeatDashboardsChecksum = '9c98cf4341cbcf6d4419258ebcc2121c3dede020'
# keep this in sync with the icingabeat dashboard ids!
# http://192.168.33.7:5601/app/kibana#/dashboard/720f2f20-0979-11e7-a4dd-e96fa284b426
$kibanaDefaultAppId = 'dashboard/720f2f20-0979-11e7-a4dd-e96fa284b426'

$elasticsearchListenIP = 'localhost'
$elasticsearchListenPort = '9200'

####################################
# Setup
####################################

class { '::profiles::base::system': }
->
class { '::profiles::base::mysql': }
->
class { '::profiles::base::apache': }
->
class { '::profiles::base::java': }
->
class { '::profiles::icinga::icinga2':
  features => {
    "elasticsearch" => {
      "listen_ip"   => $elasticsearchListenIP,
      "listen_port" => $elasticsearchListenPort
    }
  }
}
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN,
  modules => {
#    "grafana" => {
#      "datasource"  => "graphite",
#      "listen_ip"   => $hostOnlyIP,
#      "listen_port" => $grafanaListenPort
#    },
#    "map" => {},
    "elasticsearch" => {
      "listen_ip"   => $elasticsearchListenIP,
      "listen_port" => $elasticsearchListenPort
    }
  }
}
#->
#class { '::profiles::dashing::icinga2': }
#->
#class { '::profiles::influxdb::server':
#}
#->
#class { '::profiles::grafana::server':
#  listen_ip => $hostOnlyIP,
#  listen_port => $grafanaListenPort,
#  version => '4.6.2-1',
#  backend => "influxdb",
#  backend_port => $influxdbListenPort
#}
#class { '::profiles::graphite::server':
#  listen_ip   => $hostOnlyIP,
#  listen_port => $graphiteListenPort
#}
#->
#class { '::profiles::grafana::server':
#  listen_ip => $hostOnlyIP,
#  listen_port => $grafanaListenPort,
#  version => '4.6.2-1',
#  backend => "graphite",
#  backend_port => $graphiteListenPort
#}
->
class { '::profiles::elastic::elasticsearch':
  repo_version => $elasticRepoVersion,
  elasticsearch_revision => $elasticsearchVersion
}
->
class { '::profiles::elastic::kibana':
  repo_version => $elasticRepoVersion,
  kibana_revision => "${kibanaVersion}-1",
  kibana_host => '127.0.0.1',
  kibana_port => 5601,
  kibana_default_app_id => $kibanaDefaultAppId
}
->
class { '::profiles::elastic::httpproxy':
  listen_ip => $hostOnlyIP,
  node_name => $nodeName
}
->
class { '::profiles::elastic::filebeat':
  filebeat_major_version => '5'
}
->
class { '::profiles::elastic::icingabeat':
  icingabeat_version => $icingabeatVersion,
  icingabeat_dashboards_checksum => $icingabeatDashboardsChecksum,
  kibana_version => $kibanaVersion
}

#->
#class { '::profiles::graylog::elasticsearch':
#  repo_version => '5.x',
#}
#->
#class { '::profiles::graylog::mongodb': }
#->
#class { '::profiles::graylog::server':
#  repo_version => '2.3',
#  listen_ip => $hostOnlyIP
#}
#->
#class { '::profiles::graylog::plugin': }
#
#
#
#
## TODO: role specific
#
#file { '/etc/icinga2/demo/graylog2-demo.conf':
#  owner  => icinga,
#  group  => icinga,
#  content   => template("icinga2/graylog2-demo.conf.erb"),
#  require   => [ Package['icinga2'], File['/etc/icinga2/demo'] ],
#  notify    => Service['icinga2']
#}



