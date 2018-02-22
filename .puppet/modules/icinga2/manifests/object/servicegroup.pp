# == Define: icinga2::object::servicegroup
#
# Manage Icinga 2 servicegroup objects.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disables it. Defaults to present.
#
# [*servicegroup_name*]
#   Set the Icinga 2 name of the servicegroup object. Defaults to title of the define resource.
#
# [*display_name*]
#   A short description of the service group.
#
# [*groups*]
#   An array of nested group names.
#
# [*assign*]
#   Assign user group members using the group assign rules.
#
# [*ignore*]
#   Exclude users using the group ignore rules.
#
# [*template*]
#   Set to true creates a template instead of an object. Defaults to false.
#
# [*import*]
#   Sorted List of templates to include. Defaults to an empty list.
#
# [*target*]
#   Destination config file to store in this object. File will be declared the
#   first time.
#
# [*order*]
#   String to set the position in the target file, sorted alpha numeric. Defaults to 30.
#
#
define icinga2::object::servicegroup (
  $target,
  $ensure            = present,
  $servicegroup_name = $title,
  $display_name      = undef,
  $groups            = undef,
  $assign            = [],
  $ignore            = [],
  $template          = false,
  $import            = [],
  $order             = '65',
){
  include ::icinga2::params

  $conf_dir = $::icinga2::params::conf_dir

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_string($servicegroup_name)
  validate_array($import)
  validate_bool($template)
  validate_absolute_path($target)
  validate_string($order)

  if $display_name { validate_string ( $display_name ) }
  if $groups { validate_array ( $groups ) }


  # compose attributes
  $attrs = {
    'display_name'  => $display_name,
    'groups'        => $groups,
  }

  # create object
  icinga2::object { "icinga2::object::ServiceGroup::${title}":
    ensure      => $ensure,
    object_name => $servicegroup_name,
    object_type => 'ServiceGroup',
    import      => $import,
    template    => $template,
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    assign      => $assign,
    ignore      => $ignore,
    target      => $target,
    order       => $order,
    notify      => Class['::icinga2::service'],
  }

}
