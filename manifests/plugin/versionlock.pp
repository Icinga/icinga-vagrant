# Class: yum::plugin::versionlock
#
# This class installs versionlock plugin
#
# Parameters:
#   [*ensure*] - specifies if versionlock should be present or absent
#   [*clean*] - specifies if yum clean all should be called after edits. Defaults false.
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
  String                    $path   = '/etc/yum/pluginconf.d/versionlock.list',
  Boolean                   $clean  = false,
) {

  yum::plugin { 'versionlock':
    ensure  => $ensure,
  }

  include yum::clean
  $_clean_notify = $clean ? {
    true  => Exec['yum_clean_all'],
    false => undef,
  }

  concat { $path:
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    notify => $_clean_notify,
  }

  concat::fragment { 'versionlock_header':
    target  => $path,
    content => "# File managed by puppet\n",
    order   => '01',
  }
}
