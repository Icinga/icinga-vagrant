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

####################################
# Basic stuff
####################################
# fix puppet warning.
# https://ask.puppetlabs.com/question/6640/warning-the-package-types-allow_virtual-parameter-will-be-changing-its-default-value-from-false-to-true-in-a-future-release/
if versioncmp($::puppetversion,'3.6.1') >= 0 {
  $allow_virtual_packages = hiera('allow_virtual_packages',false)
  Package {
    allow_virtual => $allow_virtual_packages,
  }
}

package { [ 'mailx', 'tree', 'gdb', 'rlwrap', 'git', 'bash-completion' ]:
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

# enable the command pipe
icinga2::feature { 'command': }

# override constants conf and set NodeName
file { "/etc/icinga2/constants.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/constants.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# Icinga 2 Cluster

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

file { '/etc/icinga2/pki':
  owner  => icinga,
  group  => icinga,
  ensure    => 'directory',
  require => Package['icinga2']
}

file { '/etc/icinga2/pki/ca.crt':
  owner  => icinga,
  group  => icinga,
  source    => 'puppet:////vagrant/files/etc/icinga2/pki/ca.crt',
  require   => File['/etc/icinga2/pki']
}

file { "/etc/icinga2/pki/$hostname.crt":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/pki/$hostname.crt",
  require   => File['/etc/icinga2/pki']
}

file { "/etc/icinga2/pki/$hostname.key":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/pki/$hostname.key",
  require   => File['/etc/icinga2/pki']
}


exec { 'icinga2-enable-feature-api':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => 'icinga2 feature enable api',
  require => File['/etc/icinga2/features-available/api.conf'],
  notify => Service['icinga2']
}

# required for icinga2-enable-feature-api
file { "/etc/icinga2/features-available/api.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/features-available/api.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

file { '/etc/icinga2/cluster/api-users.conf':
  owner  => icinga,
  group  => icinga,
  content   => template("icinga2/api-users.conf.erb"),
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# local cluster health checks
file { '/etc/icinga2/cluster':
  owner  => icinga,
  group  => icinga,
  ensure    => 'directory',
  require => Package['icinga2']
}

file { "/etc/icinga2/cluster/$hostname.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/cluster/$hostname.conf",
  require   => [ File['/etc/icinga2/cluster'], Exec['icinga2-enable-feature-api'] ],
  notify    => Service['icinga2']
}

# remote client
file { '/etc/icinga2/remote':
  owner  => icinga,
  group  => icinga,
  ensure => present,
  source    => 'puppet:////vagrant/files/etc/icinga2/remote',
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

####################################
# Icinga 2 Cluster Zones
####################################

file { "/etc/icinga2/zones.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/files/etc/icinga2/zones.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# zones
file { '/etc/icinga2/zones.d':
  owner  => icinga,
  group  => icinga,
  ensure => present,
  source    => 'puppet:////vagrant/files/etc/icinga2/zones.d',
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# remove leftovers from previous runs
file { [ '/var/lib/icinga2/api/zones/master', '/var/lib/icinga2/api/zones/checker', '/var/lib/icinga2/api/zones/global-templates' ]:
  force  => true,
  ensure => absent
}

case $hostname {
  'icinga2a': {
    # remote client
    file { '/etc/icinga2/remote/demo.conf':
      owner  => icinga,
      group  => icinga,
      source    => 'puppet:////vagrant/files/etc/icinga2/remote/demo.conf',
      require   => File['/etc/icinga2/remote'],
      notify    => Service['icinga2']
    }

    # cluster
    file { '/etc/icinga2/zones.d/master':
      owner  => icinga,
      group  => icinga,
      ensure => directory,
      recurse => true,
      source    => "puppet:////vagrant/files/etc/icinga2/zones.d/master",
      require   => File['/etc/icinga2/zones.d'],
      notify    => Service['icinga2']
    }
    file { '/etc/icinga2/zones.d/checker':
      owner  => icinga,
      group  => icinga,
      ensure => directory,
      recurse => true,
      source    => "puppet:////vagrant/files/etc/icinga2/zones.d/checker",
      require   => File['/etc/icinga2/zones.d'],
      notify    => Service['icinga2']
    }
    file { '/etc/icinga2/zones.d/global-templates':
      owner  => icinga,
      group  => icinga,
      ensure => directory,
      recurse => true,
      source    => "puppet:////vagrant/files/etc/icinga2/zones.d/global-templates",
      require   => File['/etc/icinga2/zones.d'],
      notify    => Service['icinga2']
    }
  }

  default: { # icinga2{b,c} and more other instances not being the config master
    ['master', 'checker', 'global-templates'].each |String $cfgdir| {
      file { "/etc/icinga2/zones.d/${cfgdir}":
        ensure => absent,
        require   => File['/etc/icinga2/zones.d'],
        notify    => Service['icinga2']
      }
    }
  }
}
