# PRIVATE CLASS: do not use directly
class influxdb::server::install {
  $ensure = $influxdb::server::ensure
  $version = $influxdb::server::version

  Exec {
    path => '/usr/bin:/bin',
  }

  if $influxdb::server::manage_repos {
    class { 'influxdb::repo': }
  }

  if $influxdb::server::manage_install {
    if $ensure == 'absent' {
      $_ensure = $ensure
    } else {
        $_ensure = $version
    }

    package { 'influxdb':
      ensure => $_ensure,
      tag    => 'influxdb',
    }
  }
}
