# == Define: icinga2::object::timeperiod
#
# Manage Icinga 2 timeperiod objects.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disables it. Defaults to present.
#
# [*timeperiod_name*]
#   Set the Icinga 2 name of the timeperiod object. Defaults to title of the define resource.
#
# [*display_name*]
# 	A short description of the time period.
#
# [*import*]
#   Sorted List of templates to include. Defaults to [ "legacy-timeperiod" ].
#
# [*ranges*]
# 	A dictionary containing information which days and durations apply to this
#   timeperiod.
#
# [*prefer_includes*]
# 	Boolean whether to prefer timeperiods includes or excludes. Default to true.
#
# [*excludes*]
# 	An array of timeperiods, which should exclude from your timerange.
#
# [*includes*]
# 	An array of timeperiods, which should include into your timerange
#
# [*template*]
#   Set to true creates a template instead of an object. Defaults to false.
#
# [*target*]
#   Destination config file to store this object in. File will be declared on the first run.
#
# [*order*]
#   String to control the position in the target file, sorted alpha numeric.
#
#
define icinga2::object::timeperiod (
  $target,
  $ensure          = present,
  $timeperiod_name = $title,
  $display_name    = undef,
  $ranges          = undef,
  $prefer_includes = undef,
  $excludes        = undef,
  $includes        = undef,
  $template        = false,
  $import          = ['legacy-timeperiod'],
  $order           = '35',
){
  include ::icinga2::params

  $conf_dir = $::icinga2::params::conf_dir

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_string($timeperiod_name)
  validate_array($import)
  validate_bool($template)
  validate_absolute_path($target)
  validate_string($order)


  if $display_name { validate_string ($display_name) }
  if $ranges { validate_hash ($ranges) }
  if $prefer_includes { validate_bool ($prefer_includes) }
  if $excludes { validate_array ($excludes) }
  if $includes { validate_array ($includes) }

  # compose attributes
  $attrs = {
    'display_name'    => $display_name,
    'ranges'          => $ranges,
    'prefer_includes' => $prefer_includes,
    'excludes'        => $excludes,
    'includes'        => $includes,
  }

  # create object
  icinga2::object { "icinga2::object::TimePeriod::${title}":
    ensure      => $ensure,
    object_name => $timeperiod_name,
    object_type => 'TimePeriod',
    template    => $template,
    import      => $import,
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => $target,
    order       => $order,
    notify      => Class['::icinga2::service'],
  }

}
