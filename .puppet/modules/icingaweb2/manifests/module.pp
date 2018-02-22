# == Define: icingaweb2::module
#
# Download, enable and configure Icinga Web 2 modules. This is a public defined type and is meant to be used to install
# modules developed by the community as well.
#
# === Parameters
#
# [*ensure*]
#   Enable or disable module. Defaults to `present`
#
# [*module*]
#   Name of the module.
#
# [*module_dir*]
#   Target directory of the module.
#
# [*install_method*]
#   Install methods are `git`, `package` and `none` is supported as installation method. Defaults to `git`
#
# [*git_repository*]
#   Git repository of the module. This setting is only valid in combination with the installation method `git`.
#
# [*git_revision*]
#   Tag or branch of the git repository. This setting is only valid in combination with the installation method `git`.
#
# [*package_name*]
#   Package name of the module. This setting is only valid in combination with the installation method `package`.
#
# [*settings*]
#   A hash with the module settings. Multiple configuration files with ini sections can be configured with this hash.
#   The `module_name` should be used as target directory for the configuration files.
#
#   Example:
#
#     $conf_dir        = $::icingaweb2::params::conf_dir
#     $module_conf_dir = "${conf_dir}/modules/mymodule"
#
#     $settings = {
#       'section1' => {
#         'target'   => "${module_conf_dir}/config1.ini",
#         'settings' => {
#           'setting1' => 'value1',
#           'setting2' => 'value2',
#         }
#       },
#       'section2' => {
#         'target'   => "${module_conf_dir}/config2.ini",
#         'settings' => {
#           'setting3' => 'value3',
#           'setting4' => 'value4',
#         }
#       }
#     }
#
define icingaweb2::module(
  Enum['absent', 'present']         $ensure         = 'present',
  String                            $module         = $title,
  Stdlib::Absolutepath              $module_dir     = "${::icingaweb2::params::module_path}/${title}",
  Enum['git', 'none', 'package']    $install_method = 'git',
  Optional[String]                  $git_repository = undef,
  String                            $git_revision   = 'master',
  Optional[String]                  $package_name   = undef,
  Hash                              $settings       = {},
){
  $conf_dir   = $::icingaweb2::params::conf_dir
  $conf_user  = $::icingaweb2::conf_user
  $conf_group = $::icingaweb2::params::conf_group

  File {
    owner => $conf_user,
    group => $conf_group
  }

  if $ensure == 'present' {
    $ensure_module_enabled = 'link'
    $ensure_module_config_dir = 'directory'
    $ensure_vcsrepo = 'present'

    create_resources('icingaweb2::inisection', $settings)
  } else {
    $ensure_module_enabled = 'absent'
    $ensure_module_config_dir = 'absent'
    $ensure_vcsrepo = 'absent'
  }

  file {"${conf_dir}/enabledModules/${module}":
    ensure => $ensure_module_enabled,
    target => $module_dir,
  }

  file {"${conf_dir}/modules/${module}":
    ensure  => $ensure_module_config_dir,
    force   => true,
    recurse => true,
  }

  case $install_method {
    'git': {
      vcsrepo { $module_dir:
        ensure   => $ensure_vcsrepo,
        provider => 'git',
        source   => $git_repository,
        revision => $git_revision,
      }
    }
    'none': { }
    'package': {
      package { $package_name:
        ensure => $ensure,
      }
    }
    default: {
      fail('The installation method you provided is not supported.')
    }
  }
}
