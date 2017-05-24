include icinga_rpm
include epel
include icinga2
include icinga2_ido_mysql
include icingaweb2
include icingaweb2_internal_db_mysql
include monitoring_plugins

#class { 'selinux':
#  mode => 'disabled'
#}

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
# Icinga Web 2 Modules
####################################

# Demo config required by the modules
file { '/etc/icinga2/demo':
  ensure => directory,
  recurse => true,
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/demo",
  require   => File['/etc/icinga2/icinga2.conf'],
  notify    => Service['icinga2']
}

####################################
# BP
####################################

file { 'check_mysql_health':
  name => '/usr/lib64/nagios/plugins/check_mysql_health',
  owner => root,
  group => root,
  mode => '0755',
  source    => 'puppet:////vagrant/files/usr/lib64/nagios/plugins/check_mysql_health',
  require => Class['monitoring_plugins'],
}

# ensure that the icinga user is in the icingaweb2 group for executing the icingacli_businessprocess commands
@user { icinga: ensure => present }
User<| title == icinga |>{
  groups +> ['icingaweb2'],
  require => [ Package['icinga2'], Package['icingaweb2'] ]
}

icingaweb2::module { 'businessprocess':
  builtin => false
}

file { '/etc/icingaweb2/modules/businessprocess':
  ensure => directory,
  recurse => true,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  source    => "puppet:////vagrant/files/etc/icingaweb2/modules/businessprocess",
  require => Package['icingaweb2']
}

####################################
# GenericTTS
####################################

icingaweb2::module { 'generictts':
  builtin => false
}

file { '/etc/icingaweb2/modules/generictts':
  ensure => directory,
  recurse => true,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  source    => "puppet:////vagrant/files/etc/icingaweb2/modules/generictts",
  require => Package['icingaweb2']
}

file { 'feed-tts-comments':
  name => '/usr/local/bin/feed-tts-comments',
  owner => root,
  group => root,
  mode => '0755',
  source => "puppet:////vagrant/files/usr/local/bin/feed-tts-comments",
}

exec { 'feed-tts-comments-host':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => "/usr/local/bin/feed-tts-comments",
  require => [ File['feed-tts-comments'], Service['icinga2'] ],
}

####################################
# NagVis
####################################

include nagvis

icingaweb2::module { 'nagvis':
  builtin => false
}

file { 'nagvis-link-css-styles':
  ensure  => 'link',
  path    => '/usr/local/nagvis/share/userfiles/styles/icingaweb-nagvis-integration.css',
  target  => '/usr/share/icingaweb2/modules/nagvis/public/css/icingaweb-nagvis-integration.css',
  require => [ Class['nagvis'], File["$::icingaweb2::config_dir/enabledModules/nagvis"] ]
}

file { 'nagvis-core-functions-index.php':
  ensure  => 'present',
  path    => '/usr/local/nagvis/share/server/core/functions/index.php',
  source  => 'puppet:////vagrant/files/usr/local/nagvis/share/server/core/functions/index.php',
  mode    => '644',
  owner   => 'apache',
  group   => 'apache',
  require => Class['nagvis::config']
}

####################################
# Director
####################################

icingaweb2::module { 'director':
  builtin => false
}
->
exec { 'fix-binary-blog-bug-zend-655':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => 'sed -i \'s/$value = addcslashes/\/\/$value = addcslashes/\' /usr/share/php/Zend/Db/Adapter/Pdo/Abstract.php'
}
->
# ship box specific director module config
file {'/etc/icingaweb2/modules/director':
  ensure => directory,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  require => [ Package['icingaweb2'], File['/etc/icingaweb2/modules'] ]
} ->
file { '/etc/icingaweb2/modules/director/config.ini':
  ensure => file,
  owner => root,
  group => icingaweb2,
  mode => '2770',
  source => 'puppet:////vagrant/files/etc/icingaweb2/modules/director/config.ini', #TODO use hiera and templates
  require => File['/etc/icingaweb2/modules/director']
}->
exec { 'create-mysql-icingaweb2-director-db':
  #TODO: move this to a dedicated subclass
  path        => '/bin:/usr/bin:/sbin:/usr/sbin',
  unless      => 'mysql -udirector -pdirector director',
  command     => 'mysql -uroot -e "CREATE DATABASE director; GRANT ALL ON director.* TO director@localhost IDENTIFIED BY \'director\';"',
  user        => 'root',
  environment => [ "HOME=/root" ],
  require     => Service['mariadb']
}->
exec { 'Icinga Director DB migration':
  path    => '/usr/local/bin:/usr/bin:/bin',
  command => 'icingacli director migration run',
  onlyif  => 'icingacli director migration pending',
  require => Package['icingacli'],
}->
file { '/etc/icingaweb2/modules/director/kickstart.ini':
  ensure => file,
  owner => root,
  group => icingaweb2,
  mode => '2770',
  source => 'puppet:////vagrant/files/etc/icingaweb2/modules/director/kickstart.ini', #TODO use hiera and templates
  require => File['/etc/icingaweb2/modules/director']
}->
exec { 'Icinga Director Kickstart':
  path    => '/usr/local/bin:/usr/bin:/bin',
  command => 'icingacli director kickstart run',
  onlyif  => 'icingacli director kickstart required',
  require => [ Service['icinga2'], Exec['enable-icinga2-api'] ]
}

