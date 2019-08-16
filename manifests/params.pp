# This class provides default parameters for the selinux class
#
# @api private
#
class selinux::params {
  $module_build_root = "${facts['puppet_vardir']}/puppet-selinux"

  case $facts['os']['family'] {
    'RedHat': {
      if $facts['os']['name'] == 'Amazon' {
        $package_name = 'policycoreutils'
      } else {
        $package_name = $facts['os']['release']['major'] ? {
          '5'     => 'policycoreutils',
          '6'     => 'policycoreutils-python',
          '7'     => 'policycoreutils-python',
          default => 'policycoreutils-python-utils',
        }
      }
    }
    default: {
      fail("${facts['os']['family']} is not supported")
    }
  }
}
