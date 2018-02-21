
####################################
# Global configuration
####################################

$nodeName = 'icinga2-influxdb' # TODO: Hiera.
$hostOnlyIP = '192.168.33.8'
$hostOnlyFQDN = 'icinga2x-influxdb.vagrant.demo.icinga.com'
$grafanaListenIP = $hostOnlyIP
$grafanaListenPort = 8004
$influxdbListenIP = $hostOnlyIP
$influxdbListenPort = 8086

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
    "influxdb" => {
      "listen_ip"   => $influxdbListenIP,
      "listen_port" => $influxdbListenPort
    }
  }
}
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN,
  node_name => $nodeName,
  modules => {
    "grafana" => {
      "datasource"  => "influxdb",
      "listen_ip"   => $hostOnlyIP,
      "listen_port" => $grafanaListenPort
    }
  }
}
->
class { '::profiles::influxdb::server':
}
->
class { '::profiles::grafana::server':
  listen_ip => $hostOnlyIP,
  listen_port => $grafanaListenPort,
  backend => "influxdb",
  backend_port => $influxdbListenPort
}


####################################
# Icinga Web 2
####################################

## user-defined preferences (using the iframe module)
#file { '/etc/icingaweb2/preferences':
#  ensure => directory,
#  owner  => root,
#  group  => icingaweb2,
#  mode => '2770',
#  require => Package['icingaweb2']
#}
#
#file { '/etc/icingaweb2/preferences/icingaadmin':
#  ensure => directory,
#  recurse => true,
#  owner  => root,
#  group  => icingaweb2,
#  mode => '2770',
#  source    => "puppet:////vagrant/files/etc/icingaweb2/preferences/icingaadmin",
#  require => [ Package['icingaweb2'], File['/etc/icingaweb2/preferences'] ]
#}




