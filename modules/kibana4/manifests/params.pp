# == Class: kibana4
#
# Default parameters
#
class kibana4::params {
  $babel_cache_path              = '/tmp/babel.cache'
  $version                       = 'latest'
  $package_repo_version          = '4.5'
  $package_install_dir           = '/opt/kibana'
  $service_ensure                = true
  $service_enable                = true
  $service_name                  = 'kibana'
  case $::osfamily {
    'Debian': { $service_provider = debian }
    'RedHat': {
      case $::operatingsystemmajrelease {
        '7': { $service_provider = systemd }
        default: { $service_provider = init }
      }
    }
    default: { $service_provider = init   }
  }
  $config                        = undef
}
