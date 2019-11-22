# @api private
class mongodb::opsmanager::install {
  #assert_private("You are calling a private class mongodb::opsmanager::install.")
  $package_ensure = $mongodb::opsmanager::package_ensure
  $package_name   = $mongodb::opsmanager::package_name
  $download_url   = $mongodb::opsmanager::download_url

  case $package_ensure {
    'absent': {
      $my_package_ensure = 'absent'
      $file_ensure       = 'absent'
    }
    default:  {
      $my_package_ensure = $package_ensure
      $file_ensure       = 'present'
    }
  }

  if versioncmp(fact('puppetversion'),'5.4.0') < 0 {
    case $facts['os']['family'] {
      'RedHat': {
        $my_provider = 'rpm'
      }
      'Debian': {
        $my_provider = 'dpkg'
      }
      default: {
        warning("The ${module_name} module might not work on ${facts['os']['family']}.  Sensible defaults will be attempted.")
        $my_provider = undef
      }
    }
  } else {
    $my_provider = undef
  }

  package { $package_name:
    ensure   => $my_package_ensure,
    source   => $download_url,
    provider => $my_provider,
  }
}
