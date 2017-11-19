####################################
# Global configuration
####################################

$hostOnlyIP = '192.168.33.6'
$hostOnlyFQDN = 'icinga2x-graylog.vagrant.demo.icinga.com'


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
class { '::profiles::icinga::icinga2': }
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN
}
->
class { '::profiles::graylog::elasticsearch':
  repo_version => '5.x',
}
->
class { '::profiles::graylog::mongodb': }
->
class { '::profiles::graylog::server':
  repo_version => '2.3',
  listen_ip => $hostOnlyIP
}
->
class { '::profiles::graylog::plugin': }





####################################
# Icinga 2 General
####################################

# TODO: specific role
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


# TODO: role specific

# Demo config required by the modules
file { '/etc/icinga2/demo':
  ensure => directory,
  recurse => true,
  owner  => icinga,
  group  => icinga,
#  source    => "puppet:////vagrant/files/etc/icinga2/demo",
  require   => File['/etc/icinga2/icinga2.conf'],
  notify    => Service['icinga2']
}

file { '/etc/icinga2/demo/graylog2-demo.conf':
  owner  => icinga,
  group  => icinga,
  content   => template("icinga2/graylog2-demo.conf.erb"),
  require   => [ Package['icinga2'], File['/etc/icinga2/demo'] ],
  notify    => Service['icinga2']
} ->
icinga2::feature { 'gelf':
}



