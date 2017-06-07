# Demo box for Graylog & icinga2
# Includes: GelfWriter, check-graylog2-stream
# OSMC demo config
# admin pw: admin

include epel

class { 'selinux':
  mode => 'disabled'
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

package { [ 'mailx', 'tree', 'gdb', 'rlwrap', 'git' ]:
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
  version => 'latest',
  distribution => 'jdk'
} ->
class { 'elasticsearch':
  manage_repo  => true,
  repo_version => '5.x',
  java_install => false,
  jvm_options => [
    '-Xms256m',
    '-Xmx256m'
  ],
} ->
elasticsearch::instance { 'graylog-es':
  config => {
    'cluster.name' => 'graylog',
    'network.host' => '127.0.0.1'
  },
}

# MongoDB
class { '::mongodb::globals':
  manage_package_repo => true,
} ->
class { '::mongodb::server': }


# Graylog
class { 'graylog::repository':
  version => '2.3'
}->
class { 'graylog::server':
  package_version => '2.3.0-3.alpha.3',
  config                       => {
    'password_secret'          => '0CDCipdUvE3cSPN8OXARpAKU6bO9N41DuVNEMD95KyPgI3oGExLJiiZdy57mwpbqrvXqta5C2yaARe2tLPpmTfos47QOoBDP',
    'root_password_sha2'       => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
    'rest_listen_uri'          => "http://${::ipaddress}:9000/api/",
    'web_listen_uri'           => "http://${::ipaddress}:9000/",
    'web_endpoint_uri'         => "http://localhost:9000/api/",
    'versionchecks'            => false,
    'usage_statistics_enabled' => false,
  },
  require => Class['::java'],
} ->
exec { 'download-check-graylog2-stream':
  command => '/usr/bin/wget -O /var/tmp/check-graylog2-stream.tar.gz https://github.com/graylog-labs/check-graylog2-stream/releases/download/1.4/check-graylog2-stream.linux_x86.tar.gz',
  creates => '/var/tmp/check-graylog2-stream.tar.gz',
} ->
exec { 'extract-check-graylog2-stream':
  command => '/usr/bin/tar -C /usr/lib64/nagios/plugins -xzf /var/tmp/check-graylog2-stream.tar.gz',
  creates => '/usr/lib64/nagios/plugins/check-graylog2-stream',
} ->
file { '/usr/lib64/nagios/plugins/check-graylog2-stream':
  ensure  => present,
  owner   => 'root',
  group   => 'root',
  mode    => '0555',
} ->
file { '/usr/lib/nagios':
  ensure  => directory,
  owner   => 'root',
  group   => 'root',
  mode    => '0555',
} ->
file { '/usr/lib/nagios/plugins':
  ensure  => directory,
  owner   => 'root',
  group   => 'root',
  mode    => '0555',
} ->
file { '/usr/lib/nagios/plugins/check-graylog2-stream-wrapper':
  ensure  => present,
  owner   => 'root',
  group   => 'root',
  mode    => '0555',
  source  => 'file:///vagrant/scripts/check-graylog2-stream-wrapper.sh',
}


# Icinga 2
include icinga_rpm
include icinga2
include icinga2_ido_mysql
include icingaweb2
include icingaweb2_internal_db_mysql
include monitoring_plugins

# Required by vim-icinga2
class { 'vim':
  opt_bg_shading => 'light',
}

$mysql_server_override_options = {}

class { '::mysql::server':
  root_password => 'icingar0xx',
  remove_default_accounts => true,
  override_options => $mysql_server_override_options
}

file { '/etc/icinga2/conf.d/api-users.conf':
  owner  => icinga,
  group  => icinga,
  content   => template("icinga2/api-users.conf.erb"),
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

file { '/etc/icinga2/conf.d/demo.conf':
  owner  => icinga,
  group  => icinga,
  content   => template("icinga2/graylog2-demo.conf.erb"),
  require   => Package['icinga2'],
  notify    => Service['icinga2']
} ->
icinga2::feature { 'gelf':
}# ->
#file { '/usr/lib64/nagios/plugins/check-graylog-stream':
#  ensure => symlink,
#  target => '/usr/lib/nagios/plugins/check-graylog2-stream',
#  force => true,
#  replace => true,
#  #require => [ Package['check-graylog2-stream'], Class['monitoring_plugins'] ]
#  require => [ Class['monitoring_plugins'] ]
#}
