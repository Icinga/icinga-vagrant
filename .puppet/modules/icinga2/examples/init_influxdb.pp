class { 'icinga2':
  manage_repo => true,
}

include icinga2::feature::influxdb
