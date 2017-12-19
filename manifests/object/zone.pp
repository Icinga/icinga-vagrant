# == Define: icinga2::object::zone
#
# Manage Icinga 2 zone objects.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disables it. Defaults to present.
#
# [*zone_name*]
#   Set the Icinga 2 name of the zone object. Defaults to title of the define resource.
#
# [*endpoints*]
#   List of endpoints belong to this zone.
#
# [*parent*]
#   Parent zone to this zone.
#
# [*global*]
#   If set to true, a global zone is defined and the parameter endpoints
#   and parent are ignored. Defaults to false.
#
# [*target*]
#   Destination config file to store in this object. File will be declared at the
#   first time.
#
# [*order*]
#   String to control the position in the target file, sorted alpha numeric.
#
#
define icinga2::object::zone(
  $ensure    = present,
  $zone_name = $title,
  $endpoints = [],
  $parent    = undef,
  $global    = false,
  $target    = undef,
  $order     = '45',
) {

  include ::icinga2::params

  $conf_dir = $::icinga2::params::conf_dir

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_string($zone_name)
  validate_integer($order)

  if $endpoints { validate_array($endpoints) }
  if $parent { validate_string($parent) }
  if $global { validate_bool($global) }

  # set defaults and validate
  if $target {
    validate_absolute_path($target)
    $_target = $target }
  else {
    $_target = "${conf_dir}/zones.conf" }

  validate_string($order)

  # compose the attributes
  if $global {
    $attrs = {
      global    => $global,
    }
  } else {
    $attrs = {
      endpoints => $endpoints,
      parent    => $parent,
    }
  }

  # create object
  icinga2::object { "icinga2::object::Zone::${title}":
    ensure      => $ensure,
    object_name => $zone_name,
    object_type => 'Zone',
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => $_target,
    order       => $order,
    notify      => Class['::icinga2::service'],
  }
}
