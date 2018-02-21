# == Define: icinga2::object::notificationcommand
#
# Manage Icinga 2 notificationcommand objects.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disables it. Defaults to present.
#
# [*notificationcommand_name*]
#   Set the Icinga 2 name of the notificationcommand object. Defaults to title of the define resource.
#
# [*execute*]
# 	 The "execute" script method takes care of executing the notification.
#    The default template "plugin-notification-command" which is imported into
#    all CheckCommand objects takes care of this setting.
#
# [*command*]
# 	 The command. This can either be an array of individual command arguments.
#    Alternatively a string can be specified in which case the shell interpreter
#    (usually /bin/sh) takes care of parsing the command.
#
# [*env*]
# 	 A dictionary of macros which should be exported as environment variables
#    prior to executing the command.
#
# [*vars*]
# 	 A dictionary containing custom attributes that are specific to this command
#    or a string to do operations on this dictionary.
#
# [*timeout*]
# 	 The command timeout in seconds. Defaults to 60 seconds.
#
# [*arguments*]
# 	 A dictionary of command arguments.
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
#   String to set the position in the target file, sorted alpha numeric. Defaults to 10.
#
#
define icinga2::object::notificationcommand (
  $target,
  $ensure                   = present,
  $notificationcommand_name = $title,
  $command                  = undef,
  $env                      = undef,
  $vars                     = undef,
  $timeout                  = undef,
  $arguments                = undef,
  $template                 = false,
  $import                   = ['plugin-notification-command'],
  $order                    = '25',
){
  include ::icinga2::params

  $conf_dir = $::icinga2::params::conf_dir

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_string($notificationcommand_name)
  validate_array($import)
  validate_bool($template)
  validate_absolute_path($target)
  validate_string($order)

  if !is_array($command) { validate_string($command) }
  if !is_string($command) { validate_array($command) }
  if $env { validate_hash ($env) }
  if $timeout { validate_integer ($timeout) }
  if $arguments { validate_hash ($arguments) }

  # compose attributes
  $attrs = {
    'command'   => $command,
    'env'       => $env,
    'timeout'   => $timeout,
    'arguments' => $arguments,
    'vars'      => $vars,
  }

  # create object
  icinga2::object { "icinga2::object::NotificationCommand::${title}":
    ensure      => $ensure,
    object_name => $notificationcommand_name,
    object_type => 'NotificationCommand',
    template    => $template,
    import      => $import,
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => $target,
    order       => $order,
    notify      => Class['::icinga2::service'],
  }

}
