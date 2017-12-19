# == Class: icinga2::feature::mainlog
#
# This module configures the Icinga 2 feature mainlog.
#
# === Parameters
#
# [*ensure*]
#   Set to 'present' enables the feature mainlog, 'absent' disabled it. Defaults to 'present'.
#
# [*severity*]
#   You can set the log severity to 'information', 'notice', 'warning' or 'debug'. Defaults to 'information'.
#
# [*path*]
#   Absolute path to the log file. Default depends on platform, '/var/log/icinga2/icinga2.log' on Linux
#   and 'C:/ProgramData/icinga2/var/log/icinga2/icinga2.log' on Windows.
#
#
class icinga2::feature::mainlog(
  $ensure   = present,
  $severity = 'information',
  $path     = "${::icinga2::params::log_dir}/icinga2.log",
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
  validate_re($severity, ['^information$','^notice$','^warning$','^debug$'])
  validate_absolute_path($path)

  # compose attributes
  $attrs = {
    severity => $severity,
    path     => $path,
  }

  # create object
  icinga2::object { 'icinga2::object::FileLogger::mainlog':
    object_name => 'main-log',
    object_type => 'FileLogger',
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => "${conf_dir}/features-available/mainlog.conf",
    order       => '10',
    notify      => $_notify,
  }

  # manage feature
  icinga2::feature { 'mainlog':
    ensure      => $ensure,
  }

}
