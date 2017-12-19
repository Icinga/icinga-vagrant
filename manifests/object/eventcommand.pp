# == Define: icinga2::object::eventcommand
#
# Manage Icinga 2 EventCommand objects.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disables it. Defaults to present.
#
# [*eventcommand_name*]
#   Set the Icinga 2 name of the eventcommand object. Defaults to title of the define resource.
#
# [*execute*]
#     The "execute" script method takes care of executing the event handler.
#     In virtually all cases you should import the "plugin-event-command" template to take care of this setting.
#
# [*command*]
#     The command. This can either be an array of individual command arguments.
#     Alternatively a string can be specified in which case the shell interpreter (usually /bin/sh)
#     takes care of parsing the command.
#
# [*env*]
#     A dictionary of macros which should be exported as environment variables prior to executing the command.
#
# [*vars*]
#     A dictionary containing custom attributes that are specific to this command
#     or a string to do operations on this dictionary.
#
# [*timeout*]
#     The command timeout in seconds. Defaults to 60 seconds.
#
# [*arguments*]
#     A dictionary of command arguments.
#
# [*target*]
#   Destination config file to store in this object. File will be declared the
#   first time.
#
# [*import*]
#   Sorted List of templates to include. Defaults to an empty list.
#
# [*order*]
#   String to set the position in the target file, sorted alpha numeric. Defaults to 30.
#
#
define icinga2::object::eventcommand (
  $target,
  $ensure            = present,
  $eventcommand_name = $title,
  $command           = undef,
  $env               = undef,
  $vars              = undef,
  $timeout           = undef,
  $arguments         = undef,
  $import            = ['plugin-event-command'],
  $order             = '20',
){
  include ::icinga2::params

  $conf_dir = $::icinga2::params::conf_dir

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_string($eventcommand_name)
  validate_absolute_path($target)
  validate_string($order)
  validate_array($import)

  if !is_array($command) { validate_string($command) }
  if !is_string($command) { validate_array($command) }
  if $env { validate_hash($env) }
  if $timeout { validate_integer($timeout) }
  if $arguments { validate_hash($arguments) }

  # compose the attributes
  $attrs = {
    'command'   => $command,
    'env'       => $env,
    'timeout'   => $timeout,
    'arguments' => $arguments,
    'vars'      => $vars,
  }

  # create object
  icinga2::object { "icinga2::object::EventCommand::${title}":
    ensure      => $ensure,
    object_name => $eventcommand_name,
    object_type => 'EventCommand',
    import      => $import,
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => $target,
    order       => $order,
    notify      => Class['::icinga2::service'],
  }
}
