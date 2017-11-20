####################################
# Global configuration
####################################

$hostOnlyIP = '192.168.33.5'
$hostOnlyFQDN = 'icinga2x.vagrant.demo.icinga.com'
$graphiteListenPort = 8003
$grafanaListenPort = 8004

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
  features => [ "graphite" ]
}
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN,
  modules => {
    "grafana" => {
      "datasource"  => "graphite",
      "listen_ip"   => $hostOnlyIP,
      "listen_port" => $grafanaListenPort
    },
    "businessprocess" => {},
    "cube" => {},
    "map" => {}
  }
}
->
class { '::profiles::graphite::server':
  listen_ip   => $hostOnlyIP,
  listen_port => $graphiteListenPort
}
->
class { '::profiles::grafana::server':
  listen_port => $grafanaListenPort,
  version => '4.2.0-1',
  backend => "graphite"
}
->
class { '::profiles::dashing::icinga2': }


