# == Class: graylog2::dashboard::package
#
# === Authors
#
# Jonas Genannt <jonas@brachium-system.net>
#
# === Copyright
#
# Copyright 2014 Jonas Genannt
#
class graylog2::dashboard::package(
  $package,
  $version,
) {

  package { $package:
    ensure  => $version,
  }

}
