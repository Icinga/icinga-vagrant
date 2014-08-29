include icinga-rpm-snapshot
include epel
include apache
include mysql
include snmp
include icinga2
include icinga2-ido-mysql
#include icinga2-classicui
#include icinga2-icinga-web
include icingaweb2
include icingaweb2-internal-db-mysql
include monitoring-plugins

####################################
# Basic stuff
####################################

package { [ 'vim-enhanced', 'mailx' ]:
  ensure => 'installed'
}

file { '/etc/motd':
  source => 'puppet:////vagrant/.vagrant-puppet/files/etc/motd',
  owner => root,
  group => root
}

file { '/etc/profile.d/env.sh':
  source => 'puppet:////vagrant/.vagrant-puppet/files/etc/profile.d/env.sh'
}

####################################
# Start page at http://localhost/
####################################

file { '/var/www/html/index.html':
  source    => 'puppet:////vagrant/.vagrant-puppet/files/var/www/html/index.html',
  owner     => 'apache',
  group     => 'apache',
  require   => Package['apache']
}

file { '/var/www/html/icinga_wall.png':
  source    => 'puppet:////vagrant/.vagrant-puppet/files/var/www/html/icinga_wall.png',
  owner     => 'apache',
  group     => 'apache',
  require   => Package['apache']
}

####################################
# Plugins
####################################

file { '/usr/lib/nagios/plugins/check_snmp_int.pl':
   source    => 'puppet:////vagrant/.vagrant-puppet/files/usr/lib/nagios/plugins/check_snmp_int.pl',
   owner     => 'root',
   group     => 'root',
   mode      => 755,
   require   => Class['monitoring-plugins']
}

####################################
# Icinga 2 General
####################################

user { 'vagrant':
  groups  => 'icingacmd',
  require => Package['icinga2']
}

# enable the command pipe
icinga2::feature { 'command': }

# Icinga 2 Cluster

exec { 'iptables-allow-icinga2-cluster':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  #unless => 'grep -Fxqe "-A INPUT -m state --state NEW -m tcp -p tcp --dport 5665 -j ACCEPT" /etc/sysconfig/iptables',
  command => 'lokkit -p 5665:tcp',
  #notify => Service['icinga2']
}

file { '/etc/icinga2':
  ensure    => 'directory',
  require => Package['icinga2']
}

file { '/etc/icinga2/icinga2.conf':
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/icinga2.conf",
  require   => File['/etc/icinga2']
}

file { '/etc/icinga2/pki':
  owner  => icinga,
  group  => icinga,
  ensure    => 'directory',
  require => Package['icinga2']
}

file { '/etc/icinga2/pki/ca.crt':
  owner  => icinga,
  group  => icinga,
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/pki/ca.crt',
  require   => File['/etc/icinga2/pki']
}

file { "/etc/icinga2/pki/$hostname.crt":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/pki/$hostname.crt",
  require   => File['/etc/icinga2/pki']
}

file { "/etc/icinga2/pki/$hostname.key":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/pki/$hostname.key",
  require   => File['/etc/icinga2/pki']
}

file { '/etc/icinga2/cluster':
  owner  => icinga,
  group  => icinga,
  ensure    => 'directory',
  require => Package['icinga2']
}

file { "/etc/icinga2/cluster/$hostname.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/cluster/$hostname.conf",
  require   => [ File['/etc/icinga2/cluster'], Exec['icinga2-enable-feature-api'] ],
  notify    => Service['icinga2']
}

file { "/etc/icinga2/cluster/cluster.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/cluster/cluster.conf",
  require   => [ File['/etc/icinga2/cluster'], Exec['icinga2-enable-feature-api'] ],
  notify    => Service['icinga2']
}


exec { 'icinga2-enable-feature-api':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => 'icinga2-enable-feature api',
  require => File['/etc/icinga2/features-available/api.conf'],
  notify => Service['icinga2']
}

# override constants conf and set NodeName elsewhere
file { "/etc/icinga2/constants.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/constants.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# required for icinga2-enable-feature-api
file { "/etc/icinga2/features-available/api.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/features-available/api.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

####################################
# Icinga 2 Cluster Zones
####################################

# zones
file { '/etc/icinga2/zones.d':
  owner  => icinga,
  group  => icinga,
  ensure => present,
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d',
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

case $hostname {
  'icinga2a': {
    file { '/etc/icinga2/zones.d/master':
      owner  => icinga,
      group  => icinga,
      ensure => present,
      source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/master',
      require   => File['/etc/icinga2/zones.d'],
      notify    => Service['icinga2']
    }

    file { '/etc/icinga2/zones.d/checker':
      owner  => icinga,
      group  => icinga,
      ensure => present,
      source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/checker',
      require   => File['/etc/icinga2/zones.d'],
      notify    => Service['icinga2']
    }

    file { '/etc/icinga2/zones.d/master/health.conf':
      owner  => icinga,
      group  => icinga,
      source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/master/health.conf',
      require   => File['/etc/icinga2/zones.d/master'],
      notify    => Service['icinga2']
    }

    file { '/etc/icinga2/zones.d/checker/health.conf':
      owner  => icinga,
      group  => icinga,
      source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/checker/health.conf',
      require   => File['/etc/icinga2/zones.d/checker'],
      notify    => Service['icinga2']
    }

    # demo config
    file { '/etc/icinga2/zones.d/checker/demo.conf':
      owner  => icinga,
      group  => icinga,
      source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/checker/demo.conf',
      require   => File['/etc/icinga2/zones.d/checker'],
      notify    => Service['icinga2']
    }

    file { '/etc/icinga2/zones.d/checker/templates.conf':
      owner  => icinga,
      group  => icinga,
      source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/checker/templates.conf',
      require   => File['/etc/icinga2/zones.d/checker'],
      notify    => Service['icinga2']
    }
  }
  default: { # icinga2b and more other instances not being the config master
    file { '/etc/icinga2/zones.d/master':
      ensure => absent,
      require   => File['/etc/icinga2/zones.d'],
      notify    => Service['icinga2']
    }

    file { '/etc/icinga2/zones.d/checker':
      ensure => absent,
      require   => File['/etc/icinga2/zones.d'],
      notify    => Service['icinga2']
    }

    file { '/etc/icinga2/zones.d/global-templates':
      ensure => absent,
      require   => File['/etc/icinga2/zones.d'],
      notify    => Service['icinga2']
    }
  }
}
