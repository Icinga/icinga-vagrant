####################################
# Global configuration
####################################

$nodeName = 'icinga2-elastic' # TODO: Hiera.
$hostOnlyIP = '192.168.33.7'
$hostOnlyFQDN = 'icinga2x-elastic.vagrant.demo.icinga.com'

$elasticsearchListenIP = 'localhost'
$elasticsearchListenPort = '9200'
$kibanaListenIP = 'localhost'
$kibanaListenPort = 5601

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
class { '::profiles::icinga::icinga2':
  node_name => $nodeName,
  features => {
    "elasticsearch" => {
      "listen_ip"   => $elasticsearchListenIP,
      "listen_port" => $elasticsearchListenPort
    },
  }
}
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN,
  modules => {
    "elasticsearch" => {
      "listen_ip"   => $elasticsearchListenIP,
      "listen_port" => $elasticsearchListenPort
    },
  }
}
->
class { '::profiles::elastic::elasticsearch':
  repo_version => $elasticRepoVersion,
  elasticsearch_revision => $elasticsearchVersion
}
->
class { '::profiles::elastic::kibana':
  repo_version => $elasticRepoVersion,
  kibana_revision => "${kibanaVersion}-1",
  kibana_host => $kibanaListenIP,
  kibana_port => $kibanaListenPort,
  kibana_default_app_id => $kibanaDefaultAppId
}
->
class { '::profiles::elastic::httpproxy':
  listen_ip => $hostOnlyIP,
  node_name => $nodeName
}
->
class { '::profiles::elastic::filebeat':
  filebeat_major_version => '6'
}
->
class { '::profiles::elastic::icingabeat':
  icingabeat_version => $icingabeatVersion,
  kibana_version => $kibanaVersion,
  elasticsearch_host => $elasticsearchListenIP,
  elasticsearch_port => $elaticsearchListenPort,
  kibana_host => $kibanaListenIP, # needed for dashboard provisioning
  kibana_port => $kibanaListenPort,
}
