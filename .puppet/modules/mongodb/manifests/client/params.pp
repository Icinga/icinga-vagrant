# @api private
class mongodb::client::params inherits mongodb::globals {
  $package_ensure = pick($mongodb::globals::version, 'present')
  $manage_package = pick($mongodb::globals::manage_package, $mongodb::globals::manage_package_repo, false)

  if $manage_package {
    $package_name = "mongodb-${mongodb::globals::edition}-shell"
  } else {
    $package_name = $::osfamily ? {
      'Debian' => 'mongodb-clients',
      default  => 'mongodb',
    }
  }
}
