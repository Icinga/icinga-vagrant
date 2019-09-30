# @summary Configure the system for module building
#
# Config for module building
# --------------------------
#
# The module building requires the following file structure:
#
# ```
# $module_build_root/
#   bin/ # for simple module build script
#   modules/ # module source files and compiled policies
#   modules/tmp # repolicy tempfiles (created by scripts)
# ```
#
# @param module_build_root See main class
#
# @api private
#
class selinux::build(
  Stdlib::Absolutepath $module_build_root = $selinux::module_build_root,
) {
  file {$module_build_root:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file {"${module_build_root}/bin":
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  $module_build_simple = "${module_build_root}/bin/selinux_build_module_simple.sh"

  # put helper in place:
  file {$module_build_simple:
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/selinux_build_module_simple.sh",
  }

  $module_build_dir = "${module_build_root}/modules"

  file {$module_build_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    recurse => true,
    purge   => true,
    force   => true,
  }

  # needed by refpolicy builder and our simple builder
  file {"${module_build_dir}/tmp":
    ensure                  => 'directory',
    selinux_ignore_defaults => true,
  }
}
