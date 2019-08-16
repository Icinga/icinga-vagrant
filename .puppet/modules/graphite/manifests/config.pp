# == Class: graphite::config
#
# This class configures graphite/carbon/whisper and SHOULD NOT
# be called directly.
#
# === Parameters
#
# None.
#
class graphite::config inherits graphite::params {
  Exec {
    path => '/bin:/usr/bin:/usr/sbin' }

  # for full functionality we need this packages:
  # mandatory: python-cairo, python-django, python-twisted,
  #            python-django-tagging, python-simplejson
  # optional:  python-ldap, python-memcache, memcached, python-sqlite

  if ($::osfamily == 'RedHat' and $::operatingsystemrelease =~ /^7\.\d+/) or ($::graphite::gr_service_provider == 'systemd') {
    $initscript_notify = [Exec['graphite-reload-systemd'],]

    exec { 'graphite-reload-systemd':
      command     => 'systemctl daemon-reload',
      path        => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      refreshonly => true,
    }
  } else {
    $initscript_notify = []
  }

  # we need an web server with python support
  # apache with mod_wsgi or nginx with gunicorn
  case $::graphite::gr_web_server {
    'apache'   : {
      $gr_web_user_REAL = pick($::graphite::gr_web_user, $::graphite::params::apache_web_user)
      $gr_web_group_REAL = pick($::graphite::gr_web_group, $::graphite::params::apache_web_group)
      include graphite::config_apache
      $web_server_package_require = [Package[$::graphite::params::apache_pkg]]
      $web_server_service_notify = Service[$::graphite::params::apache_service_name]
    }

    'nginx'    : {
      # Configure gunicorn and nginx.
      $gr_web_user_REAL = pick($::graphite::gr_web_user, $::graphite::params::nginx_web_user)
      $gr_web_group_REAL = pick($::graphite::gr_web_group, $::graphite::params::nginx_web_group)
      include graphite::config_gunicorn
      include graphite::config_nginx
      $web_server_package_require = [Package['nginx']]
      $web_server_service_notify = Service['gunicorn']
    }

    'wsgionly' : {
      # Configure gunicorn only without nginx.
      if !$::graphite::gr_web_user or !$::graphite::gr_web_group {
        fail('having $gr_web_server => \'wsgionly\' requires use of $gr_web_user and $gr_web_group')
      }
      $gr_web_user_REAL = pick($::graphite::gr_web_user)
      $gr_web_group_REAL = pick($::graphite::gr_web_group)
      include graphite::config_gunicorn
      $web_server_package_require = undef
    }

    'none'     : {
      # Don't configure apache, gunicorn or nginx. Leave all webserver configuration to something external.
      if !$::graphite::gr_web_user or !$::graphite::gr_web_group {
        fail('Having $gr_web_server => \'none\' requires use of $gr_web_user and $gr_web_group to set correct file owner for your own webserver setup.'
        )
      }
      $gr_web_user_REAL = pick($::graphite::gr_web_user)
      $gr_web_group_REAL = pick($::graphite::gr_web_group)
      $web_server_package_require = undef
      $web_server_service_notify = undef
    }

    default    : {
      fail('The only supported web servers are \'apache\', \'nginx\', \'wsgionly\' and \'none\'')
    }
  }

  if $::graphite::gr_pip_install {
    $local_settings_py_file = "${::graphite::graphiteweb_install_lib_dir_REAL}/local_settings.py"
    $syncdb_require = File[$local_settings_py_file]
  } else {
    # using custom directories.
    file { "${::graphite::graphiteweb_conf_dir_REAL}/manage.py":
      ensure => link,
      target => "${::graphite::params::libpath}/graphite/manage.py"
    }
    $local_settings_py_file = "${::graphite::graphiteweb_conf_dir_REAL}/local_settings.py"
    $syncdb_require = [File[$local_settings_py_file], File["${::graphite::graphiteweb_conf_dir_REAL}/manage.py"]]
  }

  $carbon_conf_file = "${::graphite::carbon_conf_dir_REAL}/carbon.conf"
  $graphite_web_managepy_location = $::graphite::gr_pip_install ? {
    false   => $::graphite::graphiteweb_conf_dir_REAL,
    default => $::graphite::graphiteweb_install_lib_dir_REAL,
  }

