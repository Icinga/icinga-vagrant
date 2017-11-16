class profiles::icinga::icingaweb2 (
  $icingaweb2_listen_ip = '192.168.33.5',
  $icingaweb2_fqdn = 'icingaweb2.vagrant-demo.icinga.com'
) {

  include '::profiles::nginx::base'
 
  nginx::resource::server { $icingaweb2_fqdn:
    ensure              => present,
    www_root            => '/usr/share/icingaweb2/public',
    location_cfg_append => {
      'rewrite'             => '^/$ /icingaweb2 redirect'
    }
  }
  nginx::resource::location { "${icingaweb2_fqdn}-fastcgi":
    ensure              => present,
    server              => $icingaweb2_fqdn,
    location            => '~ ^/icingaweb2/index\.php(.*)$',
    fastcgi_index       => 'index.php',
    fastcgi_split_path  => '^(.+\.php)(/.+)$',
    fastcgi             => "127.0.0.1:9000",
    fastcgi_param       => {
      'SCRIPT_FILENAME'     => '/usr/share/icingaweb2/public/index.php',
      'ICINGAWEB_CONFIGDIR' => '/etc/icingaweb2',
      'REMOTE_USER'         => '$remote_user'
    }
  }
  nginx::resource::location { "${icingaweb2_fqdn}-public":
    ensure              => present,
    server              => $icingaweb2_fqdn,
    www_root            => '/usr/share/icingaweb2/public',
    location            => '~ ^/icingaweb2(.+)?',
    index_files         => [ 'index.php' ],
    location_cfg_append => {
      'try_files'           => '$1 $uri $uri/ /icingaweb2/index.php$is_args$args'
    }
  }
  # Avoid favicon.ico not found error messages
  # https://nichteinschalten.de/de/icingaweb2-unter-nginx-betreiben/
  nginx::resource::location { "${icingaweb2_fqdn}-favicon":
    ensure              => present,
    server              => $icingaweb2_fqdn,
    www_root            => '/usr/share/icingaweb2/public',
    location            => '/favicon.ico',
    location_cfg_append => {
      'log_not_found' => 'off',
      'access_log'    => 'off',
      'expires'       => 'max'
    }
  }


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
      'PHP/memory_limit'    => '271M',
      'Date/date.timezone' => 'Europe/Berlin',
    },
    extensions => {
      pdo => {},
      mysqlnd => {},
      imagick => {
        provider => pecl,
      }
    },
    require => Class['nginx']
  }


  class { '::icingaweb2': # TODO: Replace with official module with Puppet 5 support
    require => [ Class['nginx'], Class['::php'] ]
  }
  ->
  class { '::icingaweb2_internal_db_mysql': # TODO: Move this into a specific profile

  }
}
