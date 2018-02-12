# selinux::params
#
# THIS IS A PRIVATE CLASS
# =======================
#
# This class provides default parameters for the selinux class
#
class selinux::params {
  $refpolicy_makefile = '/usr/share/selinux/devel/Makefile'
  $mode           = undef
  $type           = undef
  $manage_package = true

  $refpolicy_package_name = 'selinux-policy-devel'

  $module_build_root = "${facts['puppet_vardir']}/puppet-selinux"

  if $::operatingsystemmajrelease {
    $os_maj_release = $::operatingsystemmajrelease
  } else {
    $os_versions    = split($::operatingsystemrelease, '[.]')
    $os_maj_release = $os_versions[0]
  }

  case $::osfamily {
    'RedHat': {
      case $::operatingsystem {
        'Fedora': {
          $sx_fs_mount = '/sys/fs/selinux'
          case $os_maj_release {
            '19','20' : {
              $package_name = 'policycoreutils-python'
            }
            '21','22','23' : {
              $package_name = 'policycoreutils-devel'
            }
            default: {
              $package_name = 'policycoreutils-python-utils'
            }
          }
        }
        'Amazon': {
          $sx_fs_mount = '/selinux'
          $package_name = 'policycoreutils'
        }
        default: {
          case $os_maj_release {
            '7': {
              $sx_fs_mount = '/sys/fs/selinux'
              $package_name = 'policycoreutils-python'
            }
            '6': {
              $sx_fs_mount = '/selinux'
              $package_name = 'policycoreutils-python'
            }
            '5': {
              $sx_fs_mount = '/selinux'
              $package_name = 'policycoreutils'
            }
            '': {
              # Fallback to lsbmajdistrelease, if puppet version is < 3.0
              if($::lsbmajdistrelease == '5') {
                $sx_fs_mount = '/selinux'
                $package_name = 'policycoreutils'
              }
            }
            default: {
              fail("${::operatingsystem}-${::os_maj_release} is not supported")
            }
          }
        }
      }
    }
    default: {
      fail("${::osfamily} is not supported")
    }
  }
}
