# PRIVATE CLASS: do not use directly
class influxdb::install(
  $ensure         = $influxdb::ensure,
  $version        = $influxdb::version,
  $manage_repos   = $influxdb::manage_repos,
  $manage_install = $influxdb::manage_install,
){

  if $manage_repos {
    require influxdb::repo
  }

  if $manage_install {

    $_ensure = $ensure ? {
      'absent' => $ensure,
      default  => $version,
    }

    package { 'influxdb':
      ensure => $_ensure,
      tag    => 'influxdb',
    }

  }

}
