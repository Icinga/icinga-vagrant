package { 'git': }

include ::mysql::server

mysql::db { 'director':
  user     => 'director',
  password => 'director',
  host     => 'localhost',
  charset  => 'utf8',
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

class {'icingaweb2::module::director':
  git_revision  => 'v1.3.2',
  db_host       => 'localhost',
  db_name       => 'director',
  db_username   => 'director',
  db_password   => 'director',
  import_schema => true,
  kickstart     => true,
  endpoint      => 'puppet-icingaweb2.localdomain',
  api_username  => 'root',
  api_password  => 'icinga',
  require       => Mysql::Db['director']
}