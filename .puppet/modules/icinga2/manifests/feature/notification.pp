# == Class: icinga2::feature::notification
#
# This module configures the Icinga 2 feature notification.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the feature notification, absent disabled it. Defaults to present.
#
# [*enable_ha*]
#   Notifications are load-balanced amongst all nodes in a zone. By default this
#   functionality is enabled. If your nodes should send out notifications independently
#   from any other nodes (this will cause duplicated notifications if not properly
#   handled!), you can set enable_ha to false.
#
#
class icinga2::feature::notification(
  $ensure    = present,
  $enable_ha = undef,
) {

  if ! defined(Class['::icinga2']) {
    fail('You must include the icinga2 base class before using any icinga2 feature class!')
  }

  $conf_dir = $::icinga2::params::conf_dir
  $_notify  = $ensure ? {
    'present' => Class['::icinga2::service'],
    default   => undef,
  }

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  if $enable_ha {
    validate_bool($enable_ha)
  }

  # compose attributes
  $attrs = {
    enable_ha => $enable_ha,
  }

  # create object
  icinga2::object { 'icinga2::object::NotificationComponent::notification':
    object_name => 'notification',
    object_type => 'NotificationComponent',
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => "${conf_dir}/features-available/notification.conf",
    order       => '10',
    notify      => $_notify,
  }

  # import library 'notification'
  concat::fragment { 'icinga2::feature::notification':
    target  => "${conf_dir}/features-available/notification.conf",
    content => "library \"notification\"\n\n",
    order   => '05',
  }

  # manage feature
  icinga2::feature { 'notification':
    ensure      => $ensure,
  }

}
