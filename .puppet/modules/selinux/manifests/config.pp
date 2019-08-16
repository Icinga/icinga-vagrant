# Configure the system to use SELinux on the system.
#
# It is included in the main class ::selinux
#
# @param mode See main class
# @param type See main class
# @param manage_package See main class
# @param package_name See main class
#
# @api private
#
class selinux::config (
  $mode           = $selinux::mode,
  $type           = $selinux::type,
  $manage_package = $selinux::manage_package,
  $package_name   = $selinux::package_name,
) {

  assert_private()

  if ($mode == 'enforcing' and !$facts['selinux']) {
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
        $sestatus = 'permissive'
        if $_real_mode == 'disabled' and $facts['selinux_current_mode'] == 'permissive' {
          notice('A reboot is required to fully disable SELinux. SELinux will operate in Permissive mode until a reboot')
        }
      }
      'enforcing': {
        $sestatus = 'enforcing'
      }
      default : {
        fail('You must specify a mode (enforced, permissive, or disabled) for selinux operation')
      }
    }

    # a complete relabeling is required when switching from disabled to
    # permissive or enforcing. Ensure the autorelabel trigger file is created.
    if $_real_mode in ['enforcing','permissive'] and
      !$facts['selinux'] {
      file { '/.autorelabel':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        content => "# created by puppet for disabled to ${_real_mode} switch\n",
      }
    }

    exec { "change-selinux-status-to-${_real_mode}":
      command => "setenforce ${sestatus}",
      unless  => "getenforce | grep -Eqi '${sestatus}|disabled'",
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
