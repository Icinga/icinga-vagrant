#
class influxdb::repo {

  case $::osfamily {
    'Debian': {
      require influxdb::repo::apt
    }

    'RedHat': {
      require influxdb::repo::yum
    }

    default: {
      fail("Unsupported managed repository for osfamily: ${::osfamily}, operatingsystem: ${::operatingsystem},\
      module ${module_name} currently only supports managing repos for osfamily RedHat and Debian")
    }

  }

}
