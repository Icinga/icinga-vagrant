class profiles::grafana::server (
  $version = '4.2.0-1',
  $listen_port = 8004,
  $backend = 'graphite'
) {
  # https://github.com/bfraser/puppet-grafana
  class { 'grafana':
    package_source => "https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-${version}.x86_64.rpm",
    cfg => {
      app_mode => 'production',
      server   => {
        http_port     => $listen_port,
      },
      users    => {
        allow_sign_up => false,
      },
      security => {
        admin_user => 'admin',
        admin_password => 'admin',
      },
    },
  }


  if ($backend == 'graphite') {

  } elsif ($backend == 'influxdb') {
    # there are no static config files for data sources in grafana2
    # https://github.com/grafana/grafana/issues/1789
    file { 'grafana-influxdb-setup':
      name => '/usr/local/bin/grafana-influxdb-setup',
      owner => root,
      group => root,
      mode => '0755',
      content => template('profiles/grafana/grafana-influxdb-setup.erb')
    }
    ->
    file { 'influxdb-dashboard-vagrant-grafana-demo':
      name => '/etc/grafana/influxdb-dashboard-vagrant-grafana-demo.json',
      owner => root,
      group => root,
      mode => '0644',
      content => template('profiles/grafana/templates/influxdb-dashboard-vagrant-grafana-demo.json.erb')
    }
    ->
    file { 'influxdb-base-metrics_grafana-web-module':
      name => '/etc/grafana/influxdb-base-metrics_grafana-web-module.json',
      owner => root,
      group => root,
      mode => '0644',
      content => template('profiles/grafana/templates/influxdb-base-metrics_grafana-web-module.json.erb')
    }
    ->
    file { 'influxdb-icinga2-default-grafana-web-module':
      name => '/etc/grafana/influxdb-icinga2-default-grafana-web-module.json',
      owner => root,
      group => root,
      mode => '0644',
      content => template('profiles/grafana/templates/influxdb-icinga2-default-grafana-web-module.json.erb')
    }
    ->
    exec { 'finish-grafana-influxdb-setup':
      path => '/bin:/usr/bin:/sbin:/usr/sbin',
      command => "/usr/local/bin/grafana-influxdb-setup",
      require => [ Class['grafana::service'], Class['influxdb::server::service'] ]
    }

  }

}
