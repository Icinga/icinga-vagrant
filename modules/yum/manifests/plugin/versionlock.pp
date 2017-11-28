# Class: yum::plugin::versionlock
#
# This class installs versionlock plugin
#
# Parameters:
#   [*ensure*] - specifies if versionlock should be present or absent
#
# Actions:
#
# Requires:
#
# Sample usage:
#   include yum::plugin::versionlock
#
class yum::plugin::versionlock (
  Enum['present', 'absent'] $ensure = 'present',
  String                    $path   = '/etc/yum/pluginconf.d/versionlock.list'
) {
  yum::plugin { 'versionlock':
    ensure  => $ensure,
  }
  concat { $path:
    mode  => '0644',
    owner => 'root',
    group => 'root',
  }

  concat::fragment { 'versionlock_header':
    target  => $path,
    content => "# File managed by puppet\n",
    order   => '01',
  }
}
