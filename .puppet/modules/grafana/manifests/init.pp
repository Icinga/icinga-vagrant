# == Class: grafana
#
# Installs and configures Grafana.
#
# === Parameters
# [*archive_source*]
# Download location of tarball to be used with the 'archive' install method.
# Defaults to the URL of the latest version of Grafana available at the time of module release.
#
# [*container_cfg*]
# Boolean. Determines whether a configuration file should be generated when using the 'docker' install method.
# If true, use the `cfg` and `cfg_location` parameters to control creation of the file.
# Defaults to false.
#
# [*container_params*]
# Hash of parameters to use when creating the Docker container. For use with the 'docker' install method.
# Refer to documentation of the `docker::run` resource in the `garethr-docker` module for details of available parameters.
# Defaults to:
#
#   container_params => {
#     'image' => 'grafana/grafana:latest',
#     'ports' => '3000'
#   }
#
# [*data_dir*]
# The directory Grafana will use for storing its data.
# Defaults to '/var/lib/grafana'.
#
# [*install_dir*]
# Installation directory to be used with the 'archive' install method.
# Defaults to '/usr/share/grafana'.
#
# [*install_method*]
# Set to 'archive' to install Grafana using the tar archive.
# Set to 'docker' to install Grafana using the official Docker container.
# Set to 'package' to install Grafana using .deb or .rpm packages.
# Set to 'repo' to install Grafana using an apt or yum repository.
# Defaults to 'package'.
#
# [*manage_package_repo*]
# If true this will setup the official grafana repositories on your host. Defaults to true.
#
# [*package_name*]
# The name of the package managed with the 'package' install method.
# Defaults to 'grafana'.
#
# [*package_source*]
# Download location of package to be used with the 'package' install method.
# Defaults to the URL of the latest version of Grafana available at the time of module release.
#
# [*service_name*]
# The name of the service managed with the 'archive' and 'package' install methods.
# Defaults to 'grafana-server'.
#
# [*version*]
# The version of Grafana to install and manage.
# Defaults to the latest version of Grafana available at the time of module release.
#
# [*repo_name*]
# When using 'repo' install_method, the repo to look for packages in.
# Set to 'stable' to install only stable versions
# Set to 'testing' to install beta versions
# Defaults to stable.
#
# [*plugins*]
# A hash of plugins to be passed to `create_resources`, wraps around the
# `grafana_plugin` resource.
#
# === Examples
#
#  class { '::grafana':
#    install_method  => 'docker',
#  }
#
class grafana (
  Optional[String] $archive_source     = undef,
  String $cfg_location                 = $::grafana::params::cfg_location,
  Hash $cfg                            = $::grafana::params::cfg,
  Optional[Hash] $ldap_cfg             = undef,
  Boolean $container_cfg               = $::grafana::params::container_cfg,
  Hash $container_params               = $::grafana::params::container_params,
  String $data_dir                     = $::grafana::params::data_dir,
  String $install_dir                  = $::grafana::params::install_dir,
  String $install_method               = $::grafana::params::install_method,
  Boolean $manage_package_repo         = $::grafana::params::manage_package_repo,
  String $package_name                 = $::grafana::params::package_name,
  Optional[String] $package_source     = undef,
  Enum['stable', 'testing'] $repo_name = $::grafana::params::repo_name,
  String $rpm_iteration                = $::grafana::params::rpm_iteration,
  String $service_name                 = $::grafana::params::service_name,
  String $version                      = $::grafana::params::version,
  Hash $plugins                        = {}
) inherits grafana::params {

  contain grafana::install
  contain grafana::config
  contain grafana::service

  Class['grafana::install']
  -> Class['grafana::config']
  ~> Class['grafana::service']

  create_resources(grafana_plugin, $plugins)

  Grafana_Plugin <| |> ~> Class['grafana::service']

}
