# Definition: selinux::module
#
# Description
#  This class will either install or uninstall a SELinux module from a running system.
#  This module allows an admin to keep .te files in text form in a repository, while
#  allowing the system to compile and manage SELinux modules.
#
#  Concepts incorporated from:
#  http://stuckinadoloop.wordpress.com/2011/06/15/puppet-managed-deployment-of-selinux-modules/
#
# Parameters:
#   - $ensure: (present|absent) - sets the state for a module
#   - $selinux::params::sx_mod_dir: The directory compiled modules will live on a system (default: /usr/share/selinux)
#   - $mode: Allows an admin to set the SELinux status. (default: enforcing)
#   - $source: the source file (either a puppet URI or local file) of the SELinux .te module
#
# Actions:
#  Compiles a module using 'checkmodule' and 'semodule_package'.
#
# Requires:
#  - SELinux
#
# Sample Usage:
#  selinux::module{ 'apache':
#    ensure => 'present',
#    source => 'puppet:///modules/selinux/apache.te',
#  }
#
define selinux::module(
  $source,
  $ensure         = 'present',
  $use_makefile   = false,
  $makefile       = '/usr/share/selinux/devel/Makefile',
) {

  include selinux

  if $::selinux_config_policy in ['targeted','strict']
  {
    $selinux_policy = $::selinux_config_policy
  }
  elsif $::selinux_custom_policy
  {
    $selinux_policy = $::selinux_custom_policy
  }

  # Set Resource Defaults
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  # Only allow refresh in the event that the initial .te file is updated.
  Exec {
    path         => '/sbin:/usr/sbin:/bin:/usr/bin',
    refreshonly  => true,
    cwd          => $selinux::params::sx_mod_dir,
  }

  exec { "${name}-checkloaded":
    refreshonly => false,
    creates     => "/etc/selinux/${selinux_policy}/modules/active/modules/${name}.pp",

    command     => 'true', # lint:ignore:quoted_booleans
    notify      => Exec["${name}-buildmod"],
  }

  ## Begin Configuration
  file { "${::selinux::params::sx_mod_dir}/${name}.te":
    ensure => $ensure,
    source => $source,
    tag    => "selinux-module-${name}",
  }
  if !$use_makefile {
    file { "${::selinux::params::sx_mod_dir}/${name}.mod":
      tag   => ["selinux-module-build-${name}", "selinux-module-${name}"],
    }
  }
  file { "${::selinux::params::sx_mod_dir}/${name}.pp":
    tag   => ["selinux-module-build-${name}", "selinux-module-${name}"],
  }

  # Specific executables based on present or absent.
  case $ensure {
    present: {
      if $use_makefile {
        exec { "${name}-buildmod":
          command => 'true', # lint:ignore:quoted_booleans
        }
        exec { "${name}-buildpp":
          command => "make -f ${makefile} ${name}.pp",
        }
      } else {
        exec { "${name}-buildmod":
          command => "checkmodule -M -m -o ${name}.mod ${name}.te",
        }
        exec { "${name}-buildpp":
          command => "semodule_package -m ${name}.mod -o ${name}.pp",
        }
      }
      exec { "${name}-install":
        command => "semodule -i ${name}.pp",
      }

      # Set dependency ordering
      File["${::selinux::params::sx_mod_dir}/${name}.te"]
      ~> Exec["${name}-buildmod"]
      ~> Exec["${name}-buildpp"]
      ~> Exec["${name}-install"]
      -> File<| tag == "selinux-module-build-${name}" |>
    }
    absent: {
      exec { "${name}-remove":
        command => "semodule -r ${name}.pp > /dev/null 2>&1",
      }

      # Set dependency ordering
      Exec["${name}-remove"]
      -> File<| tag == "selinux-module-${name}" |>
    }
    default: {
      fail("Invalid status for SELinux Module: ${ensure}")
    }
  }
}
