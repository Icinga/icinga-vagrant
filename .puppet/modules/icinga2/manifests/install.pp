# == Class: icinga2::install
#
# This class handles the installation of the Icinga 2 package. On Windows only chocolatey is supported as installation
# source.
#
# === Parameters
#
# This class does not provide any parameters.
#
# === Examples
#
# This class is private and should not be called by others than this module.
#
#
class icinga2::install {

  assert_private()

  $package        = $::icinga2::params::package
  $manage_package = $::icinga2::manage_package
  $pki_dir        = $::icinga2::params::pki_dir
  $conf_dir       = $::icinga2::params::conf_dir
  $user           = $::icinga2::params::user
  $group          = $::icinga2::params::group
  $repositoryd    = $::icinga2::repositoryd

  if $manage_package {
    if $::osfamily == 'windows' { Package { provider => chocolatey, } }

    package { $package:
      ensure => installed,
      before => File[$pki_dir, $conf_dir],
    }
  }

  file { [$pki_dir, $conf_dir]:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  # deprecated, removed in Icinga 2 v2.8.0
  $_ensure = $repositoryd ? {
    true    => 'directory',
    default => 'absent',
  }

  file { "${conf_dir}/repository.d":
    ensure  => $_ensure,
    owner   => $user,
    group   => $group,
    recurse => true,
    purge   => true,
    force   => true,
    require => File[$pki_dir, $conf_dir],
  }

}
