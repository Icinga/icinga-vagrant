####################################
# Global configuration
####################################

$hostOnlyIP = '192.168.33.5'
$hostOnlyFQDN = 'icinga2x.vagrant.demo.icinga.com'
$graphitePort = 8003

####################################
# Setup
####################################

class { '::profiles::base::system': }
->
class { '::profiles::base::mysql': }
->
class { '::profiles::base::apache': }
->
class { '::profiles::icinga::icinga2': }
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN
}
->
class { '::profiles::graphite::icinga2':
  listen_port => $graphitePort
}

icinga2::feature { 'graphite': }
#->
#class { '::profiles::dashing::icinga2': }


#file { '/etc/icinga2/icinga2.conf':
#  owner  => icinga,
#  group  => icinga,
#  source    => "puppet:////vagrant/files/etc/icinga2/icinga2.conf",
#  notify    => Service['icinga2']
#}
#->
#file { "/etc/icinga2/zones.conf":
#  owner  => icinga,
#  group  => icinga,
#  source    => "puppet:////vagrant/files/etc/icinga2/zones.conf",
#  notify    => Service['icinga2']
#}
#->
#file { '/etc/icinga2/conf.d/hosts.conf':
#  owner  => icinga,
#  group  => icinga,
#  source    => 'puppet:////vagrant/files/etc/icinga2/conf.d/hosts.conf',
#  notify    => Service['icinga2']
#}
#->
#file { '/etc/icinga2/conf.d/additional_services.conf':
#  owner  => icinga,
#  group  => icinga,
#  source    => 'puppet:////vagrant/files/etc/icinga2/conf.d/additional_services.conf',
#  notify    => Service['icinga2']
#}
#->
## user-defined preferences (using the iframe module)
#file { '/etc/icingaweb2/preferences':
#  ensure => directory,
#  owner  => root,
#  group  => icingaweb2,
#  mode => '2770',
#}
#->
#file { '/etc/icingaweb2/preferences/icingaadmin':
#  ensure => directory,
#  recurse => true,
#  owner  => root,
#  group  => icingaweb2,
#  mode => '2770',
#  source    => "puppet:////vagrant/files/etc/icingaweb2/preferences/icingaadmin",
#}
#->
## user-defined dashboards for the default 'icingaadmin' user
#file { '/etc/icingaweb2/dashboards':
#  ensure => directory,
#  owner  => root,
#  group  => icingaweb2,
#  mode => '2770',
#}
#->
#file { '/etc/icingaweb2/dashboards/icingaadmin':
#  ensure => directory,
#  recurse => true,
#  owner  => root,
#  group  => icingaweb2,
#  mode => '2770',
#  source    => "puppet:////vagrant/files/etc/icingaweb2/dashboards/icingaadmin",
#}
#->
####################################
# Icinga Web 2 Modules
####################################


####################################
# BP
####################################
#->
## ensure that the icinga user is in the icingaweb2 group for executing the icingacli_businessprocess commands
#@user { icinga: ensure => present }
#User<| title == icinga |>{
#  groups +> ['icingaweb2'],
#}
#->
#icingaweb2::module { 'businessprocess':
#  builtin => false
#}
#->
#file { '/etc/icingaweb2/modules/businessprocess':
#  ensure => directory,
#  recurse => true,
#  owner  => root,
#  group  => icingaweb2,
#  mode => '2770',
#  source    => "puppet:////vagrant/files/etc/icingaweb2/modules/businessprocess",
#}
####################################
# GenericTTS
####################################

#icingaweb2::module { 'generictts':
#  builtin => false
#}
#->
#file { '/etc/icingaweb2/modules/generictts':
#  ensure => directory,
#  recurse => true,
#  owner  => root,
#  group  => icingaweb2,
#  mode => '2770',
#  source    => "puppet:////vagrant/files/etc/icingaweb2/modules/generictts",
#}
#->
#file { 'feed-tts-comments':
#  name => '/usr/local/bin/feed-tts-comments',
#  owner => root,
#  group => root,
#  mode => '0755',
#  source => "puppet:////vagrant/files/usr/local/bin/feed-tts-comments",
#}
#->
#exec { 'feed-tts-comments-host':
#  path => '/bin:/usr/bin:/sbin:/usr/sbin',
#  command => "/usr/local/bin/feed-tts-comments",
#}
#->
####################################
# NagVis
####################################

#class { '::nagvis': }
#->
#icinga2::feature { 'livestatus': }
#->
#icingaweb2::module { 'nagvis':
#  builtin => false
#}
#->
#file { 'nagvis-link-css-styles':
#  ensure  => 'link',
#  path    => '/usr/local/nagvis/share/userfiles/styles/icingaweb-nagvis-integration.css',
#  target  => '/usr/share/icingaweb2/modules/nagvis/public/css/icingaweb-nagvis-integration.css',
#}
#->
#file { 'nagvis-core-functions-index.php':
#  ensure  => 'present',
#  path    => '/usr/local/nagvis/share/server/core/functions/index.php',
#  source  => 'puppet:////vagrant/files/usr/local/nagvis/share/server/core/functions/index.php',
#  mode    => '644',
#  owner   => 'apache',
#  group   => 'apache',
#}
#->

####################################
# More Icinga Web 2 modules
####################################

#icingaweb2::module { 'cube':
#  builtin => false
#}
#->
#icingaweb2::module { 'globe':
#  builtin => false,
#  repo_url => 'https://github.com/Mikesch-mp/icingaweb2-module-globe'
#}
#->
#icingaweb2::module { 'map':
#  builtin => false,
#  repo_url => 'https://github.com/nbuchwitz/icingaweb2-module-map'
#}->
#file { '/etc/icingaweb2/modules/map':
#  ensure => directory,
#  recurse => true,
#  owner  => root,
#  group  => icingaweb2,
#  mode => '2770',
#  source    => "puppet:////vagrant/files/etc/icingaweb2/modules/map",
#}
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
  notify => Class['apache::service']
}

####################################
# Icinga Web 2 Grafana Module
####################################
#->
#icingaweb2::module { 'grafana':
#  builtin => false,
#  repo_url => 'https://github.com/Mikesch-mp/icingaweb2-module-grafana'
#}->
#file { '/etc/icingaweb2/modules/grafana':
#  ensure => directory,
#  recurse => true,
#  owner  => root,
#  group  => icingaweb2,
#  mode => '2770',
#  source    => "puppet:////vagrant/files/etc/icingaweb2/modules/grafana",
#}
#
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
