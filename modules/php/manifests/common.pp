# Class: php::common
#
# Class to avoid duplicate definitions for the php-common package, not meant to
# be used from outside the php module's own classes and definitions.
#
# We can't use a virtual resource, since we have no central place to put it.
#
class php::common (
  $common_package_name = $::php::params::common_package_name,
) inherits ::php::params {
  package { $common_package_name: ensure => 'installed' }
}