####################################
# More Icinga Web 2 modules
####################################

icingaweb2::module { 'cube':
  builtin => false
}

icingaweb2::module { 'globe':
  builtin => false,
  repo_url => 'https://github.com/Mikesch-mp/icingaweb2-module-globe'
}

####################################
# Dashing
####################################

package { [ 'rubygems', 'rubygem-bundler',
            'ruby-devel', 'openssl', 'gcc-c++',
            'make', 'nodejs', 'v8'
           ]:
  ensure => 'installed',
  require => Class['epel']
}->
vcsrepo { '/usr/share/dashing-icinga2':
  ensure   => 'present',
  path     => '/usr/share/dashing-icinga2',
  provider => 'git',
  revision => 'master',
  source   => 'https://github.com/Icinga/dashing-icinga2.git',
  force    => true,
  require  => Package['git']
}->
exec { 'dashing-bundle-install':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => "cd /usr/share/dashing-icinga2 && bundle install --jobs 4 --system", # this already installs the dashing binary
  timeout => 1800
}->
file { '/usr/lib/systemd/system/dashing-icinga2.service':
  owner  => root,
  group  => root,
  mode   => '0644',
  source	=> '/usr/share/dashing-icinga2/tools/systemd/dashing-icinga2.service',
}
->
exec { 'dashing-reload-systemd':
  command     => 'systemctl daemon-reload',
  path        => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
  refreshonly => true,
}
->
service { 'dashing-icinga2':
  provider => 'systemd',
  ensure => running,
  enable => true,
  hasstatus => true,
  hasrestart => true,
  require => Service['icinga2'],
}


####################################
# Graphite
####################################

icinga2::feature { 'graphite': }

# 0.9.14 requires pytz: https://github.com/graphite-project/graphite-web/issues/1019
package { 'pytz':
  ensure => 'installed',
  require => Class['epel']
}

# avoid a bug in the pip provider
# https://github.com/echocat/puppet-graphite/issues/180
file { 'pip-symlink':
  ensure	=> symlink,
  path	=> '/usr/bin/pip-python',
  target	=> '/usr/bin/pip',
  before	=> Class['graphite'],
}

