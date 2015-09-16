# Demo box for Graylog & icinga2
# Includes: GelfWriter, check-graylog2-stream
# OSMC demo config
# admin pw: admin

include epel

$graylog_version = "1.1"
$elasticsearch_version = ""

# basic stuff
# fix puppet warning.
# https://ask.puppetlabs.com/question/6640/warning-the-package-types-allow_virtual-parameter-will-be-changing-its-default-value-from-false-to-true-in-a-future-release/
if versioncmp($::puppetversion,'3.6.1') >= 0 {
  $allow_virtual_packages = hiera('allow_virtual_packages',false)
  Package {
    allow_virtual => $allow_virtual_packages,
  }
}

package { [ 'vim-enhanced', 'mailx', 'tree', 'gdb', 'rlwrap', 'git' ]:
  ensure => 'installed',
  require => Class['Epel']
}

# Webserver

class {'apache':
  # don't purge php, icingaweb2, etc configs
  purge_configs => false,
}

class {'::apache::mod::php': }

include '::php::cli'
include '::php::mod_php5'

php::ini { '/etc/php.ini':
  display_errors => 'On',
  memory_limit => '256M',
  date_timezone => 'Europe/Berlin',
  session_save_path => '/var/lib/php/session'
}

# Elasticsearch
file { '/etc/security/limits.d/99-elasticsearch.conf':
  ensure  => present,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => "elasticsearch soft nofile 64000\nelasticsearch hard nofile 64000\n",
} ->
class { 'java':
} ->
class { 'elasticsearch':
  version      => '1.3.4-1',
  manage_repo  => true,
  repo_version => '1.3',
  java_install => false,
} ->
elasticsearch::instance { 'graylog-es':
  config => {
    'cluster.name' => 'graylog',
    'network.host' => '127.0.0.1'
  },
  init_defaults => {
    'ES_HEAP_SIZE' => '256m',
  },
}

# MongoDB
class { '::mongodb::globals':
  manage_package_repo => true,
} ->
class { '::mongodb::server': }


# Graylog
class { 'graylog2::repo':
  version => $graylog_version,
} ->
class { 'graylog2::server':
  service_enable	     => true,
  service_ensure	     => true,
  rest_enable_cors           => true,
  rest_listen_uri            => "http://${::ipaddress}:12900/",
  rest_transport_uri         => "http://${::ipaddress}:12900/",
  elasticsearch_discovery_zen_ping_multicast_enabled => false,
  elasticsearch_discovery_zen_ping_unicast_hosts     => '127.0.0.1:9300',
  elasticsearch_network_host => '127.0.0.1',
  password_secret            => '3eb06615884fec5ae541b8661b430e8da89ed5fddf81c4bdc6a2a714abb9b51d',
  root_password_sha2         => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
  elasticsearch_cluster_name => 'graylog',
  java_opts                  => '-Xms256m -Xmx512m -XX:NewRatio=1 -XX:PermSize=128m -XX:MaxPermSize=256m -server -XX:+ResizeTLAB -XX:+UseConcMarkSweepGC -XX:+CMSConcurrentMTEnabled -XX:+CMSClassUnloadingEnabled -XX:+UseParNewGC -XX:-OmitStackTraceInFastThrow',
  require                    => [
    Elasticsearch::Instance['graylog-es'],
    Class['mongodb::server'],
    Class['graylog2::repo'],
  ],
} ->
class { 'graylog2::web':
  application_secret => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
  graylog2_server_uris => [ "http://${::ipaddress}:12900/" ],
  require            => Class['graylog2::server'],
  timeout            => '60s',
} ->
# check-graylog2-stream
package { 'check-graylog2-stream':
  ensure => '1.2-1',
  require => Class['graylog2::server']
} ->
file { '/usr/lib/nagios/plugins/check-graylog2-stream-wrapper':
  ensure  => present,
  owner   => 'root',
  group   => 'root',
  mode    => '0555',
  source  => 'file:///vagrant/scripts/check-graylog2-stream-wrapper.sh',
}


# Icinga 2
class { 'icinga_rpm':
  pkg_repo_version => 'release'
}

include '::mysql::server'
include icinga2
include icinga2_ido_mysql
include icingaweb2
include icingaweb2_internal_db_mysql
include monitoring_plugins

file { '/etc/icinga2/conf.d/demo.conf':
  owner  => icinga,
  group  => icinga,
  content   => template("icinga2/graylog2-demo.conf.erb"),
  require   => Package['icinga2'],
  notify    => Service['icinga2']
} ->
icinga2::feature { 'gelf':
} ->
file { '/usr/lib/nagios/plugins/check-graylog-stream':
  ensure => symlink,
  target => '/usr/lib64/nagios/plugins/check-graylog2-stream',
  force => true,
  replace => true,
  require => [ Package['check-graylog2-stream'], Class['monitoring_plugins'] ]
}
