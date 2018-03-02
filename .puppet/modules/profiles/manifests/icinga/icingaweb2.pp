class profiles::icinga::icingaweb2 (
  $icingaweb2_listen_ip = '192.168.33.5',
  $icingaweb2_fqdn = 'icingaweb2.vagrant-demo.icinga.com',
  $node_name = 'icinga2',
  $api_username = 'root',
  $api_password = 'icinga',
  $modules = {},
  $themes = {}
) {
  apache::vhost { "${icingaweb2_fqdn}-http":
    priority        => 5,
    port            => '80',
    docroot         => '/var/www/html',
    rewrites => [
      {
        rewrite_rule => ['^/$ /icingaweb2 [NE,L,R=301]'],
      },
    ],
  }

  apache::vhost { "${icingaweb2_fqdn}-https":
    priority        => 5,
    port            => '443',
    docroot         => '/var/www/html',
    ssl		  => true,
    add_listen      => false, #prevent duplicate listen entries
    rewrites => [
      {
        rewrite_rule => ['^/$ /icingaweb2 [NE,L,R=301]'],
      },
    ],
  }

  # Use our own apache config instead of RPM?
  file { '/etc/httpd/conf.d/icingaweb2.conf':
    owner => root,
    group => root,
    mode  => '0644',
    content => template("profiles/icinga/icingaweb2/apache_fpm.conf.erb"),
  }

  file { '/usr/local/bin/php':
    ensure => link,
    target => '/opt/rh/rh-php71/root/usr/bin/php',
  } -> Class['php::composer::auto_update']

  package { [ 'scl-utils', 'centos-release-scl' ]:
    ensure => present,
  }->
  # Workaround for PHP module not allowing to configure log path
  file { [ '/var/opt', '/var/opt/rh', '/var/opt/rh/rh-php71' ]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750'
  }
  ->
  file { [ '/var/opt/rh/rh-php71/log', '/var/opt/rh/rh-php71/log/php-fpm' ]:
    ensure => directory,
    owner  => 'apache',
    group  => 'apache',
    mode   => '0770'
  }
  ->
  file { '/var/log/php-fpm':
    ensure => link,
    source => '/var/opt/rh/rh-php71/log/php-fpm'
  }
  ->
  class { '::php::globals':
    config_root   => '/etc/opt/rh/rh-php71',
    fpm_pid_file  => '/var/opt/rh/rh-php71/run/php-fpm/php-fpm.pid',
  }->
  class { '::php':
    package_prefix => 'rh-php71-php-', # most important
    config_root_ini => '/etc/opt/rh/rh-php71',
    config_root_inifile => '/etc/opt/rh/rh-php71/php.ini',

    manage_repos => false,
    fpm => true,
    fpm_package        => 'rh-php71-php-fpm',
    fpm_service_name   => 'rh-php71-php-fpm',
    fpm_service_enable => true,
    fpm_service_ensure => 'running',
    fpm_inifile        => '/etc/opt/rh/rh-php71/php-fpm.ini',
    #fpm_error_log      => '/var/opt/rh/rh-php71/log/php-fpm',
    fpm_user           => 'apache', # rh-php71 prefers apache
    fpm_group          => 'apache',
    dev => true,
    composer => true,
    pear => true,
    phpunit => true,
    settings => {
      'PHP/memory_limit'    => '256M',
      'Date/date.timezone' => 'Europe/Berlin',
    },
    extensions => {
      pdo => {},
      mysqlnd => {},
    },
    # NOTE for future reference: DO NOT build imagick with PECL. That fails heavily, either with pear not in PATH and then configure & make on missing imagick-devel packages.
    # I'll rather shoot myself before doing so. We'll wait for SCL packages.
  }
  ->
  mysql::db { 'icingaweb2':
    user      => 'icingaweb2',
    password  => 'icingaweb2',
    host      => 'localhost',
    grant     => [ 'ALL' ]
  }
  # Icinga Web 2 itself
  ->
  class { '::icingaweb2':
    manage_repo   => false, # done in profiles::base::system
    import_schema => true,  # imports DB schema and creates a default user icinga/icinga
    db_type       => 'mysql',
    db_host       => 'localhost',
    db_port       => 3306,
    db_username   => 'icingaweb2',
    db_password   => 'icingaweb2'
  }
  ->
  class { '::icingaweb2::module::monitoring':
    ido_host           => 'localhost',
    ido_db_name        => 'icinga',
    ido_db_username    => 'icinga',
    ido_db_password    => 'icinga',
    commandtransports  => {
      icinga2 => {
        transport => 'api', # Use full-blown root, not best practice.
        username  => $api_username,
        password  => $api_password
      }
    }
  }
  ->
  package { 'icingaweb2-selinux':
    ensure => latest,
  }

  $default_user    = "icingaadmin"
  $conf_dir        = $::icingaweb2::params::conf_dir
  $pref_conf_dir   = "${conf_dir}/preferences"
  $dash_conf_dir   = "${conf_dir}/dashboards"
  $default_dash_conf_path = "${dash_conf_dir}/${default_user}/dashboard.ini"

  # Preferences. Assume to use 'icingaadmin' as default user, provided by the icingaweb2 class
  file { [ "${pref_conf_dir}", "${pref_conf_dir}/${default_user}" ]:
    ensure => directory,
    owner  => root,
    group  => icingaweb2,
    mode => '2770',
    require => Class['::icingaweb2']
  }
  ->
  # Dashboards. Assume to use 'icingaadmin' as default user, provided by the icingaweb2 class
  file { [ "${dash_conf_dir}", "${dash_conf_dir}/${default_user}" ]:
    ensure => directory,
    owner  => root,
    group  => icingaweb2,
    mode => '2770'
  }
  ->
  concat { "$default_dash_conf_path":
    owner => root,
    group => icingaweb2,
    mode  => '0660'
  }

  # Modules

  # Director
  if ('director' in $modules) {
    $director_git_revision = $modules['director']['git_revision']

    mysql::db { 'director':
      user      => 'director',
      password  => 'director',
      host      => 'localhost',
      charset   => 'utf8',
      grant     => [ 'ALL' ]
    }

    # wait until Icinga 2 and the REST API is fully available.
    exec { 'http-conn-validator-icinga-api':
      path => '/bin:/usr/bin:/sbin:/usr/sbin',
      command => "/usr/local/bin/http-conn-validator \"https://$api_username:$api_password@localhost:5665/v1\"",
      timeout => 1800,
      require => Class['icinga2::service']
    }
    ->
    class {'icingaweb2::module::director':
      git_revision  => $director_git_revision,
      db_host       => 'localhost',
      db_name       => 'director',
      db_username   => 'director',
      db_password   => 'director',
      import_schema => true,
      kickstart     => true,
      endpoint      => $node_name,
      api_username  => $api_username,
      api_password  => $api_password,
      require       => Mysql::Db['director']
    }
  }

  # Map
  if ('map' in $modules) {
    $map_module_conf_dir = "${conf_dir}/modules/map"

    $map_settings = {
      'module-map' => {
        'section_name' => 'map',
        'target'       => "${map_module_conf_dir}/config.ini",
        'settings'     => {
          'stateType'      => 'hard',
          'default_zoom'   => '6',
        }
      }
    }

    icingaweb2::module { 'map':
      install_method => 'git',
      git_repository => 'https://github.com/nbuchwitz/icingaweb2-module-map.git',
      git_revision   => 'master',
      settings       => $map_settings,
    }
    ->
    concat::fragment { "module_maps_dashboards":
      target  => $default_dash_conf_path,
      content => template("profiles/icinga/icingaweb2/modules/map/dashboard.ini.erb"),
      order   => '10'
    }
  }

  # Cube
  if ('cube' in $modules) {
    $cube_module_conf_dir = "${conf_dir}/modules/cube"

    class { 'icingaweb2::module::cube':
      git_revision   => 'master',
    }
    ->
    concat::fragment { "module_cube_dashboards":
      target  => $default_dash_conf_path,
      content => template("profiles/icinga/icingaweb2/modules/cube/dashboard.ini.erb"),
      order   => '01'
    }
  }

  # Globe
  if ('globe' in $modules) {
    $globe_module_conf_dir = "${conf_dir}/modules/globe"

    icingaweb2::module { 'globe':
      install_method => 'git',
      git_repository => 'https://github.com/Mikesch-mp/icingaweb2-module-globe.git',
      git_revision   => 'master'
    }
  }

  # Business Process
  if ('businessprocess' in $modules) {
    $businessprocess_module_conf_dir = "${conf_dir}/modules/businessprocess"

    class { 'icingaweb2::module::businessprocess':
      git_revision   => 'master'
    }
    ->
    file { "${businessprocess_module_conf_dir}/processes":
      ensure => directory,
      owner  => root,
      group  => icingaweb2,
      mode => '2770'
    }
    ->
    file { "${businessprocess_module_conf_dir}/processes/all.conf":
      ensure => present,
      owner  => root,
      group  => icingaweb2,
      mode => '0660',
      content => template("profiles/icinga/icingaweb2/modules/businessprocess/processes/all.conf.erb")
    }
    ->
    file { "${businessprocess_module_conf_dir}/processes/web.conf":
      ensure => present,
      owner  => root,
      group  => icingaweb2,
      mode => '0660',
      content => template("profiles/icinga/icingaweb2/modules/businessprocess/processes/web.conf.erb")
    }
    ->
    file { "${businessprocess_module_conf_dir}/processes/mysql.conf":
      ensure => present,
      owner  => root,
      group  => icingaweb2,
      mode => '0660',
      content => template("profiles/icinga/icingaweb2/modules/businessprocess/processes/mysql.conf.erb")
    }
    ->
    concat::fragment { "module_businessprocess_dashboards":
      target  => $default_dash_conf_path,
      content => template("profiles/icinga/icingaweb2/modules/businessprocess/dashboard.ini.erb"),
      order   => '01'
    }
  }

  # Grafana
  if ('grafana' in $modules) {
    $grafana_datasource = $modules['grafana']['datasource']
    $grafana_listen_ip = $modules['grafana']['listen_ip']
    $grafana_listen_port = $modules['grafana']['listen_port']

    $grafana_module_conf_dir = "${conf_dir}/modules/grafana"

    $grafana_settings = {
      'module-grafana' => {
        'section_name'  => 'grafana',
        'target'        => "${grafana_module_conf_dir}/config.ini",
        'settings'      => {
          'username'              => 'admin',
          'password'              => 'admin',
          'host'                  => "${grafana_listen_ip}:${grafana_listen_port}",
          'protocol'              => 'http',
          'height'                => '280',
          'width'                 => '640',
          'timerange'             => '1h',
          'enableLink'            => 'yes',
          'default-dashboard'     => 'icinga2-default',
          'datasource'            => $grafana_datasource,
          'defaultdashboardstore' => 'db',
          'accessmode'            => 'direct',
          'timeout'               => '30'
        }
      }
    }

    icingaweb2::module { 'grafana':
      install_method => 'git',
      git_repository => 'https://github.com/Mikesch-mp/icingaweb2-module-grafana.git',
      git_revision   => 'master',
      settings       => $grafana_settings,
    }
    ->
    # TODO: Move this somewhere else.
    file { '/etc/icingaweb2/preferences':
      ensure => directory,
      owner  => root,
      group  => icingaweb2,
      mode => '2770',
      require => Package['icingaweb2']
    }
    ->
    file { '/etc/icingaweb2/preferences/icingaadmin':
      ensure => directory,
      owner  => root,
      group  => icingaweb2,
      mode => '2770',
    }
    ->
    file { '/etc/icingaweb2/preferences/icingaadmin/menu.ini': #TODO: Use Concat::Fragment and do not override it
      ensure => present,
      owner  => root,
      group  => icingaweb2,
      mode => '0660',
      content => template("profiles/icinga/icingaweb2/preferences/icingaadmin/menu_grafana.ini.erb")
    }
  }

  # Graphite
  if ('graphite' in $modules) {
    $graphite_listen_ip = $modules['graphite']['listen_ip']
    $graphite_listen_port = $modules['graphite']['listen_port']

    $graphite_module_conf_dir = "${conf_dir}/modules/graphite"

    $graphite_instance_name = 'graphite'

    $graphite_settings = {
      'module-graphite-general' => {
        'section_name'  => 'graphite',
        'target'        => "${graphite_module_conf_dir}/config.ini",
        'settings'      => {
          'url'                  => "http://${graphite_listen_ip}:${graphite_listen_port}",
        }
      },
      'module-graphite-ui' => {
        'section_name'  => 'ui',
        'target'        => "${graphite_module_conf_dir}/config.ini",
        'settings'      => {
          'default_time_range'      => '5',
          'default_time_range_unit' => 'minutes',
          'disable_no_graphs_found' => '0'
        }
      },
    }

    icingaweb2::module { 'graphite':
      install_method => 'git',
      git_repository => 'https://github.com/icinga/icingaweb2-module-graphite.git',
      git_revision   => 'master',
      settings       => $graphite_settings,
    }
  }

  # Elasticsearch
  if ('elasticsearch' in $modules) {
    $elasticsearch_listen_ip = $modules['elasticsearch']['listen_ip']
    $elasticsearch_listen_port = $modules['elasticsearch']['listen_port']

    $elasticsearch_module_conf_dir = "${conf_dir}/modules/elasticsearch"

    $elasticsearch_instance_name = 'elasticsearch'

    $elasticsearch_settings = {
      'module-elasticsearch-instances' => {
        'section_name'  => $elasticsearch_instance_name,
        'target'        => "${elasticsearch_module_conf_dir}/instances.ini",
        'settings'      => {
          #'user'                  => 'admin',
          #'password'              => 'admin',
          'uri'                  => "http://${elasticsearch_listen_ip}:${elasticsearch_listen_port}",
        }
      },
      'module-elasticsearch-eventtypes' => {
        'section_name'  => 'icinga2',
        'target'        => "${elasticsearch_module_conf_dir}/eventtypes.ini",
        'settings'      => {
          'instance'              => $elasticsearch_instance_name,
          'index'                 => 'icinga2-*',
          'filter'                => 'host={host.name}',
          'fields'                => '*'
        }
      }
    }

    icingaweb2::module { 'elasticsearch':
      install_method => 'git',
      git_repository => 'https://github.com/icinga/icingaweb2-module-elasticsearch.git',
      git_revision   => 'master',
      settings       => $elasticsearch_settings,
    }
  }

  # Graylog
  if ('graylog' in $modules) {
    $graylog_listen_ip = $modules['graylog']['listen_ip']
    $graylog_listen_port = $modules['graylog']['listen_port']

    $graylog_module_conf_dir = "${conf_dir}/modules/graylog"

    $graylog_instance_name = 'graylog'

    $graylog_settings = {
      'module-graylog-instances' => {
        'section_name'  => $graylog_instance_name,
        'target'        => "${graylog_module_conf_dir}/instances.ini",
        'settings'      => {
          'user'                  => 'admin',
          'password'              => 'admin',
          'uri'                  => "http://${graylog_listen_ip}:${graylog_listen_port}/api",
        }
      },
      'module-graylog-eventtypes' => {
        'section_name'  => 'icinga2',
        'target'        => "${graylog_module_conf_dir}/eventtypes.ini",
        'settings'      => {
          'instance'              => $graylog_instance_name,
          'index'                 => 'icinga2-*',
          'filter'                => 'host={host.name}',
          'fields'                => '*'
        }
      }
    }

    icingaweb2::module { 'graylog':
      install_method => 'git',
      git_repository => 'https://github.com/icinga/icingaweb2-module-graylog.git',
      git_revision   => 'master',
      settings       => $graylog_settings,
    }
  }

  # Themes

  if ('company' in $themes) {
    icingaweb2::module { 'company':
      install_method => 'git',
      git_repository => 'https://github.com/Icinga/icingaweb2-theme-company',
      git_revision   => 'master',
    }
  }

  if ('always-green' in $themes) {
    icingaweb2::module { 'always-green':
      install_method => 'git',
      git_repository => 'https://github.com/xam-stephan/icingaweb2-module-theme-always-green',
      git_revision   => 'master',
    }
  }

  if ('lsd' in $themes) {
    icingaweb2::module { 'lsd':
      install_method => 'git',
      git_repository => 'https://github.com/Mikesch-mp/icingaweb2-theme-lsd',
      git_revision   => 'master',
    }
  }

  if ('unicorn' in $themes) {
    icingaweb2::module { 'unicorn':
      install_method => 'git',
      git_repository => 'https://github.com/Mikesch-mp/icingaweb2-theme-unicorn',
      git_revision   => 'master',
    }
    ->
    wget::retrieve { 'retrieve-unicorn-image':
      source      => 'http://i.imgur.com/SCfMd.png',
      destination => '/usr/share/icingaweb2/modules/unicorn/public/img/unicorn.png',
      timeout     => 180,
      verbose     => false,
      unless      => "test $(ls -A /usr/share/icingaweb2/modules/unicorn/public/img/unicorn.png 2>/dev/null)",
    }
  }

  if ('batman' in $themes) {
    icingaweb2::module { 'batman':
      install_method => 'git',
      git_repository => 'https://github.com/jschanz/icingaweb2-theme-batman',
      git_revision   => 'master',
    }
  }
}

