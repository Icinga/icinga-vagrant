####################################
# Global configuration
####################################

$nodeName = 'icinga2-puppet4' # TODO: Hiera.
$hostOnlyIP = '192.168.33.50'
$hostOnlyFQDN = 'puppet4.vagrant.demo.icinga.com'

$graphiteWebListenIP = $hostOnlyIP
$graphiteWebListenPort = 8003
$carbonListenIP = $hostOnlyIP
$carbonListenPort = 2003
$influxdbListenIP = $hostOnlyIP
$influxdbListenPort = 8086
$grafanaListenIP = $hostOnlyIP
$grafanaListenPort = 8004
$elasticsearchListenIP = 'localhost'
$elasticsearchListenPort = '9200'
$kibanaListenIP = 'localhost'
$kibanaListenPort = 5601
$gelfListenIP = $hostOnlyIP
$gelfListenPort = 12201
$graylogListenIP = $hostOnlyIP
$graylogListenPort = 9000

# Icinga
$directorVersion = '1.4.1'

# Elastic
$elasticRepoVersion = '6.x'
$elasticsearchVersion = '6.2.0'
$kibanaVersion = '6.2.0'
$icingabeatVersion = '6.1.1'
# keep this in sync with the icingabeat dashboard ids!
# http://192.168.33.7:5601/app/kibana#/dashboard/34e97340-e4ce-11e7-b4d1-8383451ae5a4
$kibanaDefaultAppId = 'dashboard/34e97340-e4ce-11e7-b4d1-8383451ae5a4'

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
#class { '::profiles::icinga::icinga2':
#  node_name => $nodeName,
#  features => {
#    #"graphite" => {
#    #  "listen_ip"   => $carbonListenIP,
#    #  "listen_port" => $carbonListenPort
#    #},
#    #"influxdb" => {
#    #  "listen_ip"   => $influxdbListenIP,
#    #  "listen_port" => $influxdbListenPort
#    #},
#    #"gelf" => {
#    #  "listen_ip"   => $gelfListenIP,
#    #  "listen_port" => $gelfListenPort
#    #}
#    "elasticsearch" => {
#      "listen_ip"   => $elasticsearchListenIP,
#      "listen_port" => $elasticsearchListenPort
#    },
#  }
#}
#->
#class { '::profiles::icinga::icingaweb2':
#  icingaweb2_listen_ip => $hostOnlyIP,
#  icingaweb2_fqdn => $hostOnlyFQDN,
#  node_name => $nodeName,
#  modules => {
##    "grafana" => {
##      "datasource"  => "graphite",
##      "listen_ip"   => $grafanaListenIP,
##      "listen_port" => $grafanaListenPort
##    },
##    "map" => {},
#    "director" => {
#      "git_revision" => $directorVersion
#    },
#    "elasticsearch" => {
#      "listen_ip"   => $elasticsearchListenIP,
#      "listen_port" => $elasticsearchListenPort
#    },
##    "graphite" => {
##      "listen_ip"   => $graphiteWebListenIP,
##      "listen_port" => $graphiteWebListenPort
##    },
##    "graylog" => {
##      "listen_ip"   => $graylogListenIP,
##      "listen_port" => $graylogListenPort
##    }
#  }
#}
#->
class { '::profiles::graphite::server':
  listen_ip   => $graphiteWebListenIP,
  listen_port => $graphiteWebListenPort
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
#  listen_ip   => $graphiteListenIP,
#  listen_port => $graphiteListenPort
#}
#->
#class { '::profiles::grafana::server':
#  listen_ip => $grafanaListenIP,
#  listen_port => $grafanaListenPort,
#  version => '4.6.2-1',
#  backend => "graphite",
#  backend_port => $graphiteListenPort
#}
#->
#class { '::profiles::elastic::elasticsearch':
#  repo_version => $elasticRepoVersion,
#  elasticsearch_revision => $elasticsearchVersion
#}
#->
#class { '::profiles::elastic::kibana':
#  repo_version => $elasticRepoVersion,
#  kibana_revision => "${kibanaVersion}-1",
#  kibana_host => $kibanaListenIP,
#  kibana_port => $kibanaListenPort,
#  kibana_default_app_id => $kibanaDefaultAppId
#}
#->
#class { '::profiles::elastic::httpproxy':
#  listen_ip => $hostOnlyIP,
#  node_name => $nodeName
#}
#->
#class { '::profiles::elastic::filebeat':
#  filebeat_major_version => '6'
#}
#->
#class { '::profiles::elastic::icingabeat':
#  icingabeat_version => $icingabeatVersion,
#  kibana_version => $kibanaVersion,
#  elasticsearch_host => $elasticsearchListenIP,
#  elasticsearch_port => $elaticsearchListenPort,
#  kibana_host => $kibanaListenIP, # needed for dashboard provisioning
#  kibana_port => $kibanaListenPort,
#}

#->
#class { '::profiles::graylog::elasticsearch':
#  repo_version => '5.x',
#}
#->
#class { '::profiles::graylog::mongodb': }
#->
#class { '::profiles::graylog::server':
#  repo_version => '2.4',
#  listen_ip => $graylogListenIP,
#  listen_port => $graylogListenPort
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



