####################################
# Global configuration
####################################

$hostOnlyIP = '192.168.33.7'
$hostOnlyFQDN = 'icinga2x-elastic.vagrant.demo.icinga.com'
$kibanaVersion = '5.3.1'
$icingabeatVersion = '1.1.0'
$icingabeatDashboardsChecksum = '9c98cf4341cbcf6d4419258ebcc2121c3dede020'
# keep this in sync with the icingabeat dashboard ids!
# http://192.168.33.7:5601/app/kibana#/dashboard/720f2f20-0979-11e7-a4dd-e96fa284b426
$kibanaDefaultAppId = 'dashboard/720f2f20-0979-11e7-a4dd-e96fa284b426'


####################################
# Setup
####################################

class { '::profiles::base::system': }
->
class { '::profiles::base::mysql': }
->
class { '::profiles::base::java': }
->
class { '::profiles::icinga::icinga2': }
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIp,
  icingaweb2_fqdn => $hostOnlyFQDN
}
->
class { '::profiles::elastic::elasticsearch':
  repo_version => '5.x',
}
->
class { '::profiles::elastic::kibana':
  kibana_revision => "${kibanaVersion}-1",
  kibana_host => '127.0.0.1',
  kibana_port => 5601,
  kibana_default_app_id => $kibanaDefaultAppId
}
->
class { '::profiles::elastic::httpproxy':
  listen_ip => $hostOnlyIp
}
->
class { '::profiles::elastic::filebeat':
}
->
class { '::profiles::elastic::icingabeat':
  icingabeat_version => $icingabeatVersion,
  icingabeat_dashboards_checksum => $icingabeatDashboardsChecksum,
  kibana_version => $kibanaVersion
}

####################################
# Icinga 2 configuration
####################################

# TODO: Make this a generic role based configuration
file { '/etc/icinga2':
  ensure  => 'directory',
  require => Package['icinga2']
}

file { '/etc/icinga2/icinga2.conf':
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/icinga2.conf",
  require   => File['/etc/icinga2'],
  notify    => Service['icinga2']
}

file { "/etc/icinga2/zones.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/zones.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

file { '/etc/icinga2/conf.d/hosts.conf':
  owner  => icinga,
  group  => icinga,
  source    => 'puppet:////vagrant/files/etc/icinga2/conf.d/hosts.conf',
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

file { '/etc/icinga2/conf.d/additional_services.conf':
  owner  => icinga,
  group  => icinga,
  source    => 'puppet:////vagrant/files/etc/icinga2/conf.d/additional_services.conf',
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

file { "/etc/icinga2/features-available/elasticsearch.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/features-available/elasticsearch.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}
->
# TODO: Index pattern
icinga2::feature { 'elasticsearch': }
->
# TODO: Move this into a specific role
icingaweb2::module { 'elasticsearch':
  builtin => false,
  repo_revision => 'next',
  require => [ Class['profiles::icinga::icingaweb2'], Class['profiles::elastic::elasticsearch'] ]
}

####################################
# Icinga Web 2 configuration
####################################

# TODO: Make this a generic role based configuration
file { '/etc/icingaweb2/preferences':
  ensure => directory,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  require => Package['icingaweb2']
}

file { '/etc/icingaweb2/preferences/icingaadmin':
  ensure => directory,
  recurse => true,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  source    => "puppet:////vagrant/files/etc/icingaweb2/preferences/icingaadmin",
  require => [ Package['icingaweb2'], File['/etc/icingaweb2/preferences'] ]
}

# user-defined dashboards for the default 'icingaadmin' user
file { '/etc/icingaweb2/dashboards':
  ensure => directory,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  require => Package['icingaweb2']
}

file { '/etc/icingaweb2/dashboards/icingaadmin':
  ensure => directory,
  recurse => true,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  source    => "puppet:////vagrant/files/etc/icingaweb2/dashboards/icingaadmin",
  require => [ Package['icingaweb2'], File['/etc/icingaweb2/dashboards'] ]
}




