####################################
# Global configuration
####################################

$hostOnlyIP = '192.168.33.5'
$hostOnlyFQDN = 'icinga2x.vagrant.demo.icinga.com'
$graphiteListenPort = 8003
$grafanaListenPort = 8004

####################################
# Setup
####################################

class { '::profiles::base::system': }
->
class { '::profiles::base::mysql': }
->
class { '::profiles::base::apache': }
->
class { '::profiles::icinga::icinga2':
  features => [ "graphite" ]
}
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN,
  modules => {
    "grafana" => {
      "datasource"  => "graphite",
      "listen_ip"   => $hostOnlyIP,
      "listen_port" => $grafanaListenPort
    }
  }
}
->
class { '::profiles::graphite::server':
  listen_ip   => $hostOnlyIP,
  listen_port => $graphiteListenPort
}
->
class { '::profiles::grafana::server':
  listen_port => $grafanaListenPort,
  version => '4.2.0-1',
  backend => "graphite"
}
#->
#class { '::profiles::dashing::icinga2': }


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
