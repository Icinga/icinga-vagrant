# Here is an example nginx resource for use with Slashbunny-phpfpm and the
# voxpupuli-nginx module to get icingaweb2 running behind nginx.
#

$vhost = 'puppet-icingaweb2'

include ::nginx

nginx::resource::server { 'icingaweb2':
  server_name          => [$vhost],
  ssl                  => true,
  ssl_cert             => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  ssl_key              => '/etc/ssl/private/ssl-cert-snakeoil.key',
  ssl_redirect         => true,
  index_files          => [],
  use_default_location => false,
}

nginx::resource::location { 'root':
  location            => '/',
  server              => 'icingaweb2',
  index_files         => [],
  location_cfg_append => {
    rewrite => '^/(.*) https://$host/icingaweb2/$1 permanent'
  }
}

nginx::resource::location { 'icingaweb2_index':
  location       => '~ ^/icingaweb2/index\.php(.*)$',
  server         => 'icingaweb2',
  ssl            => true,
  ssl_only       => true,
  index_files    => [],
  fastcgi        => '127.0.0.1:9000',
  fastcgi_index  => 'index.php',
  fastcgi_script => '/usr/share/icingaweb2/public/index.php',
  fastcgi_param  => {
    'ICINGAWEB_CONFIGDIR' => '/etc/icingaweb2',
    'REMOTE_USER'         => '$remote_user',
  },
}

nginx::resource::location { 'icingaweb':
  location       => '~ ^/icingaweb2(.+)?',
  location_alias => '/usr/share/icingaweb2/public',
  try_files      => ['$1', '$uri', '$uri/', '/icingaweb2/index.php$is_args$args'],
  index_files    => ['index.php'],
  server         => 'icingaweb2',
  ssl            => true,
  ssl_only       => true,
}

include ::phpfpm

phpfpm::pool { 'main': }

include ::mysql::server

mysql::db { 'icingaweb2':
  user     => 'icingaweb2',
  password => 'icingaweb2',
  host     => 'localhost',
  grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER', 'REFERENCES'],
}

class {'icingaweb2':
  manage_repo   => true,
  import_schema => true,
  db_type       => 'mysql',
  db_host       => 'localhost',
  db_port       => 3306,
  db_username   => 'icingaweb2',
  db_password   => 'icingaweb2',
  conf_user     => 'nginx',
  require       => Mysql::Db['icingaweb2'],
}

class {'icingaweb2::module::monitoring':
  ido_host          => 'localhost',
  ido_db_name       => 'icinga2',
  ido_db_username   => 'icinga2',
  ido_db_password   => 'supersecret',
  commandtransports => {
    icinga2 => {
      transport => 'api',
      username  => 'root',
      password  => 'icinga',
    }
  }
}
