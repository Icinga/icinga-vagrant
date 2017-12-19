# == Define: icinga2::object::scheduleddowntime
#
# Manage Icinga 2 scheduleddowntime objects.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disables it. Defaults to present.
#
# [*scheduleddowntime_name*]
#   Set the Icinga 2 name of the scheduleddowntime object. Defaults to title of the define resource.
#
# [*host_name*]
#     The name of the host this comment belongs to.
#
# [*service_name*]
#     The short name of the service this comment belongs to. If omitted, this comment object is treated as host comment.
#
# [*author*]
#     The author's name.
#
# [*comment*]
#     The comment text.
#
# [*fixed*]
#     Whether this is a fixed downtime. Defaults to true.
#
# [*duration*]
#     The duration as number.
#
# [*ranges*]
#     A dictionary containing information which days and durations apply to this timeperiod.
#
# [*apply*]
#   Dispose an apply instead an object if set to 'true'. Value is taken as statement,
#   i.e. 'vhost => config in host.vars.vhosts'. Defaults to false.
#
# [*prefix*]
#   Set scheduleddowntime_name as prefix in front of 'apply for'. Only effects if apply is a string. Defaults to false.
#
# [*apply_target*]
#   An object type on which to target the apply rule. Valid values are `Host` and `Service`. Defaults to `Host`.
#
# [*assign*]
#   Assign user group members using the group assign rules.
#
# [*ignore*]
#   Exclude users using the group ignore rules.
#
# [*target*]
#   Destination config file to store in this object. File will be declared the
#   first time.
#
# [*order*]
#   String to set the position in the target file, sorted alpha numeric. Defaults to 30.
#
#
define icinga2::object::scheduleddowntime (
  $target,
  $ensure                 = present,
  $scheduleddowntime_name = $title,
  $host_name              = undef,
  $service_name           = undef,
  $author                 = undef,
  $comment                = undef,
  $fixed                  = undef,
  $duration               = undef,
  $ranges                 = undef,
  $apply                  = false,
  $prefix                 = false,
  $apply_target           = 'Host',
  $assign                 = [],
  $ignore                 = [],
  $order                  = '90',
){
  include ::icinga2::params

  $conf_dir = $::icinga2::params::conf_dir

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_string($scheduleddowntime_name)
  unless is_bool($apply) { validate_string($apply) }
  validate_bool($prefix)
  validate_re($apply_target, ['^Host$', '^Service$'],
    "${apply_target} isn't supported. Valid values are 'Host' and 'Service'.")
  validate_absolute_path($target)
  validate_string($order)

  if $host_name { validate_string($host_name) }
  if $service_name { validate_string ($service_name) }
  if $author { validate_string($author) }
  if $comment { validate_string($comment) }
  if $fixed { validate_bool($fixed) }
  if $duration { validate_re($duration, '^\d+(\.\d+)?[dhms]?$') }
  if $ranges { validate_hash($ranges) }

  # compose attributes
  $attrs = {
    'host_name'    => $host_name,
    'service_name' => $service_name,
    'author'       => $author,
    'comment'      => $comment,
    'fixed'        => $fixed,
    'duration'     => $duration,
    'ranges'       => $ranges,
  }

  # create object
  icinga2::object { "icinga2::object::ScheduledDowntime::${title}":
    ensure       => $ensure,
    object_name  => $scheduleddowntime_name,
    object_type  => 'ScheduledDowntime',
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
