# filebeat::install::linux
#
# Install the linux filebeat package
#
# @summary A simple class to install the filebeat package
#
class filebeat::install::linux {
  package {'filebeat':
    ensure => $filebeat::package_ensure,
  }
}
