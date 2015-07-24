# == Class: graylog2::dashboard
#
# === Authors
#
# Jonas Genannt <jonas@brachium-system.net>
#
# === Copyright
#
# Copyright 2014 Jonas Genannt
#
class graylog2::dashboard(
  $package_version      = $graylog2::dashboard::params::package_version,
) inherits graylog2::dashboard::params  {

  anchor {'graylog2::dashboard::start': }->
  class {'graylog2::dashboard::package':
    package => $graylog2::dashboard::params::package_name,
    version => $package_version,
  } ->
  anchor {'graylog2::dashboard::end': }
}
