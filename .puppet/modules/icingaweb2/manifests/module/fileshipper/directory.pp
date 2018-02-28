# == Define: icingaweb2::module::fileshipper::directory
#
# Manage directories with plain Icinga 2 configuration files
#
# === Parameters
#
# [*identifier*]
#   Identifier of the base directory
#
# [*source*]
#   Absolute path of the source direcory
#
# [*target*]
#   Absolute path of the target direcory
#
# [*extensions*]
#   Only files with these extensions will be synced. Defaults to `.conf`
#
define icingaweb2::module::fileshipper::directory(
  String               $identifier = $title,
  Stdlib::Absolutepath $source     = undef,
  Stdlib::Absolutepath $target     = undef,
  String               $extensions = '.conf',
){
  assert_private("You're not supposed to use this defined type manually.")

  $conf_dir        = $::icingaweb2::params::conf_dir
  $module_conf_dir = "${conf_dir}/modules/fileshipper"

  icingaweb2::inisection { "fileshipper-directory-${identifier}":
    section_name => $identifier,
    target       => "${module_conf_dir}/directories.ini",
    settings     => {
      'source'     => $source,
      'target'     => $target,
      'extensions' => $extensions,
    }
  }
}