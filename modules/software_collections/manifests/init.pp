################################################################################
# Class: software_collections
#
# This class will install centos-release-scl - The Software Collections (SCL) Repository
#
################################################################################
class software_collections (
  $version = present,
  $manage_package = true,
) {
  if $manage_package {
    if $::kernel == 'Linux' {
      if ! defined(Package['centos-release-scl']) {
        package { 'centos-release-scl': ensure => $version }
      }
    }
  }
}
