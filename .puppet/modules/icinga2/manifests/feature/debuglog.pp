# == Class: icinga2::feature::debuglog
#
# This module configures the Icinga 2 feature mainlog.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the feature mainlog, absent disables it. Defaults to present.
#
# [*path*]
#   Absolute path to the log file. Default depends on platform:
#   /var/log/icinga2/debug.log on Linux
#   C:/ProgramData/icinga2/var/log/icinga2/debug.log on Windows
#
#
class icinga2::feature::debuglog(
  $ensure   = present,
  $path     = "${::icinga2::params::log_dir}/debug.log",
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
  validate_absolute_path($path)

  # compose attributes
  $attrs = {
    severity => 'debug',
    path     => $path,
  }

  # create object
  icinga2::object { 'icinga2::object::FileLogger::debuglog':
    object_name => 'debug-file',
    object_type => 'FileLogger',
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => "${conf_dir}/features-available/debuglog.conf",
    order       => '10',
    notify      => $_notify,
  }

  # manage feature
  icinga2::feature { 'debuglog':
    ensure => $ensure,
  }
}
