# Class: selinux::params
#
# Description
#  This class provides default parameters for the selinux class
#
# Sample Usage:
#  sx_mod_dir = $selinux::sx_mod_dir
#
class selinux::params {
  $makefile       = '/usr/share/selinux/devel/Makefile'
  $sx_mod_dir     = '/usr/share/selinux'
  $mode           = undef
  $type           = undef
  $manage_package = true

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
            '24', '25' : {
              $package_name = 'selinux-policy-devel'
            }
            default: {
              fail("${::operatingsystem}-${::os_maj_release} is not supported")
            }
          }
        }
        'Amazon': {
          $sx_fs_mount = '/selinux'
          case $os_maj_release {
            '4': {
              $package_name = 'policycoreutils-python'
            }
            default: {
              fail("${::operatingsystem}-${::os_maj_release} is not supported")
            }
          }
        }
        default: {
          case $os_maj_release {
            '7': {
              $sx_fs_mount = '/sys/fs/selinux'
              $package_name = 'selinux-policy-devel'
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

  $restorecond_config_file       = '/etc/selinux/restorecond.conf'
  $restorecond_config_file_mode  = '0644'
  $restorecond_config_file_owner = 'root'
  $restorecond_config_file_group = 'root'
}
