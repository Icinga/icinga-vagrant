# == Define: icinga2::object::compatlogger
#
# Manage Icinga 2 CompatLogger objects.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disables it. Defaults to present.
#
# [compatlogger_name*]
#   Set the Icinga 2 name of the compatlogger object. Defaults to title of the define resource.
#
# [*spool_dir*]
#   The directory which contains the check result files. Defaults to LocalStateDir + "/lib/icinga2/spool/checkresults/".
#
# [*target*]
#   Destination config file to store in this object. File will be declared the
#   first time.
#
# [*order*]
#   String to set the position in the target file, sorted alpha numeric. Defaults to 30.
#
#
define icinga2::object::compatlogger (
  $target,
  $ensure            = present,
  $compatlogger_name = $title,
  $log_dir           = undef,
  $rotation_method   = undef,
  $order             = '5',
){
  include ::icinga2::params

  $conf_dir = $::icinga2::params::conf_dir

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_string($compatlogger_name)
  validate_absolute_path($target)
  validate_string($order)

  if $log_dir { validate_absolute_path($log_dir) }
  if $rotation_method {
    validate_re($rotation_method, [ '^HOURLY$', '^DAILY$', '^WEEKLY$', '^MONTHLY$' ],
      "${rotation_method} isn't supported. Valid values are 'HOURLY', 'DAILY', 'WEEKLY' and 'MONTHLY'.")
  }

  # compose the attributes
  $attrs = {
    'log_dir'         => $log_dir,
    'rotation_method' => $rotation_method,
  }

  # create object
  icinga2::object { "icinga2::object::CompatLogger::${title}":
    ensure      => $ensure,
    object_name => $compatlogger_name,
    object_type => 'CompatLogger',
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => $target,
    order       => $order,
    notify      => Class['::icinga2::service'],
  }

  # import library
  concat::fragment { "icinga2::object::CompatLogger::${title}-library":
    target  => $target,
    content => "library \"compat\"\n\n",
    order   => '05',
  }
}
