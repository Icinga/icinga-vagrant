include ::icingaweb2

icingaweb2::config::groupbackend {'mysql-backend':
  backend  => 'db',
  resource => 'my-sql',
}

icingaweb2::config::groupbackend {'ldap-backend':
  backend                     => 'ldap',
  resource                    => 'my-ldap',
  ldap_group_class            => 'groupofnames',
  ldap_group_name_attribute   => 'cn',
  ldap_group_member_attribute => 'member',
  ldap_base_dn                => 'ou=groups,dc=icinga,dc=com'
}