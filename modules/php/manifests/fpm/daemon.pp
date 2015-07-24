# Class: php::fpm::daemon
#
# Install the PHP FPM daemon. See php::fpm::conf for configuring its pools.
#
# Sample Usage:
#  include php::fpm::daemon
#
class php::fpm::daemon (
  $ensure                      = 'present',
  $package_name                = $::php::params::fpm_package_name,
  $service_name                = $::php::params::fpm_service_name,
  $service_restart             = $::php::params::fpm_service_restart,
  $fpm_pool_dir                = $::php::params::fpm_pool_dir,
  $fpm_conf_dir                = $::php::params::fpm_conf_dir,
  $error_log                   = $::php::params::fpm_error_log,
  $pid                         = $::php::params::fpm_pid,
  $syslog_facility             = 'daemon',
  $syslog_ident                = 'php-fpm',
  $log_level                   = 'notice',
  $emergency_restart_threshold = '0',
  $emergency_restart_interval  = '0',
  $process_control_timeout     = '0',
  $process_max                 = undef,
  $process_priority            = undef,
  $rlimit_files                = undef,
  $rlimit_core                 = undef,
  $log_owner                   = 'root',
  $log_group                   = false,
  $log_dir_mode                = '0770',
) inherits ::php::params {

  # Hack-ish to default to user for group too
  $log_group_final = $log_group ? {
    false   => $log_owner,
    default => $log_group,
  }

  package { $package_name: ensure => $ensure }

  if ( $ensure != 'absent' ) {

    service { $service_name:
      ensure    => 'running',
      enable    => true,
      restart   => "service ${service_name} ${service_restart}",
      hasstatus => true,
      require   => Package[$package_name],
    }

    # When running FastCGI, we don't always use the same user
    file { '/var/log/php-fpm':
      ensure  => 'directory',
      owner   => $log_owner,
      group   => $log_group_final,
      mode    => $log_dir_mode,
      require => Package[$package_name],
    }

    file { "${fpm_conf_dir}/php-fpm.conf":
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('php/fpm/php-fpm.conf.erb'),
      require => Package[$package_name],
      notify  => Service[$service_name],
    }

  }

}

