# Demo box for graylog2 & icinga2
# Includes: GelfWriter, check-graylog2-stream
# OSMC demo config
# admin pw: osmcgraylog2icinga2r0xx

include 'epel'

$graylog2_version = "0.91"
$elasticsearch_version = ""

# basic stuff

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
  root_password_sha2         => 'b0991879bea6e9ea67274302acc64d47107c9c2a0b3c28efa8646cb5956323b8',
  elasticsearch_cluster_name => 'graylog2',
  require                    => [
    Elasticsearch::Instance['graylog2-es'],
    Class['mongodb::server'],
    Class['graylog2::repo'],
  ],
} ->
class { 'graylog2::web':
  application_secret => '3eb06615884fec5ae541b8661b430e8da89ed5fddf81c4bdc6a2a714abb9b51d',
  graylog2_server_uris => [ "http://${::ipaddress}:12900/" ],
  require            => Class['graylog2::server'],
}


# Icinga 2
include 'icinga-rpm-snapshot'
include 'icinga2'

file { '/etc/icinga2/conf.d/osmc.conf':
  owner  => icinga,
  group  => icinga,
  source    => 'puppet:////vagrant/files/etc/icinga2/conf.d/osmc.conf',
  require   => Package['icinga2'],
  notify    => Service['icinga2']
} ->
icinga2::feature { 'gelf':
}


