# Class: selinux::config
#
# Description
#  This class is designed to configure the system to use SELinux on the system
#
# Parameters:
#  - $mode (enforcing|permissive|disabled) - sets the operating state for SELinux.
#  - $type (targeted|minimum|mls) - sets SELinux policy.
#  - $manage_package (boolean) - Whether or not to manage the SELinux management package.
#  - $package_name (string) - sets the name of the selinux management package.
#  - $sx_mod_dir (directory) - sets the operating sx_mod_dir for SELinux.
#
# Actions:
#  Configures SELinux to a specific state (enforced|permissive|disabled and targeted|minimum|mls)
#
# Requires:
#  This module has no requirements
#
# Sample Usage:
#  This module should not be called directly.
#
class selinux::config (
  $mode           = $::selinux::mode,
  $type           = $::selinux::type,
  $sx_mod_dir     = $::selinux::sx_mod_dir,
  $manage_package = $::selinux::manage_package,
  $package_name   = $::selinux::package_name,
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { $sx_mod_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
  }

  if $mode {
    file_line { "set-selinux-config-to-${mode}":
      path  => '/etc/selinux/config',
      line  => "SELINUX=${mode}",
      match => '^SELINUX=\w+',
    }

    case $mode {
      'permissive', 'disabled': {
        $sestatus = '0'
        if $mode == 'disabled' and defined('$::selinux_current_mode') and $::selinux_current_mode == 'permissive' {
          notice('A reboot is required to fully disable SELinux. SELinux will operate in Permissive mode until a reboot')
        }
      }
      'enforcing': {
        $sestatus = '1'
      }
      default : {
        fail('You must specify a mode (enforced, permissive, or disabled) for selinux operation')
      }
    }

    # a complete relabeling is required when switching from disabled to
    # permissive or enforcing. Ensure the autorelabel trigger file is created.
    if $mode in ['enforcing','permissive'] and
      !$::selinux {
      file { '/.autorelabel':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        content => "# created by puppet for disabled to ${mode} switch\n",
      }
    }

    exec { "change-selinux-status-to-${mode}":
      command => "setenforce ${sestatus}",
      unless  => "getenforce | grep -Eqi '${mode}|disabled'",
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    }
  }

  if $type {
    file_line { "set-selinux-config-type-to-${type}":
      path  => '/etc/selinux/config',
      line  => "SELINUXTYPE=${type}",
      match => '^SELINUXTYPE=\w+',
    }
  }
}
