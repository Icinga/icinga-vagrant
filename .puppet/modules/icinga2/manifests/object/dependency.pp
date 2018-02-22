# == Define: icinga2::object::dependency
#
# Manage Icinga 2 dependency objects.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disables it. Defaults to present.
#
# [*dependency_name*]
#   Set the Icinga 2 name of the dependency object. Defaults to title of the define resource.
#
# [*parent_host_name*]
#   The parent host.
#
# [*parent_service_name*]
#   The parent service. If omitted, this dependency object is treated as host
#   dependency.
#
# [*child_host_name*]
#   The child host.
#
# [*child_service_name*]
#   The child service. If omitted, this dependency object is treated as host
#   dependency.
#
# [*disable_checks*]
#   Whether to disable checks when this dependency fails. Defaults to false.
#
# [*disable_notifications*]
#   Whether to disable notifications when this dependency fails. Defaults to
#   true.
#
# [*ignore_soft_states*]
#   Whether to ignore soft states for the reachability calculation. Defaults to
#   true.
#
# [*period*]
#   Time period during which this dependency is enabled.
#
# [*states*]
#   A list of state filters when this dependency should be OK. Defaults to [ OK,
#   Warning ] for services and [ Up ] for hosts.
#
# [*apply*]
#   Dispose an apply instead an object if set to 'true'. Value is taken as statement,
#   i.e. 'vhost => config in host.vars.vhosts'. Defaults to false.
#
# [*prefix*]
#   Set dependency_name as prefix in front of 'apply for'. Only effects if apply is a string. Defaults to false.
#
# [*apply_target*]
#   An object type on which to target the apply rule. Valid values are `Host`
#   and `Service`. Defaults to `Host`.
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
#   String to set the position in the target file, sorted alpha numeric. Defaults to 35.
#
#
define icinga2::object::dependency (
  $target,
  $ensure                = present,
  $dependency_name       = $title,
  $parent_host_name      = undef,
  $parent_service_name   = undef,
  $child_host_name       = undef,
  $child_service_name    = undef,
  $disable_checks        = undef,
  $disable_notifications = undef,
  $ignore_soft_states    = undef,
  $period                = undef,
  $states                = undef,
  $apply                 = false,
  $prefix                = false,
  $apply_target          = 'Host',
  $assign                = [],
  $ignore                = [],
  $import                = [],
  $template              = false,
  $order                 = '70',
){
  include ::icinga2::params

  $conf_dir = $::icinga2::params::conf_dir

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_string($dependency_name)
  unless is_bool($apply) { validate_string($apply) }
  validate_bool($prefix)
  validate_re($apply_target, ['^Host$', '^Service$'],
    "${apply_target} isn't supported. Valid values are 'Host' and 'Service'.")
  validate_array($import)
  validate_bool($template)
  validate_absolute_path($target)
  validate_string($order)

  if $parent_host_name { validate_string ($parent_host_name) }
  if $parent_service_name { validate_string ( $parent_service_name ) }
  if $child_host_name { validate_string ($child_host_name) }
  if $child_service_name { validate_string ( $child_service_name ) }
  if $disable_checks { validate_bool ( $disable_checks ) }
  if $disable_notifications { validate_bool ( $disable_notifications ) }
  if $ignore_soft_states { validate_bool ( $ignore_soft_states ) }
  if $period { validate_string ( $period ) }
  if $states { validate_array ( $states ) }

  # compose attributes
  $attrs = {
    'parent_host_name'      => $parent_host_name,
    'parent_service_name'   => $parent_service_name,
    'child_host_name'       => $child_host_name,
    'child_service_name'    => $child_service_name,
    'disable_checks'        => $disable_checks,
    'disable_notifications' => $disable_notifications,
    'ignore_soft_states'    => $ignore_soft_states,
    'period'                => $period,
    'states'                => $states,
  }

  # create object
  icinga2::object { "icinga2::object::Dependency::${title}":
    ensure       => $ensure,
    object_name  => $dependency_name,
    object_type  => 'Dependency',
    import       => $import,
    template     => $template,
    attrs        => delete_undef_values($attrs),
    attrs_list   => keys($attrs),
    apply        => $apply,
    prefix       => $prefix,
    apply_target => $apply_target,
    assign       => $assign,
    ignore       => $ignore,
    target       => $target,
    order        => $order,
    notify       => Class['::icinga2::service'],
  }

}
