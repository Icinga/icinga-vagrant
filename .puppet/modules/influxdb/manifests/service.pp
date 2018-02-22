#
class influxdb::service(
  $service_ensure  = $influxdb::service_ensure,
  $service_enabled = $influxdb::service_enabled,
  $manage_service  = $influxdb::manage_service,
){

  if $manage_service {

    service { 'influxdb':
      ensure     => $service_ensure,
      enable     => $service_enabled,
      hasrestart => true,
      hasstatus  => true,
      require    => Package['influxdb'],
    }

  }

}
