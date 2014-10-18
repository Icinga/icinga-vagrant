include icinga-rpm-snapshot
include epel
include icinga2
include monitoring-plugins

case $hostname {
  'icinga2m': {
    include apache
    include mysql
    include snmp
    include icinga2-ido-mysql
    include icingaweb2
    include icingaweb2-internal-db-mysql
  }
  'icinga2a1': {
  }
  'icinga2a2': {
  }

}


####################################
# Basic stuff
####################################

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

case $hostname {
  'icinga2m': {

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

  }

}

####################################
# Icinga 2 General
####################################

user { 'vagrant':
  groups  => 'icingacmd',
  require => Package['icinga2']
}

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
