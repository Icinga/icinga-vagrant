class { 'icingaweb2':
  manage_repo => true,
}

icingaweb2::config::resource{'my-sql':
  type        => 'db',
  db_type     => 'mysql',
  host        => 'localhost',
  port        => '3306',
  db_name     => 'icingaweb2',
  db_username => 'root',
  db_password => 'supersecret',
}

icingaweb2::config::resource{'my-ldap':
  type         => 'ldap',
  host         => 'localhost',
  port         => 389,
  ldap_root_dn => 'dc=users,dc=icinga,dc=com',
  ldap_bind_dn => 'cn=root,dc=users,dc=icinga,dc=com',
  ldap_bind_pw => 'supersecret',
}