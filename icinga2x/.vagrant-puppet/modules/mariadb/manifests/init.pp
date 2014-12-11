# Class: mariadb
#
#   This class installs the mariadb server and client software.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#   include mariadb
#
class mariadb {

  Exec { path => '/usr/bin' }

  package {
    'mariadb':
      ensure => installed;
    'mariadb-server':
      ensure => installed;
  }

  service { 'mariadb':
    enable => true,
    ensure => running,
    require => Package['mariadb-server']
  }
}
