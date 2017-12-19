include ::mysql::server

mysql::db { 'icinga2':
  user     => 'icinga2',
  password => 'supersecret',
  host     => '127.0.0.1',
  grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER'],
}

class { '::icinga2':
  manage_repo => true,
}

class{ '::icinga2::feature::idomysql':
  user          => 'icinga2',
  password      => 'supersecret',
  database      => 'icinga2',
  import_schema => true,
  require       => Mysql::Db['icinga2'],
}

