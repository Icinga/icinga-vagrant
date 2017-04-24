# Definition: selinux::boolean
#
# Description
#  This class will set the state of an SELinux boolean.
#  All pending values are written to the policy file on disk, so they will be persistant across reboots.
#  Ensure that the manifest notifies a related service as a restart for that service may be required.
#
# Class created by GreenOgre<aggibson@cogeco.ca>
#  Adds to puppet-selinux by jfryman
#   https://github.com/jfryman/puppet-selinux
#
# Parameters:
#   - $ensure: (on|off) - Sets the current state of a particular SELinux boolean
#   - $persistent: (true|false) - Should a particular SELinux boolean persist across reboots
#
# Actions:
#  Wraps selboolean to set states
#
# Requires:
#  - SELinux
#
# Sample Usage:
#
#  selinux::boolean{ 'named_write_master_zones':
#     ensure     => "on",
#     persistent => true,
#  }
#
define selinux::boolean (
  $ensure     = 'on',
  $persistent = true,
) {

  include ::selinux

  $ensure_real = $ensure ? {
    true    => 'true', # lint:ignore:quoted_booleans
    false   => 'false', # lint:ignore:quoted_booleans
    default => $ensure,
  }

  validate_re($ensure_real, ['^on$', '^true$', '^present$', '^off$', '^false$', '^absent$'], 'Valid ensures must be one of on, true, present, off, false, or absent')
  validate_bool($persistent)

  $value = $ensure_real ? {
    /(?i-mx:on|true|present)/  => 'on',
    /(?i-mx:off|false|absent)/ => 'off',
    default                    => undef,
  }

  selboolean { $name:
    value      => $value,
    persistent => $persistent,
  }
}
