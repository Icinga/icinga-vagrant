# Class: php
#
#   This class installs php.
#
# Parameters:
#
# Actions:
#
# Requires:
#
#   apache
#
# Sample Usage:
#
#   include php
#
class php {
  package { 'php':
    ensure => installed,
    require => Class['apache'],
    notify => Class['Apache::Service']
  }

  file { '/etc/php.d/error_reporting.ini':
    content => template('php/error_reporting.ini.erb'),
    require => Package['php'],
    notify => Class['Apache::Service']
  }

  file { '/etc/php.d/xdebug_settings.ini':
    content => template('php/xdebug_settings.ini.erb'),
    require => Package['php'],
    notify => Class['Apache::Service']
  }
}
