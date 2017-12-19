# == Class: icinga2::feature::command
#
# This module configures the Icinga 2 feature command.
#
# === Parameters
#
# [*ensure*]
#   Set to present to enable the feature command, absent to disabled it. Defaults to present.
#
# [*command_path*]
#   Absolute path to the command pipe. Default depends on platform, /var/run/icinga2/cmd/icinga2.cmd on Linux
#   and C:/ProgramData/icinga2/var/run/icinga2/cmd/icinga2.cmd on Windows.
#
#
class icinga2::feature::command(
  $ensure       = present,
  $command_path = "${::icinga2::params::run_dir}/cmd/icinga2.cmd",
) {

  if ! defined(Class['::icinga2']) {
    fail('You must include the icinga2 base class before using any icinga2 feature class!')
  }

  $conf_dir = $::icinga2::params::conf_dir
  $_notify  = $ensure ? {
    'present' => Class['::icinga2::service'],
    default   => undef,
  }

  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_absolute_path($command_path)

  # compose attributes
  $attrs = {
    command_path => $command_path,
  }

  # create object
  icinga2::object { 'icinga2::object::ExternalCommandListener::command':
    object_name => 'command',
    object_type => 'ExternalCommandListener',
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => "${conf_dir}/features-available/command.conf",
    order       => '10',
    notify      => $_notify,
  }

  # import library 'compat'
  concat::fragment { 'icinga2::feature::command':
    target  => "${conf_dir}/features-available/command.conf",
    content => "library \"compat\"\n\n",
    order   => '05',
  }

  # manage feature
  icinga2::feature { 'command':
    ensure => $ensure,
  }
}
