include ::icingaweb2

icingaweb2::config::authmethod {'external-auth':
  backend => 'external',
  order   => '01',
}

icingaweb2::config::resource{'my-sql':
  type        => 'db',
  db_type     => 'mysql',
  host        => 'localhost',
  port        => 3306,
  db_name     => 'icingaweb2',
  db_username => 'root',
  db_password => 'supersecret',
}

icingaweb2::config::authmethod {'db-auth':
  backend  => 'db',
  resource => 'my-sql',
  order    => '02',
}