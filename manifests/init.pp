# == Class: Kibana4
#
# Installs and configures Kibana4.
#
# === Parameters
#
# [*version*]
# Version of Kibana4 that gets installed.  Defaults to the latest version
# available in the `package_repo_version` that is selected.
#
# [*package_repo_version*]
# apt or yum repository version. Only used if 'package_use_official_repo' is set to 'true'.
# defaults to '4.5'.
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
# [*package_repo_proxy*]
# A proxy to use for downloading packages.
# Defaults to 'undef'. You can change this if you are behind a proxy
#
# [*babel_cache_path*]
# Kibana uses babel (https://www.npmjs.com/package/babel) which writes it's cache to this location
#
# === Examples
#
#   see README file
#
class kibana4 (
  $version                       = $kibana4::params::version,
  $package_repo_version          = $kibana4::params::package_repo_version,
  $package_repo_proxy            = undef,
  $service_ensure                = $kibana4::params::service_ensure,
  $service_enable                = $kibana4::params::service_enable,
  $service_name                  = $kibana4::params::service_name,
  $config                        = $kibana4::params::config,
  $plugins                       = undef,
) inherits kibana4::params {

  class {'kibana4::install': }->
  class {'kibana4::config': }->
  class {'kibana4::service': }

  Kibana4::Plugin { require => Class['kibana4::install'] }

  if $plugins {
    validate_hash($plugins)
    create_resources('kibana4::plugin', $plugins)
  }

}
