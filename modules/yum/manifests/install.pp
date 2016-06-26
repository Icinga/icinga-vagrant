# Define: yum::install
#
# This definition installs or removes rpms from local file or URL via
# yum install command. This can be better than using just the rpm
# provider because it will pull all the dependencies.
#
# Parameters:
#   [*ensure*] - specifies if package group should be
#                present (installed) or absent (purged)
#   [*source*] - file or URL where RPM is available
#
# Actions:
#
# Requires:
#   RPM based system
#
# Sample usage:
#   yum::install { 'epel-release':
#     ensure => present,
#     source => 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm',
#   }
#
define yum::install (
  $source,
  $ensure  = present,
  $timeout = undef,
) {
  validate_string($source)

  Exec {
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    environment => 'LC_ALL=C'
  }

  case $ensure {
    present,installed: {
      exec { "yum-install-${name}":
        command => "yum -y install '${source}'",
        unless  => "rpm -q '${name}'",
        timeout => $timeout,
      }
    }

    absent,purged: {
      package { $name:
        ensure => $ensure,
      }
    }

    default: {
      fail("Invalid ensure state: ${ensure}")
    }
  }
}
