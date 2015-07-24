# == Class: graylog2::dashboard::params
#
# === Authors
#
# Jonas Genannt <jonas@brachium-system.net>
#
# === Copyright
#
# Copyright 2014 Jonas Genannt
#
class graylog2::dashboard::params {

  # OS specific settings.
  case $::osfamily {
    'Debian', 'RedHat': {
      # Nothing yet.
    }
    default: {
      fail("${::osfamily} is not supported by ${module_name}")
    }
  }

  $package_name = 'graylog2-stream-dashboard'

  $package_version = 'installed'

}
