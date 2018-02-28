# == Class: icingaweb2::module::fileshipper
#
# The fileshipper module extends the Director. It offers import sources to deal with CSV, JSON, YAML and XML files.
#
# === Parameters
#
# [*ensure*]
#   Enable or disable module. Defaults to `present`
#
# [*base_directories*]
#   Hash of base directories. These directories can later be selected in the import source (Director).
#
# [*directories*]
#   Deploy plain Icinga 2 configuration files through the Director to your Icinga 2 master.
#
class icingaweb2::module::fileshipper(
  Enum['absent', 'present'] $ensure           = 'present',
  String                    $git_repository   = 'https://github.com/Icinga/icingaweb2-module-fileshipper.git',
  Optional[String]          $git_revision     = undef,
  Hash                      $base_directories = {},
  Hash                      $directories      = {},
){

  $conf_dir        = $::icingaweb2::params::conf_dir
  $module_conf_dir = "${conf_dir}/modules/fileshipper"

  if $base_directories {
    $base_directories.each |$identifier, $directory| {
      icingaweb2::module::fileshipper::basedir{$identifier:
        basedir => $directory,
      }
    }
  }

  if $directories {
    $directories.each |$identifier, $settings| {
      icingaweb2::module::fileshipper::directory{$identifier:
        source     => $settings['source'],
        target     => $settings['target'],
        extensions => $settings['extensions'],
      }
    }
  }

  icingaweb2::module { 'fileshipper':
    ensure         => $ensure,
    git_repository => $git_repository,
    git_revision   => $git_revision,
  }
}
