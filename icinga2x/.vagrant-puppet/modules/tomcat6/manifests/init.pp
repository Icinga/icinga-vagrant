# Class: tomcat6
#
#   Install tomcat6
#
#   Copyright (C) 2014-present Icinga Development Team (http://www.icinga.org/)
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#   include tomcat6
#

class tomcat6 (
  $tomcat_user = '',
  $java_opts = '-Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC',
  $lang = 'en_US') {
  include tomcat6::params

  if $tomcat_user == '' {
    $tomcat_user_internal = $tomcat6::params::tomcat_user
  } else {
    $tomcat_user_internal = $tomcat_user
  }

  Package['tomcat6'] -> File[$tomcat6::params::tomcat_settings] -> Service['tomcat6']

  package { 'tomcat6':
    ensure => installed
  }

  file { $tomcat6::params::tomcat_settings:
    ensure => present,
    content => template('tomcat6/tomcat6.erb')
  }

  exec { 'iptables-allow-http-8080':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => 'grep -Fxqe "-A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT" /etc/sysconfig/iptables',
    command => 'firewall-cmd --permanent --add-service=http-alt; firewall-cmd --add-service=http-alt'
  }

  service { 'tomcat6':
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true
  }
}
