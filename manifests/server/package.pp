# == Class: graylog2::server::package
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::server::package(
  $package,
  $version,
) {

  package { $package:
    ensure  => $version,
  }

}
