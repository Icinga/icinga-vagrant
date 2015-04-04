# Class: selinux::params
#
# Description
#  This class provides default parameters for the selinux class
#
# Sample Usage:
#  mod_dir = $selinux::params::sx_mod_dir
#
class selinux::params {
  $sx_mod_dir   = '/usr/share/selinux'
  $mode         = 'disabled'
  $package_ensure = present

  $sx_fs_mount  = $::osfamily ? {
    'RedHat' => $::operatingsystemrelease ? {
      /^7\./        => '/sys/fs/selinux',
      default       => '/selinux',
    },
    default         => '/selinux',
  }

  $restorecond_config_file       = '/etc/selinux/restorecond.conf'
  $restorecond_config_file_mode  = '0644'
  $restorecond_config_file_owner = 'root'
  $restorecond_config_file_group = 'root'
}
