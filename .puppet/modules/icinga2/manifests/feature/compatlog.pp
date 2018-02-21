# == Class: icinga2::feature::compatlog
#
# This module configures the Icinga 2 feature compatlog.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the feature compatlog, absent disabled it. Defaults to present.
#
# [*log_dir*]
#   Absolute path to the log directory. Default depends on platform, /var/log/icinga2/compat on Linux
#   and C:/ProgramData/icinga2/var/log/icinga2/compat on Windows.
#
# [*rotation_method*]
#   Sets how often should the log file be rotated. Valid options are: HOURLY, DAILY, WEEKLY or MONTHLY.
#   Defaults to DAILY.
#
#
class icinga2::feature::compatlog(
  $ensure          = present,
  $log_dir         = "${::icinga2::params::log_dir}/compat",
  $rotation_method = 'DAILY',
) {

  if ! defined(Class['::icinga2']) {
    fail('You must include the icinga2 base class before using any icinga2 feature class!')
  }

  $conf_dir = $::icinga2::params::conf_dir
  $_notify  = $ensure ? {
    'present' => Class['::icinga2::service'],
    default   => undef,
  }

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_absolute_path($log_dir)
  validate_re($rotation_method, ['^HOURLY$','^DAILY$','^WEEKLY$','^MONTHLY$'])

  # compose attributes
  $attrs = {
    log_dir         => $log_dir,
    rotation_method => $rotation_method,
  }

  # create object
  icinga2::object { 'icinga2::object::CompatLogger::compatlog':
    object_name => 'compatlog',
    object_type => 'CompatLogger',
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => "${conf_dir}/features-available/compatlog.conf",
    order       => '10',
    notify      => $_notify,
  }

  # import library 'compat'
  concat::fragment { 'icinga2::feature::compatlog':
    target  => "${conf_dir}/features-available/compatlog.conf",
    content => "library \"compat\"\n\n",
    order   => '05',
  }

  # manage feature
  icinga2::feature { 'compatlog':
    ensure => $ensure,
  }
}
