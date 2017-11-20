####################################
# Global configuration
####################################

$hostOnlyFQDN = "${hostname}.icinga2x-cluster.vagrant.demo.icinga.com"

case $hostname {
  'icinga2a': {
     $hostOnlyIP = '192.168.33.10'
   }
  'icinga2b': {
     $hostOnlyIP = '192.168.33.20'
   }
}

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
}

# override constants conf and set NodeName
file { "/etc/icinga2/constants.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/constants.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# Icinga 2 Cluster

file { '/etc/icinga2':
  ensure    => 'directory',
  require => Package['icinga2']
}

file { '/var/lib/icinga2/certs':
  owner  => icinga,
  group  => icinga,
  ensure    => 'directory',
  require => Package['icinga2']
}

file { '/var/lib/icinga2/certs/ca.crt':
  owner  => icinga,
  group  => icinga,
  source    => 'puppet:////vagrant/files/etc/icinga2/pki/ca.crt',
  require   => File['/var/lib/icinga2/certs']
}

file { "/var/lib/icinga2/certs/$hostname.crt":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/pki/$hostname.crt",
  require   => File['/var/lib/icinga2/certs']
}

file { "/var/lib/icinga2/certs/$hostname.key":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/pki/$hostname.key",
  require   => File['/var/lib/icinga2/certs']
}


# required for icinga2-enable-feature-api
file { "/etc/icinga2/features-available/api.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/features-available/api.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# local cluster health checks
file { '/etc/icinga2/cluster':
  owner  => icinga,
  group  => icinga,
  ensure    => 'directory',
  require => Package['icinga2']
}

file { "/etc/icinga2/demo/$hostname.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/cluster/$hostname.conf",
  require   => File['/etc/icinga2/demo'],
  notify    => Service['icinga2']
}

# remote client
file { '/etc/icinga2/remote':
  owner  => icinga,
  group  => icinga,
  ensure => present,
  source    => 'puppet:////vagrant/files/etc/icinga2/remote',
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

####################################
# Icinga 2 Cluster Zones
####################################

file { "/etc/icinga2/zones.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/zones.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# zones
file { '/etc/icinga2/zones.d':
  owner  => icinga,
  group  => icinga,
  ensure => present,
  source    => 'puppet:////vagrant/files/etc/icinga2/zones.d',
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# remove leftovers from previous runs
file { [ '/var/lib/icinga2/api/zones/master', '/var/lib/icinga2/api/zones/checker', '/var/lib/icinga2/api/zones/global-templates' ]:
  force  => true,
  ensure => absent
}

case $hostname {
  'icinga2a': {
    # remote client
    file { '/etc/icinga2/demo/remote_client.conf':
      owner  => icinga,
      group  => icinga,
      source    => 'puppet:////vagrant/files/etc/icinga2/remote/demo.conf',
      require   => File['/etc/icinga2/demo'],
      notify    => Service['icinga2']
    }

    # cluster
    file { [ '/etc/icinga2/zones.d/master', '/etc/icinga2/zones.d/checker', '/etc/icinga2/zones.d/global-templates' ]:
      owner  => icinga,
      group  => icinga,
      ensure => directory,
      require   => File['/etc/icinga2/zones.d'],
      notify    => Service['icinga2']
    }

    # checker zone hosts config
    ['hosts', 'camp', 'services', 'additional_services'].each |String $cfgfile| {
      file { "/etc/icinga2/zones.d/checker/${cfgfile}.conf":
        owner  => icinga,
        group  => icinga,
        source    => "puppet:////vagrant/files/etc/icinga2/zones.d/checker/${cfgfile}.conf",
        require   => File['/etc/icinga2/zones.d/checker'],
        notify    => Service['icinga2']
      }
    }

    # global template zone
    ['templates'].each |String $cfgfile| {
      file { "/etc/icinga2/zones.d/global-templates/${cfgfile}.conf":
        owner  => icinga,
        group  => icinga,
        source    => "puppet:////vagrant/files/etc/icinga2/zones.d/global-templates/${cfgfile}.conf",
        require   => File['/etc/icinga2/zones.d/global-templates'],
        notify    => Service['icinga2']
      }
    }
  }

  default: { # icinga2b and more other instances not being the config master
    ['master', 'checker', 'global-templates'].each |String $cfgdir| {
      file { "/etc/icinga2/zones.d/${cfgdir}":
        ensure => absent,
        require   => File['/etc/icinga2/zones.d'],
        notify    => Service['icinga2']
      }
    }
  }
}
