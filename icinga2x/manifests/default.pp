####################################
# Global configuration
####################################

$nodeName = 'icinga2' # TODO: Hiera.
$hostOnlyIP = '192.168.33.5'
$hostOnlyFQDN = 'icinga2x.vagrant.demo.icinga.com'

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
$directorVersion = 'v1.4.1'

####################################
# Setup
####################################

class { '::profiles::base::system': }
->
class { '::profiles::base::mysql': }
->
class { '::profiles::base::apache': }
->
class { '::profiles::icinga::icinga2':
  node_name => $nodeName,
  features => {
    "graphite" => {
      "listen_ip"   => $carbonListenIP,
      "listen_port" => $carbonListenPort
    }
  }
}
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN,
  node_name => $nodeName,
  modules => {
    "director" => {
      "git_revision" => $directorVersion
    },
    "graphite" => {
      "listen_ip"   => $graphiteWebListenIP,
      "listen_port" => $graphiteWebListenPort
    },
    "businessprocess" => {},
    "cube" => {},
    "map" => {}
  }
}
->
class { '::profiles::graphite::server':
  listen_ip   => $graphiteListenIP,
  listen_port => $graphiteListenPort
}
->
class { '::profiles::grafana::server':
  listen_ip     => $grafanaListenIP,
  listen_port   => $grafanaListenPort,
  version       => '4.6.3-1',
  backend       => "graphite",
  backend_port  => $graphiteListenPort
}
->
class { '::profiles::dashing::icinga2':
}