  # first init of user db for graphite
  exec { 'Initial django db creation':
    command     => $::graphite::gr_django_init_command,
    provider    => $::graphite::gr_django_init_provider,
    cwd         => $graphite_web_managepy_location,
    refreshonly => true,
    require     => $syncdb_require,
    subscribe   => Class['graphite::install'],
  }

  if !$::graphite::gr_base_dir_managed_externally {
    # change access permissions for web server
    file { $::graphite::base_dir_REAL:
      ensure  => directory,
      group   => $gr_web_group_REAL,
      mode    => '0755',
      owner   => $gr_web_user_REAL,
      seltype => 'httpd_sys_rw_content_t',
    }
  }

  file { [
    $::graphite::storage_dir_REAL,
    $::graphite::rrd_dir_REAL,
    $::graphite::whitelists_dir_REAL,
    $::graphite::graphiteweb_log_dir_REAL,
    $::graphite::graphiteweb_storage_dir_REAL,
    "${::graphite::base_dir_REAL}/bin"]:
    ensure    => directory,
    group     => $gr_web_group_REAL,
    mode      => '0755',
    owner     => $gr_web_user_REAL,
    seltype   => 'httpd_sys_rw_content_t',
    subscribe => Exec['Initial django db creation'],
  }

  # change access permissions for carbon-cache to align with gr_user
  # (if different from web_user)

  if $::graphite::gr_user != '' {
    $carbon_user = $::graphite::gr_user
    $carbon_group = $::graphite::gr_group
  } else {
    $carbon_user = $gr_web_user_REAL
    $carbon_group = $gr_web_group_REAL
  }

  file {
    $::graphite::local_data_dir_REAL:
      ensure  => directory,
      group   => $carbon_group,
      mode    => '0755',
      seltype => 'httpd_sys_rw_content_t',
      owner   => $carbon_user;

    $::graphite::carbon_log_dir_REAL:
      ensure  => directory,
      group   => $carbon_group,
      mode    => '0755',
      seltype => 'httpd_sys_rw_content_t',
      owner   => $carbon_user;
  }

  # Lets ensure graphite.db owner is the same as gr_web_user_REAL
  file { "${::graphite::storage_dir_REAL}/graphite.db":
    ensure    => file,
    group     => $gr_web_group_REAL,
    mode      => '0644',
    seltype   => 'httpd_sys_rw_content_t',
    owner     => $gr_web_user_REAL,
    subscribe => Exec['Initial django db creation'],
  }

  # Deploy configfiles
  file {
    $local_settings_py_file:
      ensure  => file,
      content => template('graphite/opt/graphite/webapp/graphite/local_settings.py.erb'),
      group   => $gr_web_group_REAL,
      mode    => '0644',
      owner   => $gr_web_user_REAL,
      require => $web_server_package_require,
      seltype => 'httpd_sys_content_t',
      notify  => $web_server_service_notify;

    "${::graphite::graphiteweb_conf_dir_REAL}/graphite_wsgi.py":
      ensure  => file,
      content => template('graphite/opt/graphite/conf/graphite.wsgi.erb'),
      group   => $gr_web_group_REAL,
      mode    => '0644',
      owner   => $gr_web_user_REAL,
      require => $web_server_package_require,
      seltype => 'httpd_sys_content_t',
      notify  => $web_server_service_notify;

    "${::graphite::graphiteweb_install_lib_dir_REAL}/graphite_wsgi.py":
      ensure  => link,
      target  => "${::graphite::graphiteweb_conf_dir_REAL}/graphite_wsgi.py",
      require => File["${::graphite::graphiteweb_conf_dir_REAL}/graphite_wsgi.py"],
      notify  => $web_server_service_notify;
  }

  if $::graphite::gr_remote_user_header_name {
    file { "${::graphite::graphiteweb_install_lib_dir_REAL}/custom_auth.py":
      ensure  => file,
      content => template('graphite/opt/graphite/webapp/graphite/custom_auth.py.erb'),
      group   => $gr_web_group_REAL,
      mode    => '0644',
      owner   => $gr_web_user_REAL,
      seltype => 'httpd_sys_rw_content_t',
      require => $web_server_package_require,
    }
  }

  # configure carbon engines
  if $::graphite::gr_enable_carbon_cache {
    $service_cache = Service['carbon-cache']
  } else {
    $service_cache = undef
  }

  if $::graphite::gr_enable_carbon_relay {
    $service_relay = Service['carbon-relay']
  } else {
    $service_relay = undef
  }

