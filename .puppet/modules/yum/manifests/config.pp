# Define: yum::config
#
# This definition manages yum.conf
#
# Parameters:
#   [*key*]      - alternative conf. key (defaults to name)
#   [*ensure*]   - specifies value or absent keyword
#   [*section*]  - config section (default to main)
#
# Actions:
#
# Requires:
#   RPM based system
#
# Sample usage:
#   yum::config { 'installonly_limit':
#     ensure => 2,
#   }
#
#   yum::config { 'debuglevel':
#     ensure => absent,
#   }
#
define yum::config (
  Variant[Boolean, Integer, Enum['absent'], String] $ensure,
  String                                            $key     = $title,
) {

  $_ensure = $ensure ? {
    Boolean => bool2num($ensure),
    default => $ensure,
  }

  $_changes = $ensure ? {
    'absent'  => "rm  ${key}",
    default   => "set ${key} '${_ensure}'",
  }

  augeas { "yum.conf_${key}":
    incl    => '/etc/yum.conf',
    lens    => 'Yum.lns',
    context => '/files/etc/yum.conf/main/',
    changes => $_changes,
  }
}
