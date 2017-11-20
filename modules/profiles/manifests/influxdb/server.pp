class profiles::influxdb::server (

) {

  class {'influxdb::server':
  }->
  file { 'influxdb-setup':
    name => '/usr/local/bin/influxdb-setup',
    owner => root,
    group => root,
    mode => '0755',
    content => template("profiles/influxdb/influxdb-setup.erb"),
  }
  ->
  exec { 'finish-influxdb-setup':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "/usr/local/bin/influxdb-setup",
    require => [ Class['influxdb::server::service'] ]
  }

}
