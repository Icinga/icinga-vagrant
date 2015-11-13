
class pnp4nagios::config {

  #  include pnp4nagios::params
  $monitoring_type = $pnp4nagios::params::monitoring_type
  $log_type = $pnp4nagios::params::log_type
  $debug_lvl = $pnp4nagios::params::debug_lvl
  $perfdata_spool_dir = $pnp4nagios::params::perfdata_spool_dir

  file { 'npcdcfg':
    name => '/etc/pnp4nagios/npcd.cfg',
    owner => root,
    group => root,
    mode => '0644',
    notify => Class[pnp4nagios::service],
    content => template('pnp4nagios/npcd.cfg.erb'),
  }

  file { 'php_config':
    name => '/etc/pnp4nagios/config.php',
    owner => root,
    group => root,
    mode => '0644',
    notify => Class[pnp4nagios::service],
    content => template('pnp4nagios/config.php.erb'),
  }

  file { '/var/log/pnp4nagios':
    ensure => directory,
    owner => $monitoring_type,
    group => $monitoring_type,
    mode => '0775',
  }

  file { '/var/log/pnp4nagios/kohana':
    ensure => directory,
    owner => $monitoring_type,
    group => $monitoring_type,
    mode => '0775',
  }

  file { '/var/log/pnp4nagios/stats':
    ensure => directory,
    owner => $monitoring_type,
    group => $monitoring_type,
    mode => '0775',
  }

  file { '/var/lib/pnp4nagios':
    ensure => directory,
    owner => $monitoring_type,
    group => $monitoring_type,
    mode => '0775',
  }

  file { '/var/spool/pnp4nagios':
    ensure => directory,
    owner => $monitoring_type,
    group => $monitoring_type,
    mode => '0775',
  }

}

