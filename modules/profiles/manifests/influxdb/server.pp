class profiles::influxdb::server (
  $repo_version = undef
) {

  class { '::influxdb':
    manage_repos   => true,
    manage_service => true,
    version        => $repo_version
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
    require => [ Class['influxdb::service'] ]
  }

}
