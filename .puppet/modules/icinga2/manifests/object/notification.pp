# == Define: icinga2::object::notification
#
# Manage Icinga 2 notification objects.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disables it. Defaults to present.
#
# [*notification_name*]
#   Set the Icinga 2 name of the notification object. Defaults to title of the define resource.
#
# [*host_name*]
# 	The name of the host this notification belongs to.
#
# [*service_name*]
# 	The short name of the service this notification belongs to. If omitted, this
#   notification object is treated as host notification.
#
# [*vars*]
# 	A dictionary containing custom attributes that are specific to this
#   notification object or a string to do operations on this dictionary.
#
# [*users*]
# 	A list of user names who should be notified.
#
# [*user_groups*]
# 	A list of user group names who should be notified.
#
# [*times*]
# 	A dictionary containing begin and end attributes for the notification.
#
# [*command*]
# 	The name of the notification command which should be executed when the
#   notification is triggered.
#
# [*interval*]
# 	The notification interval (in seconds). This interval is used for active
#   notifications. Defaults to 30 minutes. If set to 0, re-notifications are
#   disabled.
#
# [*period*]
# 	The name of a time period which determines when this notification should be
#   triggered. Not set by default.
#
# [*zone*]
# 	The zone this object is a member of.
#
# [*types*]
# 	A list of type filters when this notification should be triggered. By
#   default everything is matched.
#
# [*states*]
# 	A list of state filters when this notification should be triggered. By
#   default everything is matched.
#
# [*template*]
#   Set to true creates a template instead of an object. Defaults to false.
#
# [*apply*]
#   Dispose an apply instead an object if set to 'true'. Value is taken as statement,
#   i.e. 'vhost => config in host.vars.vhosts'. Defaults to false.
#
# [*prefix*]
#   Set notification_name as prefix in front of 'apply for'. Only effects if apply is a string. Defaults to false.
#
# [*apply_target*]
#   An object type on which to target the apply rule. Valid values are `Host` and `Service`. Defaults to `Host`.
#
# [*import*]
#   Sorted List of templates to include. Defaults to an empty list.
#
# [*target*]
#   Destination config file to store in this object. File will be declared the
#   first time.
#
# [*order*]
#   String to set the position in the target file, sorted alpha numeric. Defaults to 10.
#
#
define icinga2::object::notification (
  $target,
  $ensure            = present,
  $notification_name = $title,
  $host_name         = undef,
  $service_name      = undef,
  $vars              = undef,
  $users             = undef,
  $user_groups       = undef,
  $times             = undef,
  $command           = undef,
  $interval          = undef,
  $period            = undef,
  $zone              = undef,
  $types             = undef,
  $states            = undef,
  $apply             = false,
  $prefix            = false,
  $apply_target      = 'Host',
  $assign            = [],
  $ignore            = [],
  $import            = [],
  $template          = false,
  $order             = '85',
){
  include ::icinga2::params

  $conf_dir = $::icinga2::params::conf_dir

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_string($notification_name)
  unless is_bool($apply) { validate_string($apply) }
  validate_bool($prefix)
  validate_re($apply_target, ['^Host$', '^Service$'],
    "${apply_target} isn't supported. Valid values are 'Host' and 'Service'.")
  validate_array($import)
  validate_bool($template)
  validate_absolute_path($target)
  validate_string($order)

  validate_string ($host_name)
  if $service_name { validate_string ($service_name)}
  if !is_array($users) { validate_string($users) }
  if !is_string($users) { validate_array($users) }
  if !is_array($user_groups) { validate_string($user_groups) }
  if !is_string($user_groups) { validate_array($user_groups) }
  if $times { validate_hash ($times )}
  if $command { validate_string ($command )}
  if $interval { validate_re($interval, '^\d+(\.\d+)?[dhms]?$')}
  if $period { validate_string ($period )}
  if $zone { validate_string ($zone) }
  if !is_array($types) { validate_string($types) }
  if !is_string($types) { validate_array($types) }
  if !is_array($states) { validate_string($states) }
  if !is_string($states) { validate_array($states) }
  if $assign { validate_array ($assign) }
  if $ignore { validate_array ($ignore) }

  if $ignore != [] and $assign == [] {
    fail('When attribute ignore is used, assign must be set.')
  }

  # compose attributes
  $attrs = {
    'host_name' => $host_name,
    'service_name' => $service_name,
    'users' => $users,
    'user_groups' => $user_groups,
    'times' => $times,
    'command' => $command,
    'interval' => $interval,
    'period' => $period,
    'zone' => $zone,
    'types' => $types,
    'states' => $states,
    'vars' => $vars,
  }

  # create object
  icinga2::object { "icinga2::object::Notification::${title}":
    ensure       => $ensure,
    object_name  => $notification_name,
    object_type  => 'Notification',
    import       => $import,
    template     => $template,
    attrs        => delete_undef_values($attrs),
    attrs_list   => keys($attrs),
    target       => $target,
    order        => $order,
    apply        => $apply,
    prefix       => $prefix,
    apply_target => $apply_target,
    assign       => $assign,
    ignore       => $ignore,
    notify       => Class['::icinga2::service'],
  }

}
