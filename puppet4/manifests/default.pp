####################################
# Global configuration
####################################

$hostOnlyIP = '192.168.33.50'
$hostOnlyFQDN = 'puppet4.vagrant.demo.icinga.com'
$graphiteListenPort = 8003
$influxdbListenPort = 8086
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
class { '::profiles::base::java': }
->
class { '::profiles::icinga::icinga2':
  features => [ "gelf", "influxdb", "graphite" ]
}
#->
#class { '::profiles::icinga::icingaweb2':
#  icingaweb2_listen_ip => $hostOnlyIP,
#  icingaweb2_fqdn => $hostOnlyFQDN,
#  modules => {
#    "grafana" => {
#      "datasource"  => "influxdb",
#      "listen_ip"   => $hostOnlyIP,
#      "listen_port" => $grafanaListenPort
#    },
#    "map" => {}
#  }
#}
->
class { '::profiles::dashing::icinga2': }
->
class { '::profiles::influxdb::server':
}
->
#class { '::profiles::grafana::server':
#  listen_ip => $hostOnlyIP,
#  listen_port => $grafanaListenPort,
#  version => '4.6.2-1',
#  backend => "influxdb",
#  backend_port => $influxdbListenPort
#}
class { '::profiles::graphite::server':
  listen_ip   => $hostOnlyIP,
  listen_port => $graphiteListenPort
}
->
class { '::profiles::grafana::server':
  listen_ip => $hostOnlyIP,
  listen_port => $grafanaListenPort,
  version => '4.6.2-1',
  backend => "graphite",
  backend_port => $graphiteListenPort
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



