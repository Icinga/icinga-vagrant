include icinga_rpm
include epel
include '::mysql::server'
include '::postgresql::server'
include icinga2
include icinga2_ido_mysql
include icinga2_classicui
include icinga2_icinga_web
include icingaweb2
include icingaweb2_internal_db_mysql
include monitoring_plugins

####################################
# Webserver
####################################

class {'apache':
  # don't purge php, icingaweb2, etc configs
  purge_configs => false,
  default_vhost => false
}

class {'::apache::mod::php': }

apache::vhost { 'vagrant-demo.icinga.org':
  priority        => 5,
  port            => '80',
  docroot         => '/var/www/html',
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

# leftover, purge them
file { [ '/var/www/html/index.html', '/var/www/html/icinga_wall.png' ]:
  ensure => 'absent'
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

package { [ 'vim-enhanced', 'mailx', 'tree', 'gdb', 'rlwrap', 'git', 'bash-completion' ]:
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

file { [ '/root/.vim',
       '/root/.vim/syntax',
       '/root/.vim/ftdetect' ] :
  ensure    => 'directory'
}

exec { 'copy-vim-syntax-file':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => 'cp -f /usr/share/doc/icinga2-common-$(rpm -q icinga2-common | cut -d\'-\' -f3)/syntax/vim/syntax/icinga2.vim /root/.vim/syntax/icinga2.vim',
  require => [ Package['vim-enhanced'], Package['icinga2-common'], File['/root/.vim/syntax'] ]
}

exec { 'copy-vim-ftdetect-file':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => 'cp -f /usr/share/doc/icinga2-common-$(rpm -q icinga2-common | cut -d\'-\' -f3)/syntax/vim/ftdetect/icinga2.vim /root/.vim/ftdetect/icinga2.vim',
  require => [ Package['vim-enhanced'], Package['icinga2-common'], File['/root/.vim/syntax'] ]
}

####################################
# Icinga 2 General
####################################

file { '/etc/icinga2':
  ensure    => 'directory',
  require => Package['icinga2']
}

file { '/etc/icinga2/icinga2.conf':
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/icinga2.conf",
  require   => File['/etc/icinga2']
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
  require => Package['icinga2']
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

# user-defined dashboards for the default 'icingaadmin' user
file { '/etc/icingaweb2/dashboards/icingaadmin':
  ensure => directory,
  recurse => true,
  owner  => root,
  group  => icingaweb2,
  mode => '2770',
  source    => "puppet:////vagrant/files/etc/icingaweb2/dashboards/icingaadmin",
  require => Package['icingaweb2']
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
# PNP
####################################

include pnp4nagios

icinga2::feature { 'perfdata': }

icingaweb2::module { 'pnp4nagios':
  builtin => false
}

# override the default httpd config w/o basic auth

file { 'httpd_config':
  name => '/etc/httpd/conf.d/pnp4nagios.conf',
  owner => root,
  group => root,
  mode => '0644',
  content => template('pnp4nagios/pnp4nagios.conf.erb'),
  require => Class['apache'],
  notify => Class['apache::service'],
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

file { '/etc/icinga2/bp':
  ensure => directory,
  recurse => true,
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/bp",
  require   => File['/etc/icinga2/icinga2.conf'],
  notify    => Service['icinga2']
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

