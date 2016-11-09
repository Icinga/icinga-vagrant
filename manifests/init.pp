# == Class: kibana5
#
# Installs and configures Kibana5 on a host. Modeled after
# https://github.com/lesaux/puppet-kibana4.git.
#
# === Parameters
#
# [*version*]
# Version of Kibana4 that gets installed.  Defaults to the latest version
# available in the `package_repo_version` that is selected.
#
# [*manage_repo*]
# Enable repo management by enabling the official repositories.
#
# [*package_repo_version*]
# apt or yum repository version. Only used if 'package_use_official_repo' is
# set to 'true'.
# defaults to '4.5'.
#
# [*package_repo_proxy*]
# A proxy to use for downloading packages.
# Defaults to 'undef'. You can change this if you are behind a proxy
#
# [*service_ensure*]
# Specifies the service state. Valid values are stopped (false) and running
# (true). Defaults to 'running'.
#
# [*service_enable*]
# Should the service be enabled on boot. Valid values are true, false, and
# manual. Defaults to 'true'.
#
# [*service_name*]
# Name of the Kibana4 service. Defaults to 'kibana'.
#
# [*babel_cache_path*]
# Kibana uses babel (https://www.npmjs.com/package/babel) which writes it's
# cache to this location
#
# === Examples
#
#   see README file
#
class kibana5 (
  $version              = '5.0.0',
  $manage_repo          = true,
  $package_repo_version = '5.x',
  $package_repo_proxy   = undef,
  $service_ensure       = true,
  $service_enable       = true,
  $service_name         = 'kibana',
  $config               = undef,
  $plugins              = undef,
  $config_dir           = '/etc/kibana',
  $install_dir          = '/usr/share/kibana',
  $bin_dir              = '/usr/share/kibana/bin',
) {

  validate_bool($manage_repo)

  if ($manage_repo) {
    validate_string($package_repo_version)
  }

  case $::osfamily {
    'Debian': {    $service_provider = debian }
    'RedHat': {
      case $::operatingsystemmajrelease {
        '7': {     $service_provider = systemd }
        default: { $service_provider = init }
      }
    }
    default: {     $service_provider = init }
  }

  include kibana5::install
  include kibana5::config
  include kibana5::service

  Class['kibana5::install'] ->
  Class['kibana5::config'] ->
  Class['kibana5::service']

  Kibana4::Plugin {
    require => Class['kibana5::install']
  }

  if $plugins {
    validate_hash($plugins)
    create_resources('kibana5::plugin', $plugins)
  }
}
