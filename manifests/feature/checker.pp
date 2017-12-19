# == Class: icinga2::feature::checker
#
# This module configures the Icinga 2 feature checker.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the feature checker, absent disabled it. Defaults to present.
#
# [*concurrent_checks*]
#   The maximum number of concurrent checks. Defaults to 512.
#
#
class icinga2::feature::checker(
  $ensure            = present,
  $concurrent_checks = undef,
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

  if $concurrent_checks { validate_integer($concurrent_checks) }

  # compose attributes
  $attrs = {
    concurrent_checks => $concurrent_checks,
  }

  # create object
  icinga2::object { 'icinga2::object::CheckerComponent::checker':
    object_name => 'checker',
    object_type => 'CheckerComponent',
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => "${conf_dir}/features-available/checker.conf",
    order       => '10',
    notify      => $_notify,
  }

  # import library 'checker'
  concat::fragment { 'icinga2::feature::checker':
    target  => "${conf_dir}/features-available/checker.conf",
    content => "library \"checker\"\n\n",
    order   => '05',
  }

  # manage feature
  icinga2::feature { 'checker':
    ensure => $ensure,
  }

}
