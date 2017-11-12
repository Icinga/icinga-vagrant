# Install and configure php apache settings
#
# === Parameters
#
# [*inifile*]
#   The path to the ini php-apache ini file
#
# [*settings*]
#   Hash with nested hash of key => value to set in inifile
#
class php::apache_config(
  $inifile  = $::php::params::apache_inifile,
  $settings = {}
) inherits ::php::params {

  if $caller_module_name != $module_name {
    warning('php::apache_config is private')
  }

  validate_absolute_path($inifile)
  validate_hash($settings)

  $real_settings = deep_merge($settings, hiera_hash('php::apache::settings', {}))

  ::php::config { 'apache':
    file   => $inifile,
    config => $real_settings,
  }
}
