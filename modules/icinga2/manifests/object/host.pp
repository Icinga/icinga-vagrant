# == Define: icinga2::object::host
#
# Manage Icinga 2 Host objects.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disables it. Defaults to present.
#
# [*host_name*]
#   Hostname of the Host object.
#
# [*import*]
#   Sorted List of templates to include. Defaults to an empty list.
#
# [*display_name*]
#   A short description of the host (e.g. displayed by external interfaces instead of the name if set).
#
# [*address*]
#   The host's address v4.
#
# [*address6*]
#   The host's address v6.
#
# [*vars*]
#   A dictionary containing custom attributes that are specific to this host
#   or a string to do operations on this dictionary.
#
# [*groups*]
#   A list of host groups this host belongs to.
#
# [*check_command*]
#   The name of the check command.
#
# [*max_check_attempts*]
#   The number of times a host is re-checked before changing into a hard state. Defaults to 3.
#
# [*check_period*]
#   The name of a time period which determines when this host should be checked. Not set by default.
#
# [*check_timeout*]
#    Check command timeout in seconds. Overrides the CheckCommand's timeout attribute.
#
# [*check_interval*]
#   The check interval (in seconds). This interval is used for checks when the host is in a HARD state. Defaults to 5 minutes.
#
# [*retry_interval*]
#   The retry interval (in seconds). This interval is used for checks when the host is in a SOFT state. Defaults to 1 minute.
#
# [*enable_notifications*]
#   Whether notifications are enabled. Defaults to true.
#
# [*enable_active_checks*]
#   Whether active checks are enabled. Defaults to true.
#
# [*enable_passive_checks*]
#   Whether passive checks are enabled. Defaults to true.
#
# [*enable_event_handler*]
#   Enables event handlers for this host. Defaults to true.
#
# [*enable_flapping*]
#   Whether flap detection is enabled. Defaults to false.
#
# [*enable_perfdata*]
#   Whether performance data processing is enabled. Defaults to true.
#
# [*event_command*]
#   The name of an event command that should be executed every time the host's
#   state changes or the host is in a SOFT state.
#
# [*flapping_threshold*]
#   The flapping threshold in percent when a host is considered to be flapping.
#
# [*volatile*]
#    The volatile setting enables always HARD state types if NOT-OK state changes occur.
#
# [*zone*]
#   The zone this object is a member of.
#
# [*command_endpoint*]
#   The endpoint where commands are executed on.
#
# [*notes*]
#   Notes for the host.
#
# [*notes_url*]
#   Url for notes for the host (for example, in notification commands).
#
# [*action_url*]
#   Url for actions for the host (for example, an external graphing tool).
#
# [*icon_image*]
#   Icon image for the host. Used by external interfaces only.
#
# [*icon_image_alt*]
#   Icon image description for the host. Used by external interface only.
#
# [*template*]
#   Set to true creates a template instead of an object. Defaults to false.
#
# [*target*]
#   Destination config file to store in this object. File will be declared the
#   first time.
#
# [*order*]
#   String to set the position in the target file, sorted alpha numeric. Defaults to 10.
#
#
define icinga2::object::host(
  $target,
  $ensure                = present,
  $host_name             = $title,
  $import                = [],
  $address               = undef,
  $address6              = undef,
  $vars                  = undef,
  $groups                = undef,
  $display_name          = undef,
  $check_command         = undef,
  $max_check_attempts    = undef,
  $check_period          = undef,
  $check_timeout         = undef,
  $check_interval        = undef,
  $retry_interval        = undef,
  $enable_notifications  = undef,
  $enable_active_checks  = undef,
  $enable_passive_checks = undef,
  $enable_event_handler  = undef,
  $enable_flapping       = undef,
  $enable_perfdata       = undef,
  $event_command         = undef,
  $flapping_threshold    = undef,
  $volatile              = undef,
  $zone                  = undef,
  $command_endpoint      = undef,
  $notes                 = undef,
  $notes_url             = undef,
  $action_url            = undef,
  $icon_image            = undef,
  $icon_image_alt        = undef,
  $template              = false,
  $order                 = '50',
) {

  include ::icinga2::params

  $conf_dir = $::icinga2::params::conf_dir

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_array($import)
  validate_bool($template)
  validate_absolute_path($target)
  validate_integer($order)

  if $host_name { validate_string($host_name) }
  if $address { validate_string($address) }
  if $address6 { validate_string($address6) }
  if $groups { validate_array($groups) }
  if $display_name { validate_string($display_name) }
  if $check_command { validate_string($check_command) }
  if $max_check_attempts { validate_integer($max_check_attempts) }
  if $check_period { validate_string($check_period) }
  if $check_timeout { validate_re($check_timeout, '^\d+\.?\d*[d|h|m|s]?$') }
  if $check_interval { validate_re($check_interval, '^\d+\.?\d*[d|h|m|s]?$') }
  if $retry_interval { validate_re($retry_interval, '^\d+\.?\d*[d|h|m|s]?$') }
  if $enable_notifications { validate_bool($enable_notifications) }
  if $enable_active_checks { validate_bool($enable_active_checks) }
  if $enable_passive_checks { validate_bool($enable_passive_checks) }
  if $enable_event_handler { validate_bool($enable_event_handler) }
  if $enable_flapping { validate_bool($enable_flapping) }
  if $enable_perfdata { validate_bool($enable_perfdata) }
  if $event_command { validate_string($event_command) }
  if $flapping_threshold { validate_integer($flapping_threshold) }
  if $volatile { validate_bool($volatile) }
  if $zone { validate_string($zone) }
  if $command_endpoint { validate_string($command_endpoint) }
  if $notes { validate_string($notes) }
  if $notes_url { validate_string($notes_url) }
  if $action_url { validate_string($action_url) }
  if $icon_image { validate_absolute_path($icon_image) }
  if $icon_image_alt { validate_string($icon_image_alt) }

  # compose the attributes
  $attrs = {
    address               => $address,
    address6              => $address6,
    groups                => $groups,
    display_name          => $display_name,
    check_command         => $check_command,
    max_check_attempts    => $max_check_attempts,
    check_period          => $check_period,
    check_timeout         => $check_timeout,
    check_interval        => $check_interval,
    retry_interval        => $retry_interval,
    enable_notifications  => $enable_notifications,
    enable_active_checks  => $enable_active_checks,
    enable_passive_checks => $enable_passive_checks,
    enable_event_handler  => $enable_event_handler,
    enable_flapping       => $enable_flapping,
    enable_perfdata       => $enable_perfdata,
    event_command         => $event_command,
    flapping_threshold    => $flapping_threshold,
    volatile              => $volatile,
    zone                  => $zone,
    command_endpoint      => $command_endpoint,
    notes                 => $notes,
    notes_url             => $notes_url,
    action_url            => $action_url,
    icon_image            => $icon_image,
    icon_image_alt        => $icon_image_alt,
    vars                  => $vars,
  }

  # create object
  icinga2::object { "icinga2::object::Host::${title}":
    ensure      => $ensure,
    object_name => $host_name,
    object_type => 'Host',
    template    => $template,
    import      => $import,
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => $target,
    order       => $order,
    notify      => Class['::icinga2::service'],
  }
}
