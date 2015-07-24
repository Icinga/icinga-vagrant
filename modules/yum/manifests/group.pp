# Define: yum::group
#
# This definition installs or removes yum package group.
#
# Parameters:
#   [*ensure*]   - specifies if package group should be
#                  present (installed) or absent (purged)
#
# Actions:
#
# Requires:
#   RPM based system
#
# Sample usage:
#   yum::group { 'X Window System':
#     ensure  => present,
#   }
#
define yum::group (
  $ensure = present
) {
  Exec {
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    environment => 'LC_ALL=C'
  }

  case $ensure {
    present,installed: {
      exec { "yum-groupinstall-${name}":
        command => "yum -y groupinstall '${name}'",
        unless  => "yum grouplist '${name}' | egrep -i '^Installed.+Groups:$'",
      }
    }

    absent,purged: {
      exec { "yum-groupremove-${name}":
        command => "yum -y groupremove '${name}'",
        onlyif  => "yum grouplist '${name}' | egrep -i '^Installed.+Groups:$'",
      }
    }

    default: {
      fail("Invalid ensure state: ${ensure}")
    }
  }
}
