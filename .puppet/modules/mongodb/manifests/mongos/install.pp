# PRIVATE CLASS: do not call directly
class mongodb::mongos::install (
  $package_ensure = $mongodb::mongos::package_ensure,
  $package_name   = $mongodb::mongos::package_name,
) {

  unless defined(Package[$package_name]) {
    package { 'mongodb_mongos':
      ensure => $package_ensure,
      name   => $package_name,
      tag    => 'mongodb_package',
    }
  }

}
