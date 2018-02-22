# Class: selinux::config
#
# THIS IS A PRIVATE CLASS
# =======================
#
# This class is designed to configure the system to use SELinux on the system.
#
# It is included in the main class ::selinux
#
#
#
# Config for module building
# --------------------------
#
# The module building requires the following file structure:
#
# ```
# $module_build_root/
#   bin/ # for simple module build script
#   modules/ # module source files and compiled policies
#   modules/tmp # repolicy tempfiles (created by scripts)
# ```
#
# @param mode See main class
# @param type See main class
# @param manage_package See main class
# @param package_name See main class
# @param module_build_root See main class
#
class selinux::config (
  $mode                                   = $::selinux::mode,
  $type                                   = $::selinux::type,
  $manage_package                         = $::selinux::manage_package,
  $package_name                           = $::selinux::package_name,
  Stdlib::Absolutepath $module_build_root = $::selinux::module_build_root
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if ($mode == 'enforcing' and !$::selinux) {
    notice('SELinux is disabled. Forcing configuration to permissive to avoid problems. To disable this warning, explicitly set selinux::mode to permissive or disabled.')
    $_real_mode = 'permissive'
  } else {
    $_real_mode = $mode
  }

  if $_real_mode {
    file_line { "set-selinux-config-to-${_real_mode}":
      path  => '/etc/selinux/config',
      line  => "SELINUX=${_real_mode}",
      match => '^SELINUX=\w+',
    }

    case $_real_mode {
      'permissive', 'disabled': {
        $sestatus = '0'
        if $_real_mode == 'disabled' and defined('$::selinux_current_mode') and $::selinux_current_mode == 'permissive' {
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
    if $_real_mode in ['enforcing','permissive'] and
      !$::selinux {
      file { '/.autorelabel':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        content => "# created by puppet for disabled to ${_real_mode} switch\n",
      }
    }

    exec { "change-selinux-status-to-${_real_mode}":
      command => "setenforce ${sestatus}",
      unless  => "getenforce | grep -Eqi '${_real_mode}|disabled'",
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

  file {$module_build_root:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file {"${module_build_root}/bin":
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # put helper in place:
  file {"${module_build_root}/bin/selinux_build_module_simple.sh":
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/selinux_build_module_simple.sh",
  }

  $module_build_dir = "${module_build_root}/modules"

  file {$module_build_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    recurse => true,
    purge   => true,
    force   => true,
  }

  # needed by refpolicy builder and our simple builder
  file {"${module_build_dir}/tmp":
    ensure                  => 'directory',
    selinux_ignore_defaults => true,
  }
}
