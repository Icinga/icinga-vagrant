# Class for installing a MongoDB client shell (CLI).
#
# == Parameters
#
# $ensure:: Desired ensure state of the package.
#
# $package_name:: Name of the package to install the client from. Default is
#                 repository dependent.
#
class mongodb::client (
  String[1] $ensure = $mongodb::client::params::package_ensure,
  String[1] $package_name = $mongodb::client::params::package_name,
) inherits mongodb::client::params {
  package { 'mongodb_client':
    ensure => $ensure,
    name   => $package_name,
    tag    => 'mongodb_package',
  }
}
