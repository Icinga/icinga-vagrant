class profiles::icinga::icinga2 (
  $features = {},
  $packages = [],
  $confd = 'demo'
){
  # Always initialize the main features required
  $basic_features = [ 'checker', 'notification', 'mainlog' ]

  # Allow to add more packages
  $real_packages = [ 'nagios-plugins-all', 'vim-icinga2', 'icinga2-debuginfo' ] + $packages

  class { '::icinga2':
    manage_repo => false,
    confd       => $confd,
    features    => $basic_features, # all other features are specifically invoked below.
  }
  ->
  package { $real_packages:
    ensure => 'latest',
  }

  file { 'check_mysql_health':
    name => '/usr/lib64/nagios/plugins/check_mysql_health',
    owner => root,
    group => root,
    mode => '0755',
    content => template("profiles/icinga/check_mysql_health.erb")
  }

  # TODO: remove hardcoded names
  mysql::db { 'icinga':
    user      => 'icinga',
    password  => 'icinga',
    host      => 'localhost',
    charset   => 'latin1',
    collate   => 'latin1_general_ci',
    grant     => [ 'ALL' ]
  }

  class{ '::icinga2::feature::idomysql':
    user          => 'icinga',
    password      => 'icinga',
    database      => 'icinga',
    import_schema => true,
    require       => Mysql::Db['icinga'],
  }

  class { '::icinga2::feature::api':
    pki => 'none',
    accept_commands => true,
    accept_config   => true,
  }

  class { '::icinga2::pki::ca': }

  # Features
  if (has_key($features, 'elasticsearch')) {
    $elasticsearch = $features['elasticsearch']

    class { '::icinga2::feature::elasticsearch':
      host => $elasticsearch['listen_ip'],
      port => $elasticsearch['listen_port'],
      enable_send_perfdata => true
    }
  }

  # Config
  file { '/etc/icinga2/demo':
    ensure  => directory,
    tag     => icinga2::config::file
  }

  File {
    owner => 'icinga',
    group => 'icinga',
    mode  => '0644',
  }

  # TODO: Split demo based on parameters; standalone vs cluster
  file { '/etc/icinga2/demo/api-users.conf':
    ensure  => present,
    mode    => '0644',
    content => template("profiles/icinga/icinga2/config/demo/api-users.conf.erb"),
    tag     => icinga2::config::file,
    require => File['/etc/icinga2/demo']
  }
  ->
  file { '/etc/icinga2/demo/many.conf':
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/many.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { '/etc/icinga2/demo/hosts.conf':
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/hosts.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { '/etc/icinga2/demo/services.conf':
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/services.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { '/etc/icinga2/demo/templates.conf':
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/templates.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { '/etc/icinga2/demo/groups.conf':
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/groups.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { '/etc/icinga2/demo/notifications.conf':
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/notifications.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { '/etc/icinga2/demo/commands.conf':
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/commands.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { '/etc/icinga2/demo/timeperiods.conf':
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/timeperiods.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { '/etc/icinga2/demo/users.conf':
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/users.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { '/etc/icinga2/demo/additional_services.conf':
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/additional_services.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { '/etc/icinga2/demo/bp.conf':
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/bp.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { '/etc/icinga2/demo/cube.conf':
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/cube.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { '/etc/icinga2/demo/maps.conf':
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/maps.conf.erb"),
    tag     => icinga2::config::file
  }
}

