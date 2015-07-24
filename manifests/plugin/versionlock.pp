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
  $ensure = present
) {
  yum::plugin { 'versionlock':
    ensure  => $ensure,
  }
}
