include icinga-rpm-snapshot
include epel
include apache
include mariadb
include snmp
include icinga2
include icinga2-ido-mysql
#include icinga2-classicui
#include icinga2-icinga-web
include icingaweb2
include icingaweb2-internal-db-mysql
include monitoring-plugins
include selinux

####################################
# Basic stuff
####################################

Package {
  allow_virtual => false
}

package { [ 'vim-enhanced', 'mailx', 'tree', 'gdb' ]:
  ensure => 'installed'
}

package { 'bash-completion':
  ensure => 'installed',
  require => Class['epel']
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

file { '/usr/lib64/nagios/plugins/check_snmp_int.pl':
   source    => 'puppet:////vagrant/.vagrant-puppet/files/usr/lib64/nagios/plugins/check_snmp_int.pl',
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

# override constants conf and set NodeName
file { "/etc/icinga2/constants.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/constants.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# Icinga 2 Cluster

exec { 'iptables-allow-icinga2-cluster':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  unless => 'grep -Fxqe "-A INPUT -m state --state NEW -m tcp -p tcp --dport 5665 -j ACCEPT" /etc/sysconfig/iptables',
  command => 'firewall-cmd --permanent --add-port=5665/tcp; firewall-cmd --add-port=5665/tcp',
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


exec { 'icinga2-enable-feature-api':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => 'icinga2 feature enable api',
  require => File['/etc/icinga2/features-available/api.conf'],
  notify => Service['icinga2']
}

# required for icinga2-enable-feature-api
file { "/etc/icinga2/features-available/api.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/features-available/api.conf",
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

file { "/etc/icinga2/cluster/$hostname.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/cluster/$hostname.conf",
  require   => [ File['/etc/icinga2/cluster'], Exec['icinga2-enable-feature-api'] ],
  notify    => Service['icinga2']
}

# keep it removed from previous installations (replaced by zones.conf #7184)
file { "/etc/icinga2/cluster/cluster.conf":
  ensure    => absent,
}

# remote client
file { '/etc/icinga2/remote':
  owner  => icinga,
  group  => icinga,
  ensure => present,
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/remote',
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

####################################
# Icinga 2 Cluster Zones
####################################

file { "/etc/icinga2/zones.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# zones
file { '/etc/icinga2/zones.d':
  owner  => icinga,
  group  => icinga,
  ensure => present,
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d',
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
    file { '/etc/icinga2/remote/demo.conf':
      owner  => icinga,
      group  => icinga,
      source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/remote/demo.conf',
      require   => File['/etc/icinga2/remote'],
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

    # move health checks to local cluster/ dir #7240
    file { [ '/etc/icinga2/zones.d/master/health.conf', '/etc/icinga2/zones.d/checker/health.conf', '/etc/icinga2/zones.d/checker/templates.conf' ]:
      ensure => absent
    }

    # checker zone demo config
    file { '/etc/icinga2/zones.d/checker/demo.conf':
      owner  => icinga,
      group  => icinga,
      source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/checker/demo.conf',
      require   => File['/etc/icinga2/zones.d/checker'],
      notify    => Service['icinga2']
    }

    # global template zone
    file { '/etc/icinga2/zones.d/global-templates/templates.conf':
      owner  => icinga,
      group  => icinga,
      source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/global-templates/templates.conf',
      require   => File['/etc/icinga2/zones.d/global-templates'],
      notify    => Service['icinga2']
    } ->
    file { '/etc/icinga2/zones.d/global-templates/groups.conf':
      owner  => icinga,
      group  => icinga,
      source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/global-templates/groups.conf',
      require   => File['/etc/icinga2/zones.d/global-templates'],
      notify    => Service['icinga2']
    } ->
    file { '/etc/icinga2/zones.d/global-templates/users.conf':
      owner  => icinga,
      group  => icinga,
      source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/global-templates/users.conf',
      require   => File['/etc/icinga2/zones.d/global-templates'],
      notify    => Service['icinga2']
    } ->
    file { '/etc/icinga2/zones.d/global-templates/commands.conf':
      owner  => icinga,
      group  => icinga,
      source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/global-templates/commands.conf',
      require   => File['/etc/icinga2/zones.d/global-templates'],
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
