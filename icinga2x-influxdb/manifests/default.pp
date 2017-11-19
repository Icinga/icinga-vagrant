
####################################
# Global configuration
####################################

$hostOnlyIP = '192.168.33.8'
$hostOnlyFQDN = 'icinga2x-influxdb.vagrant.demo.icinga.com'

####################################
# Setup
####################################

class { '::profiles::base::system': }
->
class { '::profiles::base::mysql': }
->
class { '::profiles::base::apache': }
->
class { '::profiles::icinga::icinga2': }
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN
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

####################################
# InfluxDB
####################################

icinga2::feature { 'influxdb': }

class {'influxdb::server':
}->
file { 'influxdb-setup':
  name => '/usr/local/bin/influxdb-setup',
  owner => root,
  group => root,
  mode => '0755',
  source => "puppet:////vagrant/files/usr/local/bin/influxdb-setup",
}
->
exec { 'finish-influxdb-setup':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => "/usr/local/bin/influxdb-setup",
  require => [ Class['influxdb::server::service'] ]
}

####################################
# Grafana
####################################

# https://github.com/bfraser/puppet-grafana
class { 'grafana':
  package_source => 'https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.2.0-1.x86_64.rpm',
  cfg => {
    app_mode => 'production',
    server   => {
      http_port     => 8004,
    },
    users    => {
      allow_sign_up => false,
    },
    security => {
      admin_user => 'admin',
      admin_password => 'admin',
    },
  },
}
->
# there are no static config files for data sources in grafana2
# https://github.com/grafana/grafana/issues/1789
file { 'grafana-setup':
  name => '/usr/local/bin/grafana-setup',
  owner => root,
  group => root,
  mode => '0755',
  source => "puppet:////vagrant/files/usr/local/bin/grafana-setup",
}
->
file { 'grafana-dashboard-icinga2-influxdb':
  name => '/etc/icinga2/grafana-dashboard-icinga2-influxdb.json',
  owner => root,
  group => root,
  mode => '0644',
  source => "puppet:////vagrant/files/etc/icinga2/grafana-dashboard-icinga2-influxdb.json",
}->
file { 'grafana-dashboard-influxdb-base-metrics':
  name => '/etc/icinga2/influxdb-base-metrics.json',
  owner => root,
  group => root,
  mode => '0644',
  source => "puppet:////vagrant/files/etc/icinga2/influxdb-base-metrics.json",
}->
file { 'grafana-dashboard-influxdb-icinga2-default':
  name => '/etc/icinga2/influxdb-icinga2-default.json',
  owner => root,
  group => root,
  mode => '0644',
  source => "puppet:////vagrant/files/etc/icinga2/influxdb-icinga2-default.json",
}
->
exec { 'finish-grafana-setup':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => "/usr/local/bin/grafana-setup",
  require => [ Class['grafana::service'], Class['influxdb::server::service'] ],
  notify => Class['apache::service']
}

####################################
# Icinga Web 2 Grafana Module
####################################

icingaweb2::module { 'grafana':
  builtin => false,
  repo_url => 'https://github.com/Mikesch-mp/icingaweb2-module-grafana'
}->
file { '/etc/icingaweb2/modules/grafana':
  ensure => directory,
  recurse => true,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  source    => "puppet:////vagrant/files/etc/icingaweb2/modules/grafana",
  require => [ Package['icingaweb2'], File['/etc/icingaweb2/modules'] ]
}


