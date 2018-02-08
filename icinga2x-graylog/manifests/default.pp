####################################
# Global configuration
####################################

$hostOnlyIP = '192.168.33.6'
$hostOnlyFQDN = 'icinga2x-graylog.vagrant.demo.icinga.com'

$gelfListenIP = $hostOnlyIP
$gelfListenPort = 12201
$graylogListenIP = $hostOnlyIP
$graylogListenPort = 9000

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
    "gelf" => {
      "listen_ip"   => $gelfListenIP,
      "listen_port" => $gelfListenPort
    }
  }
}
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN,
  node_name => $nodeName,
  modules => {
#    "graylog" => {
#      "listen_ip"   => $graylogListenIP,
#      "listen_port" => $graylogListenPort
#    }
  }
}
->
class { '::profiles::graylog::elasticsearch':
  repo_version => '5.x',
}
->
class { '::profiles::graylog::mongodb': }
->
class { '::profiles::graylog::server':
  repo_version => '2.4',
  listen_ip => $graylogListenIP,
  listen_port => $graylogListenPort
}
->
class { '::profiles::graylog::plugin': }
