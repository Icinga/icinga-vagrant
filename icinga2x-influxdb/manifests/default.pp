
####################################
# Global configuration
####################################

$hostOnlyIP = '192.168.33.8'
$hostOnlyFQDN = 'icinga2x-influxdb.vagrant.demo.icinga.com'
$grafanaListenPort = 8004
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
  features => [ "influxdb" ]
}
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN,
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
  version => '4.6.2-1',
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




