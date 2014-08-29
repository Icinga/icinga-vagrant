include icinga-rpm-snapshot
include epel
include apache
include mysql
include icinga2
include icinga2-ido-mysql
include icinga2-classicui
include icinga2-icinga-web
include icingaweb2
include icingaweb2-internal-db-mysql
include monitoring-plugins

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
# Misc
####################################

package { 'vim-enhanced':
  ensure => 'installed'
}

file { '/etc/motd':
  source => 'puppet:////vagrant/.vagrant-puppet/files/etc/motd',
  owner => root,
  group => root
}

user { 'vagrant':
  groups  => ['icinga', 'icingacmd'],
  require => [User['icinga'], Group['icingacmd']]
}

####################################
# Icinga 2 General
####################################

# enable the command pipe
icinga2::feature { 'command': }
