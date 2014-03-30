# Class: snmp
#
#   This class installs the snmp server and client software.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#   include snmp
#
class snmp {

  Exec { path => '/usr/bin' }

  package {
    'net-snmp':
      ensure => installed;
    'net-snmp-perl':
      ensure => installed;
    'perl-Net-SNMP':
      ensure => installed;
  }

  service { 'snmpd':
    enable => true,
    ensure => running,
    require => Package['net-snmp']
  }

  file { '/etc/snmp/snmpd.conf':
    content => template('snmp/snmpd.conf.erb'),
    require => Package['net-snmp'],
    notify => Service['snmpd']
  }
}
