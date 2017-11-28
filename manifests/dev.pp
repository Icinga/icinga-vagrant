# Install the development package with headers for PHP
#
# === Parameters
#
# [*ensure*]
#   The PHP ensure of PHP dev to install
#
# [*package*]
#   The package name for the PHP development files
#
class php::dev(
  String $ensure  = $::php::ensure,
  String $package = "${::php::package_prefix}${::php::params::dev_package_suffix}",
) inherits ::php::params {

  if $caller_module_name != $module_name {
    warning('php::dev is private')
  }

  # On FreeBSD there is no 'devel' package.
  $real_package = $facts['os']['family'] ? {
    'FreeBSD' => [],
    default   => $package,
  }

  # Default PHP come with xml module and no seperate package for it
  if $facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['full'], '16.04') >= 0  {
    ensure_packages(["${php::package_prefix}xml"], {
      ensure  => present,
      require => Class['::apt::update'],
    })

    package { $real_package:
      ensure  => $ensure,
      require => Class['::php::packages'],
    }
  } else {
    package { $real_package:
      ensure  => $ensure,
      require => Class['::php::packages'],
    }
  }
}
