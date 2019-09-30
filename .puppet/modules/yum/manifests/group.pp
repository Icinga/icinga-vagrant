# Define: yum::group
#
# This definition installs or removes yum package group.
#
# Parameters:
#   [*ensure*]   - specifies if package group should be
#                  present (installed) or absent (purged)
#   [*timeout*]  - exec timeout for yum groupinstall command
#   [*install_options*]  - options provided to yum groupinstall command
#
# Actions:
#
# Requires:
#   RPM based system
#
# Sample usage:
#   yum::group { 'X Window System':
#     ensure  => 'present',
#   }
#
define yum::group (
  Array[String[1]]                                    $install_options = [],
  Enum['present', 'installed', 'absent', 'purged'] $ensure             = 'present',
  Optional[Integer] $timeout                                           = undef,
) {

  Exec {
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    environment => 'LC_ALL=C',
  }

  case $ensure {
    'present', 'installed', default: {
      exec { "yum-groupinstall-${name}":
        command => join(concat(["yum -y groupinstall '${name}'"], $install_options), ' '),
        unless  => "yum grouplist hidden '${name}' | egrep -i '^Installed.+Groups:$'",
        timeout => $timeout,
      }
    }

    'absent', 'purged': {
      exec { "yum-groupremove-${name}":
        command => "yum -y groupremove '${name}'",
        onlyif  => "yum grouplist hidden '${name}' | egrep -i '^Installed.+Groups:$'",
        timeout => $timeout,
      }
    }
  }
}
