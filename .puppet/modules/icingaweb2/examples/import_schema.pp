include ::mysql::server

mysql::db { 'icingaweb2':
  user     => 'icingaweb2',
  password => 'icingaweb2',
  host     => 'localhost',
  grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER', 'REFERENCES'],
}

include ::postgresql::server

postgresql::server::db { 'icingaweb2':
  user     => 'icingaweb2',
  password => postgresql_password('icingaweb2', 'icingaweb2'),
}

class {'icingaweb2':
  manage_repo   => true,
  import_schema => true,
  db_type       => 'pgsql',
  db_host       => 'localhost',
  db_port       => 5432,
  db_username   => 'icingaweb2',
  db_password   => 'icingaweb2',
  require       => [ Postgresql::Server::Db['icingaweb2'], Mysql::Db['icingaweb2'] ]
}