class influxdb::server::service {

  if $influxdb::server::service_enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  service { 'influxdb':
    ensure     => $service_ensure,
    enable     => $influxdb::server::service_enabled,
    hasrestart => true,
    require    => Package['influxdb'],
  }

}
