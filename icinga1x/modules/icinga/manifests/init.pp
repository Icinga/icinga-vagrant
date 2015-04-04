# Class: icinga, icinga-idoutils-libdbi-mysql
#
#   Install Icinga and IDOUtils incl DB Setup from snapshot rpms
#   
#   Copyright (C) 2014-present Icinga Development Team (http://www.icinga.org/)
#
# Parameters:
#
# Actions:
#
# Requires: icinga-rpm-snapshot
#
# Sample Usage:
#
#   include icinga
#   include icinga-idoutils-libdbi-mysql
#

class icinga {
  include icinga-rpm-snapshot

  package { 'icinga':
    ensure => installed,
    require => Class['icinga-rpm-snapshot'],
    alias => 'icinga'
  }

  package { 'icinga-doc':
    ensure => installed,
    require => Class['icinga-rpm-snapshot'],
    alias => 'icinga-doc'
  }

  service { 'icinga':
    enable => true,
    ensure => running,
    hasrestart => true,
    alias => 'icinga',
    require => Package['icinga']
  }

  file { "/etc/icinga/modules/*":
    notify => Service['icinga']
  }
}

class icinga-idoutils-libdbi-mysql {
  include icinga-rpm-snapshot
  include mysql

  package { 'icinga-idoutils-libdbi-mysql':
    ensure => installed,
    require => Class['icinga-rpm-snapshot'],
    alias => 'icinga-idoutils-libdbi-mysql'
  }

  file { '/etc/sysconfig/ido2db':
    source => 'puppet:////vagrant/files/etc/sysconfig/ido2db',
    require => Package['icinga-idoutils-libdbi-mysql']
  }

  file { '/etc/icinga/modules/idoutils.cfg':
    source => 'puppet:////vagrant/files/etc/icinga/modules/idoutils.cfg',
    require => Package['icinga'],
    notify => Service['icinga']
  }

  file { '/etc/icinga/idomod-mysql.cfg':
    source => 'puppet:////vagrant/files/etc/icinga/idomod-mysql.cfg',
    require => [ Package['icinga-idoutils-libdbi-mysql'],
		 Package['icinga'],
		 Exec['populate-mysql-icinga-idoutils-db']
	       ],
    notify => Service['icinga']    
  }

  file { '/etc/icinga/ido2db-mysql.cfg':
    source => 'puppet:////vagrant/files/etc/icinga/ido2db-mysql.cfg',
    require => [ Package['icinga-idoutils-libdbi-mysql'],
		 File['/etc/sysconfig/ido2db'],
		 Exec['populate-mysql-icinga-idoutils-db']
	       ],
    notify => Service['ido2db']
  }

  exec { 'create-mysql-icinga-idoutils-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => 'mysql -uicinga -picinga icinga',
    command => 'mysql -uroot -e "CREATE DATABASE icinga; GRANT ALL ON icinga.* TO icinga@localhost IDENTIFIED BY \'icinga\';"',
    require => Service['mysqld']
  }

  exec { 'populate-mysql-icinga-idoutils-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => 'mysql -uicinga -picinga icinga -e "SELECT * FROM icinga_dbversion;" &> /dev/null',
    command => 'mysql -uicinga -picinga icinga < /usr/share/doc/icinga-idoutils-libdbi-mysql-$(rpm -q icinga-idoutils-libdbi-mysql | cut -d\'-\' -f5)/db/mysql/mysql.sql',
    require => [ Package['icinga-idoutils-libdbi-mysql'], Exec['create-mysql-icinga-idoutils-db'] ]
  }
  
  service { 'ido2db':
    enable => true,
    ensure => running,
    hasrestart => true,
    alias => 'ido2db',
    require => [ Package['icinga-idoutils-libdbi-mysql'], Exec['populate-mysql-icinga-idoutils-db'] ],
    notify => Service['icinga']
  }
}

