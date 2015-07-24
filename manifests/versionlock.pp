# Define: yum::versionlock
#
# This definition locks package from updates.
#
# Parameters:
#   [*ensure*] - specifies if versionlock should be present, absent or exclude
#   [*path*]   - configuration of Yum plugin versionlock
#
# Actions:
#
# Requires:
#   RPM based system, Yum versionlock plugin
#
# Sample usage:
#   yum::versionlock { '0:bash-4.1.2-9.el6_2.*':
#     ensure  => present,
#   }
#
define yum::versionlock (
  $ensure = present,
  $path   = '/etc/yum/pluginconf.d/versionlock.list'
) {
  require yum::plugin::versionlock

  if ($name =~ /^[0-9]+:.+\*$/) {
    $_name = $name
  } elsif ($name =~ /^[0-9]+:.+-.+-.+\./) {
    $_name= "${name}*"
  } else {
    fail('Package name must be formated as \'EPOCH:NAME-VERSION-RELEASE.ARCH\'')
  }

  case $ensure {
    present,absent,exclude: {
      if ($ensure == present) or ($ensure == absent) {
        file_line { "versionlock.list-${name}":
          ensure => $ensure,
          line   => $_name,
          path   => $path,
        }
      }

      if ($ensure == exclude) or ($ensure == absent) {
        file_line { "versionlock.list-!${name}":
          ensure => $ensure,
          line   => "!${_name}",
          path   => $path,
        }
      }
    }

    default: {
      fail("Invalid ensure state: ${ensure}")
    }
  }
}
