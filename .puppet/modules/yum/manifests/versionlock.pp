# Define: yum::versionlock
#
# This definition locks package from updates.
#
# NOTE: The resource title must use the format
#   "%{EPOCH}:%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}".  This can be retrieved via
#   the command `rpm -q --qf '%{EPOCH}:%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}'.
#   If "%{EPOCH}" returns as '(none)', it should be set to '0'.  Wildcards may
#   be used within token slots, but must not cover seperators, e.g.,
#   '0:b*sh-4.1.2-9.*' covers Bash version 4.1.2, revision 9 on all
#   architectures.
#
# Parameters:
#   [*ensure*] - specifies if versionlock should be present, absent or exclude
#
# Actions:
#
# Requires:
#   RPM based system, Yum versionlock plugin
#
# Sample usage:
#   yum::versionlock { '0:bash-4.1.2-9.el6_2.*':
#     ensure  => 'present',
#   }
#
define yum::versionlock (
  Enum['present', 'absent', 'exclude'] $ensure = 'present',
) {
  contain ::yum::plugin::versionlock

  unless $name.is_a(Yum::VersionlockString) {
    fail('Package name must be formated as %{EPOCH}:%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}. See Yum::Versionlock documentation for details.')
  }

  $line_prefix = $ensure ? {
    'exclude' => '!',
    default => '',
  }

  case $ensure {
    'present', 'exclude', default: {
      concat::fragment { "yum-versionlock-${name}":
        content => "${line_prefix}${name}\n",
        target  => $yum::plugin::versionlock::path,
      }
    }
    'absent':{
      # fragment will be removed
    }
  }
}
