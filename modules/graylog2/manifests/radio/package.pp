# == Class: graylog2::radio::package
#
# === Authors
#
# Renan Silva <renanvice@gmail.com>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::radio::package(
  $package,
  $version,
) {

  package { $package:
    ensure  => $version,
  }

}
