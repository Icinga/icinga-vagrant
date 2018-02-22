# == Class: icinga2::feature::statusdata
#
# This module configures the Icinga 2 feature statusdata.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the feature statusdata, absent disables it. Defaults to present.
#
# [*status_path*]
#   Absolute path to the status.dat file. Default depends on platform:
#   /var/cache/icinga2/status.dat on Linux
#   C:/ProgramData/icinga2/var/cache/icinga2/status.dat on Windows
#
# [*object_path*]
#   Absolute path to the object.cache file. Default depends on platform:
#   /var/cache/icinga2/object.cache on Linux
#   C:/ProgramData/icinga2/var/cache/icinga2/object.cache on Windows
#
# [*update_interval*]
#   Interval in seconds to update both status files.
#   You can also specify it in minutes with the letter m or in seconds with s. Defaults to '15s'
#
#
class icinga2::feature::statusdata(
  $ensure          = present,
  $status_path     = "${::icinga2::params::cache_dir}/status.dat",
  $objects_path    = "${::icinga2::params::cache_dir}/objects.cache",
  $update_interval = '15s',
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
  validate_absolute_path($status_path)
  validate_absolute_path($objects_path)
  validate_re($update_interval, '^\d+[ms]*$')

  # compose attributes
  $attrs = {
    status_path     => $status_path,
    objects_path    => $objects_path,
    update_interval => $update_interval,
  }

  # create object
  icinga2::object { 'icinga2::object::StatusDataWriter::statusdata':
    object_name => 'statusdata',
    object_type => 'StatusDataWriter',
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => "${conf_dir}/features-available/statusdata.conf",
    order       => '10',
    notify      => $_notify,
  }

  # import library 'compat'
  concat::fragment { 'icinga2::feature::statusdata':
    target  => "${conf_dir}/features-available/statusdata.conf",
    content => "library \"compat\"\n\n",
    order   => '05',
  }

  # manage feature
  icinga2::feature { 'statusdata':
    ensure => $ensure,
  }
}
