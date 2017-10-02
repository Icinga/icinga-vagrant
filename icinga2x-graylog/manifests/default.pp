# Demo box for Graylog & icinga2
# Includes: GelfWriter, check-graylog2-stream
# OSMC demo config
# admin pw: admin

include icinga_rpm
include epel
include icinga2
include icinga2_ido_mysql
include icingaweb2
include icingaweb2_internal_db_mysql
include monitoring_plugins

####################################
# Database
####################################

$mysql_server_override_options = {}

class { '::mysql::server':
  root_password => 'icingar0xx',
  remove_default_accounts => true,
  override_options => $mysql_server_override_options
}

####################################
# Webserver
####################################

class {'apache':
  # don't purge php, icingaweb2, etc configs
  purge_configs => false,
  default_vhost => false
}

class {'::apache::mod::php': }

apache::vhost { 'vagrant-demo.icinga.com':
  priority        => 5,
  port            => '80',
  docroot         => '/var/www/html',
  rewrites => [
    {
      rewrite_rule => ['^/$ /icingaweb2 [NE,L,R=301]'],
    },
  ],
}

apache::vhost { 'vagrant-demo.icinga.com-ssl':
  priority        => 5,
  port            => '443',
  docroot         => '/var/www/html',
  ssl		  => true,
  add_listen      => false, #prevent duplicate listen entries
  rewrites => [
    {
      rewrite_rule => ['^/$ /icingaweb2 [NE,L,R=301]'],
    },
  ],
}
include '::php::cli'
include '::php::mod_php5'

php::module { [ 'mbstring' ]: }

php::ini { '/etc/php.ini':
  display_errors => 'On',
  memory_limit => '256M',
  date_timezone => 'Europe/Berlin',
  session_save_path => '/var/lib/php/session'
}

####################################
# Misc
####################################
# fix puppet warning.
# https://ask.puppetlabs.com/question/6640/warning-the-package-types-allow_virtual-parameter-will-be-changing-its-default-value-from-false-to-true-in-a-future-release/
if versioncmp($::puppetversion,'3.6.1') >= 0 {
  $allow_virtual_packages = hiera('allow_virtual_packages',false)
  Package {
    allow_virtual => $allow_virtual_packages,
  }
}

package { [ 'mailx', 'tree', 'gdb', 'git', 'bash-completion', 'screen', 'htop' ]:
  ensure => 'installed',
  require => Class['epel']
}

@user { vagrant: ensure => present }
User<| title == vagrant |>{
  groups +> ['icinga', 'icingacmd'],
  require => Package['icinga2']
}

file { '/etc/motd':
  source => 'puppet:////vagrant/files/etc/motd',
  owner => root,
  group => root
}

file { '/etc/profile.d/env.sh':
  source => 'puppet:////vagrant/files/etc/profile.d/env.sh'
}

# Required by vim-icinga2
class { 'vim':
  opt_bg_shading => 'light',
}

####################################
# Icinga 2 General
####################################

file { '/etc/icinga2':
  ensure  => 'directory',
  require => Package['icinga2']
}

file { '/etc/icinga2/icinga2.conf':
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/icinga2.conf",
  require   => File['/etc/icinga2'],
  notify    => Service['icinga2']
}

file { "/etc/icinga2/zones.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/zones.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

file { '/etc/icinga2/conf.d/hosts.conf':
  owner  => icinga,
  group  => icinga,
  source    => 'puppet:////vagrant/files/etc/icinga2/conf.d/hosts.conf',
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

file { '/etc/icinga2/conf.d/additional_services.conf':
  owner  => icinga,
  group  => icinga,
  source    => 'puppet:////vagrant/files/etc/icinga2/conf.d/additional_services.conf',
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# api
exec { 'enable-icinga2-api':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => 'icinga2 api setup',
  require => Package['icinga2'],
  notify  => Service['icinga2']
}

file { '/etc/icinga2/conf.d/api-users.conf':
  owner  => icinga,
  group  => icinga,
  content   => template("icinga2/api-users.conf.erb"),
  require   => [ Package['icinga2'], Exec['enable-icinga2-api'] ],
  notify    => Service['icinga2']
}

####################################
# Icinga Web 2
####################################


####################################
# Icinga Web 2 Modules
####################################

# Demo config required by the modules
file { '/etc/icinga2/demo':
  ensure => directory,
  recurse => true,
  owner  => icinga,
  group  => icinga,
#  source    => "puppet:////vagrant/files/etc/icinga2/demo",
  require   => File['/etc/icinga2/icinga2.conf'],
  notify    => Service['icinga2']
}


####################################
# Graylog
####################################

class { 'java':
  version => 'latest',
  distribution => 'jdk'
}

# Elasticsearch
file { '/etc/security/limits.d/99-elasticsearch.conf':
  ensure  => present,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => "elasticsearch soft nofile 64000\nelasticsearch hard nofile 64000\n",
} ->
class { 'elasticsearch':
  manage_repo  => true,
  repo_version => '5.x',
  java_install => false,
  jvm_options => [
    '-Xms256m',
    '-Xmx256m'
  ],
  require => Class['java']
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
$graylogAddress = '192.168.33.6'

class { 'graylog::repository':
  version => '2.3'
}->
class { 'graylog::server':
  #package_version => '2.3.0-3.alpha.3',
  config                       => {
    'password_secret'          => '0CDCipdUvE3cSPN8OXARpAKU6bO9N41DuVNEMD95KyPgI3oGExLJiiZdy57mwpbqrvXqta5C2yaARe2tLPpmTfos47QOoBDP',
    'root_password_sha2'       => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
    'rest_listen_uri'          => "http://$graylogAddress:9000/api/",
    'web_listen_uri'           => "http://$graylogAddress:9000/",
    'web_endpoint_uri'         => "http://$graylogAddress:9000/api/",
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

file { '/etc/icinga2/demo/graylog2-demo.conf':
  owner  => icinga,
  group  => icinga,
  content   => template("icinga2/graylog2-demo.conf.erb"),
  require   => [ Package['icinga2'], File['/etc/icinga2/demo'] ],
  notify    => Service['icinga2']
} ->
icinga2::feature { 'gelf':
}

#file { '/usr/lib64/nagios/plugins/check-graylog-stream':
#  ensure => symlink,
#  target => '/usr/lib/nagios/plugins/check-graylog2-stream',
#  force => true,
#  replace => true,
#  #require => [ Package['check-graylog2-stream'], Class['monitoring_plugins'] ]
#  require => [ Class['monitoring_plugins'] ]
#}

# TODO: Install Graylog Beats input and use icingabeat with Graylog.

# icingabeat
#yum::install { 'icingabeat':
#  ensure => present,
#  source => "https://github.com/Icinga/icingabeat/releases/download/v$icingabeatVersion/icingabeat-$icingabeatVersion-x86_64.rpm"
#}->
#file { '/etc/icingabeat/icingabeat.yml':
#  owner  => root,
#  group  => root,
#  source    => 'puppet:////vagrant/files/etc/icingabeat/icingabeat.yml',
#}->
#service { 'icingabeat':
#  ensure => running
#}


