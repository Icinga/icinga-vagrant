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

package { [ 'mailx', 'tree', 'gdb', 'rlwrap', 'git', 'bash-completion', 'screen', 'htop', 'unzip' ]:
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

# enable the command pipe
icinga2::feature { 'command': }

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

# user-defined preferences (using the iframe module)
file { '/etc/icingaweb2/preferences':
  ensure => directory,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  require => Package['icingaweb2']
}

file { '/etc/icingaweb2/preferences/icingaadmin':
  ensure => directory,
  recurse => true,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  source    => "puppet:////vagrant/files/etc/icingaweb2/preferences/icingaadmin",
  require => [ Package['icingaweb2'], File['/etc/icingaweb2/preferences'] ]
}

# user-defined dashboards for the default 'icingaadmin' user
file { '/etc/icingaweb2/dashboards':
  ensure => directory,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  require => Package['icingaweb2']
}

file { '/etc/icingaweb2/dashboards/icingaadmin':
  ensure => directory,
  recurse => true,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  source    => "puppet:////vagrant/files/etc/icingaweb2/dashboards/icingaadmin",
  require => [ Package['icingaweb2'], File['/etc/icingaweb2/dashboards'] ]
}

# present icinga2 in icingaweb2's module documentation
file { '/usr/share/icingaweb2/modules/icinga2':
  ensure => 'directory',
  require => Package['icingaweb2']
}

file { '/usr/share/icingaweb2/modules/icinga2/doc':
  ensure => 'link',
  target => '/usr/share/doc/icinga2/markdown',
  require => [ Package['icinga2'], Package['icingaweb2'], File['/usr/share/icingaweb2/modules/icinga2'] ],
}

file { '/etc/icingaweb2/enabledModules/icinga2':
  ensure => 'link',
  target => '/usr/share/icingaweb2/modules/icinga2',
  require => File['/etc/icingaweb2/enabledModules'],
}

####################################
# Elastic
####################################

$kibanaVersion = '5.2.2'

class { 'java':
  version => 'latest',
  distribution => 'jdk'
}

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
elasticsearch::instance { 'elastic-es':
  config => {
    'cluster.name' => 'elastic',
    'network.host' => '127.0.0.1'
  }
}->
class { 'kibana':
  ensure => "$kibanaVersion-1",
  config => {
    'server.port' => 5601,
    'server.host' => '0.0.0.0',
    'kibana.index' => '.kibana',
    'kibana.defaultAppId' => 'discover',
    'logging.silent'               => false,
    'logging.quiet'                => false,
    'logging.verbose'              => false,
    'logging.events'               => "{ log: ['info', 'warning', 'error', 'fatal'], response: '*', error: '*' }",
    'elasticsearch.requestTimeout' => 500000,
  },
  require => Class['java']
}->
class { 'filebeat':
  outputs => {
    'elasticsearch' => {
      'hosts' => [
        'http://localhost:9200'
      ],
      'index' => 'filebeat'
    }
  },
  logging => {
    'level' => 'debug' #TODO reset after finishing the box
  }
}->
file { 'kibana-setup':
  name => '/usr/local/bin/kibana-setup',
  owner => root,
  group => root,
  mode => '0755',
  source => "puppet:////vagrant/files/usr/local/bin/kibana-setup",
}
->
exec { 'finish-kibana-setup':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => "/usr/local/bin/kibana-setup",
  timeout => 3600
}

######## TODO: The Logstash class does not properly include Java and therefore fails to provision.

#package { 'java-1.8.0-openjdk':
#  ensure => 'present'
#}
#class { 'logstash':
#  manage_repo  => true,
#  auto_upgrade => false,
#  version => '5.2.2-1', # version and revision are required for now
##  require => Class['java']
#  require => Package['java-1.8.0-openjdk'] # this is ugly
#}
#->
#logstash::plugin { 'logstash-input-beats':
#  require => Anchor['java::end']
#}
#->
#logstash::plugin { 'logstash-input-udp':
#  require => Anchor['java::end']
#}
#->
#logstash::plugin { 'logstash-input-tcp':
#  require => Anchor['java::end']
#}
#->
#logstash::plugin { 'logstash-codec-json':
#  require => Anchor['java::end']
#}

# icingabeat
$icingabeatVersion = '1.1.0'
$icingabeatDashboardsChecksum = '9c98cf4341cbcf6d4419258ebcc2121c3dede020'

yum::install { 'icingabeat':
  ensure => present,
  source => "https://github.com/Icinga/icingabeat/releases/download/v$icingabeatVersion/icingabeat-$icingabeatVersion-x86_64.rpm"
}->
file { '/etc/icingabeat/icingabeat.yml':
  owner  => root,
  group  => root,
  source    => 'puppet:////vagrant/files/etc/icingabeat/icingabeat.yml',
}->
service { 'icingabeat':
  ensure => running
}->
# https://github.com/icinga/icingabeat#dashboards
archive { '/tmp/icingabeat-dashboards.zip':
  ensure => present,
  extract => true,
  extract_path => '/tmp',
  source => "https://github.com/Icinga/icingabeat/releases/download/v$icingabeatVersion/icingabeat-dashboards-$icingabeatVersion.zip",
  checksum => "$icingabeatDashboardsChecksum",
  checksum_type => 'sha1',
  creates => "/tmp/icingabeat-dashboards-$icingabeatVersion",
  cleanup => true,
  require => Package['unzip']
}->
exec { 'icingabeat-kibana-dashboards':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => "/usr/share/icingabeat/scripts/import_dashboards -dir /tmp/icingabeat-dashboards-$icingabeatVersion -es http://127.0.0.1:9200",
  require => Exec['finish-kibana-setup']
}->
exec { 'icingabeat-kibana-default-index-pattern':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => "curl -XPUT http://127.0.0.1:9200/.kibana/config/$kibanaVersion -d '{ \"defaultIndex\":\"icingabeat-*\" }'",
}

# filebeat
filebeat::prospector { 'syslogs':
  paths => [
    '/var/log/messages'
  ],
  doc_type => 'syslog-beat'
}
filebeat::prospector { 'icinga2logs':
  paths => [
    '/var/log/icinga2/icinga2.log'
  ],
  doc_type => 'syslog-beat'
}

# icinga2 logstash writer - TODO
#icinga2::feature { 'logstash': }
#->
#file { '/etc/icinga2/features-available':
#  ensure  => 'directory',
#  require => Package['icinga2']
#}->
#file { '/etc/icinga2/features-available/logstash.conf':
#  owner  => icinga,
#  group  => icinga,
#  source    => 'puppet:////vagrant/files/etc/icinga2/features-available/logstash.conf',
#  require   => Package['icinga2'],
#  notify    => Service['icinga2']
#}

## TODO: Add logstash config!

