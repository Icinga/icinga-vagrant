# == Class: graylog2::web::package
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::web::package(
  $package,
  $version,
) {

  package { $package:
    ensure  => $version,
  }

}
