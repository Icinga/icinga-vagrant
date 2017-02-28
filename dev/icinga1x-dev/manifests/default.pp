include epel
include icinga_rpm
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
      rewrite_rule => ['^/$ /icinga [NE,L,R=301]'],
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
      rewrite_rule => ['^/$ /icinga [NE,L,R=301]'],
    },
  ],
}
include '::php::cli'
include '::php::mod_php5'

php::module { [ 'ldap', 'xml', 'pear', 'pdo', 'soap', 'gd', 'mysql' ]: }

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

$icinga_dev_pkg = [ 'gcc', 'autoconf', 'glibc', 'glibc-common', 'gd', 'gd-devel', 'libpng', 'libpng-devel',
			'libdbi', 'libdbi-devel', 'libdbi-drivers', 'libdbi-dbd-mysql' ]

package { [ 'mailx',
		'yum-utils',
		'tree',
		'gdb',
		'git',
		'bash-completion',
		'screen',
		'htop'
		]:
  ensure => 'installed',
  require => Class['epel']
}->
package { $icinga_dev_pkg:
  ensure => 'installed',
  require => Class['epel']
}

group { [ 'icinga', 'icingacmd' ]: ensure => present }
user { [ 'vagrant', 'icinga' ] : ensure => present }
User<| title == vagrant |>{
  groups +> ['icinga', 'icingacmd'],
  require => Group['icinga']
}
User<| title == $::apache::params::user |>{
  groups +> ['icinga', 'icingacmd'],
  require => Group['icinga']
}

# misc
file { '/etc/motd':
  source => 'puppet:////vagrant/files/etc/motd',
  owner => root,
  group => root
}

file { '/etc/profile.d/env.sh':
  source => 'puppet:////vagrant/files/etc/profile.d/env.sh'
}

class { 'vim':
  opt_bg_shading => 'light',
}

# dev tools



