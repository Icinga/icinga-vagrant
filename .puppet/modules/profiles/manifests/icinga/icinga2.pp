class profiles::icinga::icinga2 (
  $features = {},
  $packages = [],
  $node_name = 'icinga2',
  $zone_name = undef, # optional for cluster setups - begin
  $ca_cert = undef,
  $ca_key = undef,
  $node_cert = undef,
  $node_key = undef,
  $zones = undef,
  $endpoints = undef, # optional for cluster setups - end
  $api_users = {
    'root' => {
      password => 'icinga',
      permissions => [ "*" ]
    },
    'dashing' => {
      password => 'icinga2ondashingr0xx',
      permissions => [ "status/query", "objects/query/*" ]
    },
    'icingaweb2' => {
     password => 'icingaweb2apitransport',
     permissions => [ "status/query", "actions/*", "objects/modify/*", "objects/query/*" ]
    }
  },
  $graylog_listen_ip = lookup('graylog::web::listen_ip'),
  $graylog_listen_port = lookup('graylog::web::listen_port') # use a local variable here for the config, erb templates don't like hiera much
){
  # Always initialize the main features required
  $basic_features = [ 'checker', 'notification', 'mainlog' ]

  # Allow to add more packages
  $real_packages = [ 'vim-icinga2', 'icinga2-debuginfo' ] + $packages

  # standalone environments need a local configuration
  if (!$zone_name) {
    $real_confd = 'demo'
  }

  class { '::icinga2':
    manage_repo => false,
    confd       => $real_confd,
    features    => $basic_features, # all other features are specifically invoked below.
    constants   => {
      'NodeName'    => $node_name,
    },
#    require     => Yumrepo['icinga-snapshot-builds']
    require     => Class['::profiles::base::system']
  }
  ->
  package { $real_packages:
    ensure => 'latest',
  }
  ->
  class { '::profiles::icinga::plugins':

  }

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

  if (!$ca_cert and !$ca_key) {
    class { '::icinga2::pki::ca': }

    class { '::icinga2::feature::api':
      pki             => 'none', # manage them.
      accept_commands => true,
      accept_config   => true,
    }

  } elsif ($zone_name == 'master') {
    # Only the master is allowed to have its own CA
    class { '::icinga2::pki::ca': # this automatically creates a new node certificate
      ca_cert => $ca_cert,
      ca_key  => $ca_key
    }
    class { '::icinga2::feature::api':
      pki             => 'none', # manage them.
      accept_commands => true,
      accept_config   => true,
      endpoints       => $endpoints,
      zones           => $zones
    }

  } else {
    # satellite
    class { '::icinga2::feature::api':
      pki             => 'none', # only manage certificate files
      ssl_cacert      => $ca_cert, # use the configured satellite certificates
      ssl_key         => $node_key,
      ssl_cert        => $node_cert,
      accept_commands => true,
      accept_config   => true,
      endpoints       => $endpoints,
      zones           => $zones
    }
  }

  icinga2::object::zone { 'global-templates':
    global => true,
  }

  icinga2::object::zone { 'director-global':
    global => true,
  }


  # Features
  if (has_key($features, 'graphite')) {
    $graphite = $features['graphite']

    class { '::icinga2::feature::graphite':
      host => $graphite['listen_ip'],
      port => $graphite['listen_port'],
    }
  }
  if (has_key($features, 'influxdb')) {
    $influxdb = $features['influxdb']

    class { '::icinga2::feature::influxdb':
      host => $influxdb['listen_ip'],
      port => $influxdb['listen_port'],
      enable_send_metadata => true,
      enable_send_thresholds => true
    }
  }
  if (has_key($features, 'elasticsearch')) {
    $elasticsearch = $features['elasticsearch']

    class { '::icinga2::feature::elasticsearch':
      host => $elasticsearch['listen_ip'],
      port => $elasticsearch['listen_port'],
      enable_send_perfdata => true
    }
  }
  if (has_key($features, 'gelf')) {
    $gelf = $features['gelf']

    class { '::icinga2::feature::gelf':
      host => $gelf['listen_ip'],
      port => $gelf['listen_port'],
      enable_send_perfdata => true
    }
  }

  # other Icinga2 features are not supported by this profile.

  # Config
  if ($zone_name == 'master') {
    $config_path = "/etc/icinga2/zones.d/satellite" # the master zone puts everything into the satellite zone. find a better way, TODO.
  } else {
    $config_path = '/etc/icinga2/demo'
  }

  file { 'confd':
    path    => '/etc/icinga2/conf.d',
    ensure  => directory,
    purge   => true,
    recurse => true,
  }

  $api_users.each |$name, $attrs| {
     icinga2::object::apiuser { "$name":
       ensure => present,
       password => $attrs['password'],
       permissions => $attrs['permissions'],
       target => "$config_path/api-users.conf"
     }
  }

  file { $config_path:
    ensure  => directory,
    tag     => icinga2::config::file,
  }

  File {
    owner => 'icinga',
    group => 'icinga',
    mode  => '0644',
  }

  # TODO: Split demo based on parameters; standalone vs cluster
  file { "$config_path/many.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/many.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/namespaces.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/namespaces.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/hosts.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/hosts.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/services.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/services.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/templates.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/templates.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/groups.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/groups.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/notifications.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/notifications.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/commands.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/commands.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/timeperiods.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/timeperiods.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/users.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/users.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/additional_services.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/additional_services.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/bp.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/bp.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/network.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/network.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/health.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/health.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/cube.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/cube.conf.erb"),
    tag     => icinga2::config::file
  }
  ->
  file { "$config_path/maps.conf":
    ensure  => present,
    content => template("profiles/icinga/icinga2/config/demo/maps.conf.erb"),
    tag     => icinga2::config::file
  }
}

