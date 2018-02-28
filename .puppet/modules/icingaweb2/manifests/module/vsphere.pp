# == Class: icingaweb2::module::vsphere
#
# The vSphere module extends the Director. It provides import sources for virtual machines and physical hosts
# from vSphere.
#
# === Parameters
#
# [*ensure*]
#   Enable or disable module. Defaults to `present`
#
#
class icingaweb2::module::vsphere(
  Enum['absent', 'present'] $ensure           = 'present',
  String                    $git_repository   = 'https://github.com/Icinga/icingaweb2-module-vsphere.git',
  Optional[String]          $git_revision     = undef,
){

  icingaweb2::module { 'vsphere':
    ensure         => $ensure,
    git_repository => $git_repository,
    git_revision   => $git_revision,
  }
}