  if $::graphite::gr_enable_carbon_aggregator {
    $service_aggregator = Service['carbon-aggregator']
  } else {
    $service_aggregator = undef
  }

  $notify_services = delete_undef_values([$service_cache, $service_relay, $service_aggregator])

  if $::graphite::gr_enable_carbon_relay {
    file { "${::graphite::carbon_conf_dir_REAL}/relay-rules.conf":
      ensure  => file,
      content => template('graphite/opt/graphite/conf/relay-rules.conf.erb'),
      mode    => '0644',
      notify  => $notify_services,
      seltype => 'httpd_sys_content_t',
    }
  }

  if $::graphite::gr_enable_carbon_aggregator {
    file { "${::graphite::carbon_conf_dir_REAL}/aggregation-rules.conf":
      ensure  => file,
      mode    => '0644',
      content => template('graphite/opt/graphite/conf/aggregation-rules.conf.erb'),
      seltype => 'httpd_sys_content_t',
      notify  => $notify_services;
    }
  }

  file {
    "${::graphite::carbon_conf_dir_REAL}/storage-schemas.conf":
      ensure  => file,
      content => template('graphite/opt/graphite/conf/storage-schemas.conf.erb'),
      mode    => '0644',
      seltype => 'httpd_sys_content_t',
      notify  => $notify_services;

    $carbon_conf_file:
      ensure  => file,
      content => template('graphite/opt/graphite/conf/carbon.conf.erb'),
      mode    => '0644',
      notify  => $notify_services;

    "${::graphite::carbon_conf_dir_REAL}/storage-aggregation.conf":
      ensure  => file,
      content => template('graphite/opt/graphite/conf/storage-aggregation.conf.erb'),
      seltype => 'httpd_sys_content_t',
      mode    => '0644';

    "${::graphite::carbon_conf_dir_REAL}/whitelist.conf":
      ensure  => file,
      content => template('graphite/opt/graphite/conf/whitelist.conf.erb'),
      seltype => 'httpd_sys_content_t',
      mode    => '0644';

    "${::graphite::carbon_conf_dir_REAL}/blacklist.conf":
      ensure  => file,
      content => template('graphite/opt/graphite/conf/blacklist.conf.erb'),
      seltype => 'httpd_sys_content_t',
      mode    => '0644';
  }

  # configure logrotate script for carbon
  if $::graphite::gr_enable_logrotation {
    file { "${::graphite::base_dir_REAL}/bin/carbon-logrotate.sh":
      ensure  => file,
      mode    => '0544',
      content => template('graphite/opt/graphite/bin/carbon-logrotate.sh.erb'),
    }

    cron { 'Rotate carbon logs':
      command => "${::graphite::base_dir_REAL}/bin/carbon-logrotate.sh",
      hour    => 3,
      minute  => 15,
      require => File["${::graphite::base_dir_REAL}/bin/carbon-logrotate.sh"],
      user    => root,
    }
  }
  # startup carbon engine

  if $::graphite::gr_enable_carbon_cache {
    service { 'carbon-cache':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      provider   => $::graphite::gr_service_provider,
      require    => File['/etc/init.d/carbon-cache'],
    }

    file { '/etc/init.d/carbon-cache':
      ensure  => file,
      content => template("graphite/etc/init.d/${::osfamily}/carbon-cache.erb"),
      mode    => '0750',
      require => File[$carbon_conf_file],
      notify  => $initscript_notify,
    }
  }

  if $graphite::gr_enable_carbon_relay {
    service { 'carbon-relay':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      provider   => $::graphite::gr_service_provider,
      require    => File['/etc/init.d/carbon-relay'],
    }

    file { '/etc/init.d/carbon-relay':
      ensure  => file,
      content => template("graphite/etc/init.d/${::osfamily}/carbon-relay.erb"),
      mode    => '0750',
      require => File[$carbon_conf_file],
      notify  => $initscript_notify,
    }
  }

  if $graphite::gr_enable_carbon_aggregator {
    service { 'carbon-aggregator':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      provider   => $::graphite::gr_service_provider,
      require    => File['/etc/init.d/carbon-aggregator'],
    }

    file { '/etc/init.d/carbon-aggregator':
      ensure  => file,
      content => template("graphite/etc/init.d/${::osfamily}/carbon-aggregator.erb"),
      mode    => '0750',
      require => File[$carbon_conf_file],
      notify  => $initscript_notify,
    }
  }

}
