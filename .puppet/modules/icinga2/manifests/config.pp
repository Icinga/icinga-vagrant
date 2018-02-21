# == Class: icinga2::config
#
# This class exists to manage general configuration files needed by Icinga 2 to run.
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
class icinga2::config {

  assert_private()

  $constants      = prefix($::icinga2::_constants, 'const ')
  $conf_dir       = $::icinga2::params::conf_dir
  $plugins        = $::icinga2::plugins
  $confd          = $::icinga2::_confd
  $purge_features = $::icinga2::purge_features
  $repositoryd    = $::icinga2::repositoryd

  if $::kernel != 'windows' {
    $template_constants  = icinga2_attributes($constants)
    $template_mainconfig = template('icinga2/icinga2.conf.erb')
  } else {
    $template_constants  = regsubst(icinga2_attributes($constants), '\n', "\r\n", 'EMG')
    $template_mainconfig = regsubst(template('icinga2/icinga2.conf.erb'), '\n', "\r\n", 'EMG')
  }

  file { "${conf_dir}/constants.conf":
    ensure  => file,
    content => $template_constants,
  }

  file { "${conf_dir}/icinga2.conf":
    ensure  => file,
    content => $template_mainconfig,
  }

  file { "${conf_dir}/features-enabled":
    ensure  => directory,
    purge   => $purge_features,
    recurse => $purge_features,
  }

}
