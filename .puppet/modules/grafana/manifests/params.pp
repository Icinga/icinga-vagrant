# == Class grafana::params
#
# This class is meant to be called from grafana
# It sets variables according to platform
#
class grafana::params {
  $cfg                 = {}
  $container_cfg       = false
  $container_params    = {}
  $data_dir            = '/var/lib/grafana'
  $docker_image        = 'grafana/grafana'
  $docker_ports        = '3000:3000'
  $install_dir         = '/usr/share/grafana'
  $package_name        = 'grafana'
  $rpm_iteration       = '1'
  $repo_name           = 'stable'
  $version             = '4.5.1'
  case $::osfamily {
    'Archlinux': {
      $manage_package_repo = false
      $install_method      = 'repo'
      $cfg_location        = '/etc/grafana.ini'
      $service_name        = 'grafana'
    }
    'Debian', 'RedHat': {
      $manage_package_repo = true
      $install_method      = 'repo'
      $cfg_location        = '/etc/grafana/grafana.ini'
      $service_name        = 'grafana-server'
    }
    default: {
      $manage_package_repo = true
      $install_method      = 'package'
      $cfg_location        = '/etc/grafana/grafana.ini'
      $service_name        = 'grafana-server'
    }
  }
}
