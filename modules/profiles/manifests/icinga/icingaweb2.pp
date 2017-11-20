class profiles::icinga::icingaweb2 (
  $icingaweb2_listen_ip = '192.168.33.5',
  $icingaweb2_fqdn = 'icingaweb2.vagrant-demo.icinga.com',
  $modules = {}
) {

  # TODO: Replace Apache with Nginx
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


  # TODO for v2.0.0: Replace Apache with Nginx
  #class { 'nginx':
  #  confd_purge => true,
  #}

  #nginx::resource::server { $icingaweb2_fqdn:
  #  ensure              => present,
  #  www_root            => '/usr/share/icingaweb2/public',
  #  location_cfg_append => {
  #    'rewrite'             => '^/$ /icingaweb2 redirect'
  #  }
  #}
  #nginx::resource::location { "${icingaweb2_fqdn}-fastcgi":
  #  ensure              => present,
  #  server              => $icingaweb2_fqdn,
  #  location            => '~ ^/icingaweb2/index\.php(.*)$',
  #  fastcgi_index       => 'index.php',
  #  fastcgi_split_path  => '^(.+\.php)(/.+)$',
  #  fastcgi             => "127.0.0.1:9000",
  #  fastcgi_param       => {
  #    'SCRIPT_FILENAME'     => '/usr/share/icingaweb2/public/index.php',
  #    'ICINGAWEB_CONFIGDIR' => '/etc/icingaweb2',
  #    'REMOTE_USER'         => '$remote_user'
  #  }
  #}
  #nginx::resource::location { "${icingaweb2_fqdn}-public":
  #  ensure              => present,
  #  server              => $icingaweb2_fqdn,
  #  www_root            => '/usr/share/icingaweb2/public',
  #  location            => '~ ^/icingaweb2(.+)?',
  #  index_files         => [ 'index.php' ],
  #  location_cfg_append => {
  #    'try_files'           => '$1 $uri $uri/ /icingaweb2/index.php$is_args$args'
  #  }
  #}
  ## Avoid favicon.ico not found error messages
  ## https://nichteinschalten.de/de/icingaweb2-unter-nginx-betreiben/
  #nginx::resource::location { "${icingaweb2_fqdn}-favicon":
  #  ensure              => present,
  #  server              => $icingaweb2_fqdn,
  #  www_root            => '/usr/share/icingaweb2/public',
  #  location            => '/favicon.ico',
  #  location_cfg_append => {
  #    'log_not_found' => 'off',
  #    'access_log'    => 'off',
  #    'expires'       => 'max'
  #  }
  #}
  #@user { nginx: ensure => present }
  #User<| title == nginx |>{
  #  groups +> ['icingaweb2']
  #}



  package { [ 'scl-utils', 'centos-release-scl' ]:
    ensure => present,
  }->
  class { '::php::globals':
    config_root => '/etc/opt/rh/rh-php71',
    fpm_pid_file => '/var/opt/rh/rh-php71/run/php-fpm/php-fpm.pid'
  }->
  class { '::php':
    package_prefix => 'rh-php71-php-', # most important
    config_root_ini => '/etc/opt/rh/rh-php71',
    config_root_inifile => '/etc/opt/rh/rh-php71/php.ini',

    manage_repos => false,
    fpm => true,
    fpm_package => 'rh-php71-php-fpm',
    fpm_service_name => 'rh-php71-php-fpm',
    fpm_service_enable => true,
    fpm_service_ensure => 'running',
    #fpm_user => 'nginx', #requires to change package permissions, rh-php71 prefers apache
    #fpm_group => 'nginx', #not supported by puppet3 branch of puppet-php
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
  # Icinga Web itself
  ->
  class { '::icingaweb2': # TODO: Replace with official module with Puppet 5 support
  }
  ->
  package { 'icingaweb2-selinux':
    ensure => latest,
  }
  ->
  mysql::db { 'icingaweb2':
    user      => 'icingaweb2',
    password  => 'icingaweb2',
    host      => 'localhost',
    grant     => [ 'ALL' ]
  }
  ->
  exec { 'populate-icingaweb2-mysql-db':
    path 	=> '/bin:/usr/bin:/sbin:/usr/sbin',
    unless  	=> 'mysql -uicingaweb2 -picingaweb2 icingaweb2 -e "SELECT * FROM icingaweb_user;" &> /dev/null',
    command 	=> 'mysql -uicingaweb2 -picingaweb2 icingaweb2 < /usr/share/doc/icingaweb2/schema/mysql.schema.sql; mysql -uicingaweb2 -picingaweb2 icingaweb2 -e "INSERT INTO icingaweb_user (name, active, password_hash) VALUES (\'icingaadmin\', 1, \'\$1\$iQSrnmO9\$T3NVTu0zBkfuim4lWNRmH.\');"',
    require => [ Mysql::Db['icingaweb2'], Class['icingaweb2'] ]
  }
  #->
  # icingaweb2 package pulls in httpd which we don't want
  #service { 'httpd':
  #  ensure => stopped,
  #}

  if ('map' in $modules) {
    # TODO: generic layout
    $module = 'map'
    icingaweb2::module { "${module}":
      builtin => false,
      repo_url => "https://github.com/nbuchwitz/icingaweb2-module-${module}"
    }
    ->
    file { "/etc/icingaweb2/modules/${module}":
      ensure => directory,
      owner  => root,
      group  => icingaweb2,
      mode => '2770'
    }
    ->
    file { "/etc/icingaweb2/modules/${module}/config.ini":
      ensure => present,
      owner  => root,
      group  => icingaweb2,
      mode => '0660',
      content => template("profiles/icinga/icingaweb2/modules/${module}/config.ini.erb")
    }

  }

  if ('cube' in $modules) {
    icingaweb2::module { 'cube':
      builtin => false
    }
  }

  if ('globe' in $modules) {
    icingaweb2::module { 'globe':
      builtin => false,
      repo_url => 'https://github.com/Mikesch-mp/icingaweb2-module-globe'
    }
  }

  if ('businessprocess' in $modules) {
    icingaweb2::module { 'businessprocess':
      builtin => false
    }
    ->
    file { '/etc/icingaweb2/modules/businessprocess':
      ensure => directory,
      owner  => root,
      group  => icingaweb2,
      mode => '2770'
    }
    ->
    file { '/etc/icingaweb2/modules/businessprocess/processes':
      ensure => directory,
      owner  => root,
      group  => icingaweb2,
      mode => '2770'
    }
    ->
    file { '/etc/icingaweb2/modules/businessprocess/processes/all.conf':
      ensure => present,
      owner  => root,
      group  => icingaweb2,
      mode => '0660',
      content => template("profiles/icinga/icingaweb2/modules/businessprocess/processes/all.conf.erb")
    }
    ->
    file { '/etc/icingaweb2/modules/businessprocess/processes/web.conf':
      ensure => present,
      owner  => root,
      group  => icingaweb2,
      mode => '0660',
      content => template("profiles/icinga/icingaweb2/modules/businessprocess/processes/web.conf.erb")
    }
    ->
    file { '/etc/icingaweb2/modules/businessprocess/processes/mysql.conf':
      ensure => present,
      owner  => root,
      group  => icingaweb2,
      mode => '0660',
      content => template("profiles/icinga/icingaweb2/modules/businessprocess/processes/mysql.conf.erb")
    }
  }

  if ('grafana' in $modules) {
    $datasource = $modules['grafana']['datasource']
    $listen_ip = $modules['grafana']['listen_ip']
    $listen_port = $modules['grafana']['listen_port']

    icingaweb2::module { 'grafana':
      builtin => false,
      repo_url => 'https://github.com/Mikesch-mp/icingaweb2-module-grafana'
    }
    ->
    file { '/etc/icingaweb2/modules/grafana':
      ensure => directory,
      owner  => root,
      group  => icingaweb2,
      mode => '2770',
      require => Package['icingaweb2']
    }
    ->
    file { '/etc/icingaweb2/modules/grafana/config.ini':
      ensure => present,
      owner  => root,
      group  => icingaweb2,
      mode => '0660',
      content => template("profiles/icinga/icingaweb2/modules/grafana/config.ini.erb")
    }
    ->
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

  # TODO: configuration
  if ('elasticsearch' in $modules) {
    icingaweb2::module { 'elasticsearch':
      builtin => false,
      repo_revision => 'next',
    }
  }
}
