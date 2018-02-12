# selinux::boolean
#
# This class will set the state of an SELinux boolean.
#
# @example Enable `named_write_master_zones`  boolean
#   selinux::boolean{ 'named_write_master_zones':
#      ensure     => 'on',
#   }
#
# @example Ensure `named_write_master_zones` boolean is disabled
#   selinux::boolean{ 'named_write_master_zones':
#      ensure     => 'off',
#   }
#
# @param ensure Set to on or off
# @param persistent Set to false if you don't want it to survive a reboot.
#
define selinux::boolean (
  Variant[Boolean, Enum['on', 'off', 'present', 'absent']] $ensure = 'on',
  Boolean $persistent = true,
) {

  include ::selinux

  Anchor['selinux::module post']
  -> Selinux::Boolean[$title]
  -> Anchor['selinux::end']

  $ensure_real = $ensure ? {
    true    => 'on',
    false   => 'off',
    default => $ensure,
  }

  $value = $ensure_real ? {
    /(?i-mx:on|present)/ => 'on',
    /(?i-mx:off|absent)/ => 'off',
    default              => undef,
  }

  selboolean { $name:
    value      => $value,
    persistent => $persistent,
  }
}
