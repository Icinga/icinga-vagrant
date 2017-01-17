# Class: mysql
#
#   This class installs the mysql server and client software.
#
#   Copyright (C) 2013-present Icinga Development Team (http://www.icinga.com/)
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#   include mysql
#
class mysql {

  $mysqlRootPassword = 'password'

  Exec { path => '/usr/bin' }

  package {
    'mysql':
      ensure => installed;
    'mysql-server':
      ensure => installed;
  }

  service { 'mysqld':
    enable => true,
    ensure => running,
    require => Package['mysql-server']
  }

  exec {"setmysqlpassword":
    command => "mysqladmin -u root PASSWORD ${mysqlRootPassword}; /bin/true",
    require => [Package["mysql-server"], Package["mysql"] , Service["mysqld"]],
  }

  file { '/etc/my.cnf':
    content => template('mysql/my.cnf.erb'),
    require => Package['mysql-server'],
    notify => Service['mysqld']
  }

  file { [ '/root/.my.cnf', '/home/vagrant/.my.cnf']:
    content => template('mysql/.my.cnf.erb'),
    require => Package['mysql-server'],
    notify => Service['mysqld']
  }
}