file { '/opt/graphite':
  ensure => directory
}->
apache::vhost { 'graphite.localdomain':
  port    => '8003',
  docroot => '/opt/graphite/webapp',
  wsgi_application_group      => '%{GLOBAL}',
  wsgi_daemon_process         => 'graphite',
  wsgi_daemon_process_options => {
    processes          => '5',
    threads            => '5',
    display-name       => '%{GROUP}',
    inactivity-timeout => '120',
  },
  wsgi_import_script          => '/opt/graphite/conf/graphite_wsgi.py',
  wsgi_import_script_options  => {
    process-group     => 'graphite',
    application-group => '%{GLOBAL}'
  },
  wsgi_process_group          => 'graphite',
  wsgi_script_aliases         => {
    '/' => '/opt/graphite/conf/graphite_wsgi.py'
  },
  headers => [
    'set Access-Control-Allow-Origin "*"',
    'set Access-Control-Allow-Methods "GET, OPTIONS, POST"',
    'set Access-Control-Allow-Headers "origin, authorization, accept"',
  ],
  directories => [{
    path => '/media/',
  }
  ]
}->
# workaround for EPEL rename of python-pip to python2-pip, http://smoogespace.blogspot.de/2016/12/why-are-epel-python-packages-getting.html
# pip also requires additional packages: http://graphite.readthedocs.io/en/latest/install-pip.html
package { [ 'python2-pip',
	    'python-devel',
	    'cairo-devel',
	    'libffi-devel',
	    'gcc' ]:
  ensure => 'installed',
  require => Class['epel']
}->
class { 'graphite':
  gr_apache_24            => true,
  gr_web_server           => 'none',
  gr_web_user             => 'apache',
  gr_web_group            => 'apache',
  gr_disable_webapp_cache => true,
  secret_key => 'ICINGA2ROCKS',
  gr_pip_install => true,
  gr_manage_python_packages => false, #workaround for EPEL rename of python-pip to python2-pip
  gr_graphite_ver => '0.9.14',
  gr_carbon_ver => '0.9.14',
  gr_whisper_ver => '0.9.14',
  gr_twisted_ver => '13.2.0', # 0.9.14 carbon-cache requirement
  gr_timezone => 'Europe/Berlin',
  gr_max_updates_per_second => 10000,
  gr_max_creates_per_minute => 1000,
  gr_storage_schemas => [
    {
      name       => 'carbon',
      pattern    => '^carbon\.',
      retentions => '1m:90d'
    },
    {
      name       => 'icinga2_default',
      pattern    => '^icinga2\.',
      retentions => '1m:2d,5m:10d,30m:90d,360m:4y'
    },
    {
      name       => 'default',
      pattern    => '.*',
      retentions => '1m:14d'
    }
  ],
}

####################################
# Grafana
####################################

# https://github.com/bfraser/puppet-grafana
class { 'grafana':
  package_source => 'https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.2.0-1.x86_64.rpm',
  cfg => {
    app_mode => 'production',
    server   => {
      http_port     => 8004,
    },
    users    => {
      allow_sign_up => false,
    },
    security => {
      admin_user => 'admin',
      admin_password => 'admin',
    },
  },
}
->
# there are no static config files for data sources in grafana2
# https://github.com/grafana/grafana/issues/1789
file { 'grafana-setup':
  name => '/usr/local/bin/grafana-setup',
  owner => root,
  group => root,
  mode => '0755',
  source => "puppet:////vagrant/files/usr/local/bin/grafana-setup",
}
->
file { 'grafana-dashboard-icinga2':
  name => '/etc/icinga2/grafana-dashboard-icinga2.json',
  owner => root,
  group => root,
  mode => '0644',
  source => "puppet:////vagrant/files/etc/icinga2/grafana-dashboard-icinga2.json",
}
->
file { 'grafana-dashboard-graphite-base-metrics':
  name => '/etc/icinga2/graphite-base-metrics.json',
  owner => root,
  group => root,
  mode => '0644',
  source => "puppet:////vagrant/files/etc/icinga2/graphite-base-metrics.json",
}->
file { 'grafana-dashboard-graphite-icinga2-default':
  name => '/etc/icinga2/graphite-icinga2-default.json',
  owner => root,
  group => root,
  mode => '0644',
  source => "puppet:////vagrant/files/etc/icinga2/graphite-icinga2-default.json",
}
->
exec { 'finish-grafana-setup':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => "/usr/local/bin/grafana-setup",
  require => [ Class['graphite'], Class['grafana::service'] ],
  notify => Class['apache::service']
}

####################################
# Icinga Web 2 Grafana Module
####################################

icingaweb2::module { 'grafana':
  builtin => false,
  repo_url => 'https://github.com/Mikesch-mp/icingaweb2-module-grafana'
}->
file { '/etc/icingaweb2/modules/grafana':
  ensure => directory,
  recurse => true,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  source    => "puppet:////vagrant/files/etc/icingaweb2/modules/grafana",
  require => [ Package['icingaweb2'], File['/etc/icingaweb2/modules'] ]
}

####################################
# Clippy.js
####################################

vcsrepo { '/var/www/html/icinga2-api-examples':
  ensure   => 'present',
  path     => '/var/www/html/icinga2-api-examples',
  provider => 'git',
  revision => 'master',
  source   => 'https://github.com/Icinga/icinga2-api-examples.git',
  force    => true,
  require  => Package['git']
}
