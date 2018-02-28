# == Class: icingaweb2::install
#
# This class handles the installation of the Icinga Web 2 package.
#
# === Parameters
#
# This class does not provide any parameters.
#
# === Examples
#
# This class is private and should not be called by others than this module.
#
class icingaweb2::install {

  assert_private("You're not supposed to use this defined type manually.")

  $package             = $::icingaweb2::params::package
  $manage_package      = $::icingaweb2::manage_package
  $extra_packages      = $::icingaweb2::extra_packages

  if $manage_package {
    package { $package:
      ensure => installed,
    }
  }

  if $extra_packages {
    ensure_packages($extra_packages, { 'ensure' => 'present' })
  }
}
