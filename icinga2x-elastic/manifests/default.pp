include icinga_rpm
include epel
include icinga2
include icinga2_ido_mysql
include icingaweb2
include icingaweb2_internal_db_mysql
include monitoring_plugins

class { 'selinux':
  mode => 'disabled'
}

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

class { 'nginx':
  confd_purge => true,
}

$icingaweb2_fqdn = 'icingaweb2.vagrant-demo.icinga.com'
$icingaweb2_php_fpm_port = 9000

nginx::resource::server { $icingaweb2_fqdn:
  listen_ip           => '192.168.33.7',
  listen_port         => 80,
  ssl                 => false,
  ipv6_listen_port    => 80,
  www_root            => '/usr/share/icingaweb2/public',
  location_cfg_append => {
    'rewrite'             => '^/$ /icingaweb2'
  },
  index_files         => [ 'index.php' ],
}
nginx::resource::location { "${icingaweb2_fqdn}-fastcgi":
  ensure              => present,
  server              => $icingaweb2_fqdn,
  location            => '~ ^/icingaweb2/index\.php(.*)$',
  fastcgi_index       => 'index.php',
  fastcgi_split_path  => '^(.+\.php)(/.+)$',
  fastcgi             => "127.0.0.1:${icingaweb2_php_fpm_port}",
  fastcgi_param       => {
    'SCRIPT_FILENAME'     => '/usr/share/icingaweb2/public/index.php',
    'ICINGAWEB_CONFIGDIR' => '/etc/icingaweb2',
    'REMOTE_USER'         => '$remote_user'
  }
}
nginx::resource::location { "${icingaweb2_fqdn}-public":
  ensure              => present,
  server              => $icingaweb2_fqdn,
  www_root            => '/usr/share/icingaweb2/public',
  location            => '~ ^/icingaweb2(.+)?',
  index_files         => [ 'index.php' ],
  location_cfg_append => {
    'try_files'           => '$1 $uri $uri/ /icingaweb2/index.php$is_args$args'
  }
}
# Avoid favicon.ico not found error messages
# https://nichteinschalten.de/de/icingaweb2-unter-nginx-betreiben/
nginx::resource::location { "${icingaweb2_fqdn}-favicon":
  ensure              => present,
  server              => $icingaweb2_fqdn,
  www_root            => '/usr/share/icingaweb2/public',
  location            => '/favicon.ico',
  location_cfg_append => {
    'log_not_found' => 'off',
    'access_log'    => 'off',
    'expires'       => 'max'
  }
}


package { [ 'scl-utils', 'centos-release-scl' ]:
  ensure => present,
}->
class { '::php::globals':
  config_root => '/etc/opt/rh/rh-php56',
  fpm_pid_file => '/var/opt/rh/rh-php56/run/php-fpm/php-fpm.pid'
}->
class { '::php':
  package_prefix => 'rh-php56-php-', # most important
  config_root_ini => '/etc/opt/rh/rh-php56',
  #config_root_inifile => '/etc/opt/rh/rh-php56/php.ini',
#  cli_inifile => '/etc/opt/rh/rh-php56/php.ini',
#  fpm_config_file => '/etc/opt/rh/rh-php56/php-fpm.conf',
#  fpm_error_log => '/var/opt/rh/rh-php56/log/php-fpm/error.log',
#  fpm_pool_dir => '/etc/opt/rh/rh-php56/php-fpm.d',
#  fpm_service_name => 'rh-php56-php-fpm',

  manage_repos => false,
  fpm => true,
  fpm_package => 'rh-php56-php-fpm',
  fpm_service_name => 'rh-php56-php-fpm',
  fpm_service_enable => true,
  fpm_service_ensure => 'running',
  #fpm_user => 'nginx', #requires to change package permissions, rh-php56 prefers apache
  #fpm_group => 'nginx',
  dev => true,
  composer => true,
  pear => true,
  phpunit => true,
  settings => {
    'PHP/memory_limit' => '256M',
    'Date/date.timezone'      => 'Europe/Berlin',
  },
  extensions => {
    pdo => {},
    mysqlnd => {},
    imagick => {
      provider => pecl,
    }
  },
  require => Class['nginx']
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

# global vars
$kibanaVersion = '5.3.1'
$icingabeatVersion = '1.1.0'
$icingabeatDashboardsChecksum = '9c98cf4341cbcf6d4419258ebcc2121c3dede020'
# keep this in sync with the icingabeat dashboard ids!
# http://192.168.33.7:5601/app/kibana#/dashboard/720f2f20-0979-11e7-a4dd-e96fa284b426
$kibanaDefaultAppId = 'dashboard/720f2f20-0979-11e7-a4dd-e96fa284b426'
$elasticsearchBasicAuthFile = '/etc/nginx/elasticsearch.passwd' # defaults to icinga:icinga

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
    'server.port'                  => 5601,
    'server.host'                  => '127.0.0.1',
    'kibana.index'                 => '.kibana',
    'kibana.defaultAppId'          => "$kibanaDefaultAppId",
    'logging.silent'               => false,
    'logging.quiet'                => false,
    'logging.verbose'              => false,
    'logging.events'               => "{ log: ['info', 'warning', 'error', 'fatal'], response: '*', error: '*' }",
    'elasticsearch.requestTimeout' => 500000,
  },
  require => Class['java']
}->
file { "$elasticsearchBasicAuthFile":
  owner  => root,
  group  => root,
  mode   => '0755',
  source => "puppet:////vagrant/files/$elasticsearchBasicAuthFile",
}->
nginx::resource::server { 'elasticsearch.vagrant-demo.icinga.com':
  listen_ip   => '192.168.33.7',
  listen_port => 9200,
  ssl         => true,
  ssl_port    => 9200,
  ssl_cert    => '/var/lib/icinga2/certs/icinga2-elastic.crt',
  ssl_key     => '/var/lib/icinga2/certs/icinga2-elastic.key',
  ssl_trusted_cert => '/var/lib/icinga2/certs/ca.crt',
  ipv6_listen_port => 9200,
  proxy       => 'http://localhost:9200',
  auth_basic  => 'Elasticsearch auth',
  auth_basic_user_file => "$elasticsearchBasicAuthFile",
  require     => File['/etc/icinga2']
}->
nginx::resource::server { 'kibana.vagrant-demo.icinga.com':
  listen_ip   => '192.168.33.7',
  listen_port => 5601,
  ssl         => true,
  ssl_port    => 5601,
  ssl_cert    => '/var/lib/icinga2/certs/icinga2-elastic.crt',
  ssl_key     => '/var/lib/icinga2/certs/icinga2-elastic.key',
  ssl_trusted_cert => '/var/lib/icinga2/certs/ca.crt',
  ipv6_listen_port => 5601,
  proxy       => 'http://localhost:5601',
  auth_basic  => 'Kibana auth',
  auth_basic_user_file => "$elasticsearchBasicAuthFile",
  require     => File['/etc/icinga2']
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

# icinga2 elasticsearch writer - TODO
#icinga2::feature { 'elasticsearch': }
#->
#file { '/etc/icinga2/features-available':
#  ensure  => 'directory',
#  require => Package['icinga2']
#}->
#file { '/etc/icinga2/features-available/elasticsearch.conf':
#  owner  => icinga,
#  group  => icinga,
#  source    => 'puppet:////vagrant/files/etc/icinga2/features-available/elasticsearch.conf',
#  require   => Package['icinga2'],
#  notify    => Service['icinga2']
#}

## TODO: Add logstash config!

