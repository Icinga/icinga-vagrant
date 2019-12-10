class profiles::grafana::server (
  $version = '4.6.3',
  $listen_ip = '192.168.33.5',
  $listen_port = 8004,
  $backend = 'graphite',
  $backend_port = 8003
) {
  class { 'grafana':
    version => $version,
    install_method => 'repo',
    manage_package_repo => true,
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
      # better performance for Grafana module in Icinga Web 2 with direct access.
      'auth.anonymous' => {
        enabled => 'true'
      }
    },
  }


  if ('prometheus' in $backend) {

  file { "grafana-${backend}-setup":
    name => "/usr/local/bin/grafana-${backend}-setup",
    owner => root,
    group => root,
    mode => "0755",
    content => template("profiles/grafana/grafana-${backend}-setup.erb")
  }

  } else {

  # there are no static config files for data sources in Grafana
  # https://github.com/grafana/grafana/issues/1789
  file { "grafana-${backend}-setup":
    name => "/usr/local/bin/grafana-${backend}-setup",
    owner => root,
    group => root,
    mode => "0755",
    content => template("profiles/grafana/grafana-${backend}-setup.erb")
  }
  ->
  file { "${backend}-dashboard-vagrant-grafana-demo":
    name => "/etc/grafana/${backend}-dashboard-vagrant-grafana-demo.json",
    owner => root,
    group => root,
    mode => "0644",
    content => template("profiles/grafana/templates/${backend}-dashboard-vagrant-grafana-demo.json.erb")
  }
  ->
  file { "${backend}-base-metrics-grafana-web-module":
    name => "/etc/grafana/${backend}-base-metrics-grafana-web-module.json",
    owner => root,
    group => root,
    mode => "0644",
    content => template("profiles/grafana/templates/${backend}-base-metrics-grafana-web-module.json.erb")
  }
  ->
  file { "${backend}-icinga2-default-grafana-web-module":
    name => "/etc/grafana/${backend}-icinga2-default-grafana-web-module.json",
    owner => root,
    group => root,
    mode => "0644",
    content => template("profiles/grafana/templates/${backend}-icinga2-default-grafana-web-module.json.erb")
  }
  ->
  exec { "finish-grafana-${backend}-setup":
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    command => "/usr/local/bin/grafana-${backend}-setup",
    require => Class["grafana::service"]
  }

  } # if prometheus
}
