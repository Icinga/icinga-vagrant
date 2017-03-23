# Class: kibana::service
#
# This class is meant to be called from kibana.
# It ensure the service is running.
#
class kibana::service {

  $_ensure = $::kibana::ensure != 'absent'
  $_enable = $::kibana::ensure != 'absent'

  service { 'kibana':
    ensure => $_ensure,
    enable => $_enable,
  }
}
