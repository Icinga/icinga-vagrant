# Demo box for graylog2 & icinga2
# Includes: GelfWriter, check-graylog2-stream
# OSMC demo config
# admin pw: admin

include 'epel'

$graylog2_version = "0.91"
$elasticsearch_version = ""

exec { "disable selinux on $hostname":
  user    => "root",
  command => "/usr/sbin/setenforce 0",
  unless  => "/usr/sbin/sestatus | /bin/egrep -q '(Current mode:.*permissive|SELinux.*disabled)'";
}


# basic stuff
# fix puppet warning.
# https://ask.puppetlabs.com/question/6640/warning-the-package-types-allow_virtual-parameter-will-be-changing-its-default-value-from-false-to-true-in-a-future-release/
if versioncmp($::puppetversion,'3.6.1') >= 0 {
  $allow_virtual_packages = hiera('allow_virtual_packages',false)
  Package {
    allow_virtual => $allow_virtual_packages,
  }
}


# firewall: TODO add support for other OS unlike CentOS7
case $operatingsystem {
  centos, redhat: {
    if $operatingsystemrelease =~ /^7.*/ {

      package { 'firewalld':
        ensure => installed
      }
      service { 'firewalld':
        ensure => running,
        enable => true,
        hasstatus => true,
        hasrestart => true,
        require => Package['firewalld']
      }

      exec { 'iptables-graylog2-001':
        path => '/bin:/usr/bin:/sbin:/usr/sbin',
        command => 'firewall-cmd --permanent --zone=public --add-port=80/tcp',
        require   => Package['firewalld']
      } ->
      exec { 'iptables-graylog2-002':
        path => '/bin:/usr/bin:/sbin:/usr/sbin',
        command => 'firewall-cmd --permanent --zone=public --add-port=9000/tcp'
      } ->
      exec { 'iptables-graylog2-003':
        path => '/bin:/usr/bin:/sbin:/usr/sbin',
        command => 'firewall-cmd --permanent --zone=public --add-port=9300/tcp'
      } ->
      exec { 'iptables-graylog2-004':
        path => '/bin:/usr/bin:/sbin:/usr/sbin',
        command => 'firewall-cmd --permanent --zone=public --add-port=12201/tcp'
      } ->
      exec { 'iptables-graylog2-005':
        path => '/bin:/usr/bin:/sbin:/usr/sbin',
        command => 'firewall-cmd --permanent --zone=public --add-port=12201/udp'
      } ->
      exec { 'iptables-graylog2-006':
        path => '/bin:/usr/bin:/sbin:/usr/sbin',
        command => 'firewall-cmd --permanent --zone=public --add-port=12900/tcp',
        notify    => Service['firewalld']

      }
    }
  }
}


# Elasticsearch
class { 'elasticsearch':
#  version      => '1.3.4',
  manage_repo  => true,
  repo_version => '1.0',
  java_install => true,
} ->
elasticsearch::instance { 'graylog2-es':
  config => {
    'cluster.name' => 'graylog2',
  },
}

# MongoDB
class { '::mongodb::globals':
  manage_package_repo => true,
} ->
class { '::mongodb::server': }


# Graylog2
class { 'graylog2::repo':
  version => $graylog2_version,
  # hardcode centos6, as they don't have el7 yet
  baseurl => "https://packages.graylog2.org/repo/el/6/${graylog2_version}/x86_64/"
} ->
class { 'graylog2::server':
  service_enable	     => true,
  service_ensure	     => true,
  rest_enable_cors           => true,
  rest_listen_uri            => "http://${::ipaddress}:12900/",
  rest_transport_uri         => "http://${::ipaddress}:12900/",
  elasticsearch_discovery_zen_ping_multicast_enabled => false,
  elasticsearch_discovery_zen_ping_unicast_hosts     => '127.0.0.1:9300',
  password_secret            => '3eb06615884fec5ae541b8661b430e8da89ed5fddf81c4bdc6a2a714abb9b51d',
  root_password_sha2         => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
  elasticsearch_cluster_name => 'graylog2',
  require                    => [
    Elasticsearch::Instance['graylog2-es'],
    Class['mongodb::server'],
    Class['graylog2::repo'],
  ],
} ->
class { 'graylog2::web':
  application_secret => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
  graylog2_server_uris => [ "http://${::ipaddress}:12900/" ],
  require            => Class['graylog2::server'],
} ->
# check-graylog2-stream
package { 'check-graylog2-stream':
  ensure => latest,
  require => Class['graylog2::server']
}


# Icinga 2
include 'icinga-rpm-snapshot'
include 'icinga2'

file { '/etc/icinga2/conf.d/demo.conf':
  owner  => icinga,
  group  => icinga,
  content   => template("icinga2/demo.conf.erb"),
  require   => Package['icinga2'],
  notify    => Service['icinga2']
} ->
icinga2::feature { 'gelf':
} ->
package { 'nagios-plugins-all':
  ensure => latest,
  require => Package['icinga2']
} ->
file { '/usr/lib/nagios/plugins/check-graylog-stream':
  ensure => symlink,
  target => '/usr/lib64/nagios/plugins/check-graylog2-stream',
  force => true,
  replace => true,
  require => Package['check-graylog2-stream']
}

package { 'httpd':
  ensure => installed
} ->
service { 'httpd':
  ensure => running
}

package { 'icinga2-classicui-config':
  ensure => latest,
  before => Package["icinga-gui"],
  require => [ Class['icinga-rpm-snapshot'], Package['httpd'] ],
  notify => Service['httpd']
} ->
package { 'icinga-gui':
  ensure => latest,
  alias => 'icinga-gui'
} ->
group { 'icingacmd':
  ensure => present
} ->
user { 'icinga':
  ensure => present,
  groups => 'icingacmd',
  managehome => false
} ->
User<| title == apache |>{ groups +> ['icingacmd', 'vagrant'] } ->
icinga2::feature { 'statusdata': } ->
icinga2::feature { 'compatlog': } ->
icinga2::feature { 'command': }

