node default  {
  package { 'curl': }

  case $::kernel {
    'linux': {
      $manage_repo = true
      $target_dir = '/etc/icinga2/conf.d'
    } # linux

    'windows': {
      $manage_repo = false
      $target_dir = 'C:/ProgramData/icinga2/etc/icinga2/conf.d'
    } # windows

   'FreeBSD': {
      $manage_repo = false
      $target_dir = '/usr/local/etc/icinga2/conf.d'
    } # FreeBSD
  }

  class { '::icinga2':
    manage_repo => $manage_repo,
  }

  icinga2::object::apiuser { 'icinga':
    target      => "${target_dir}/apiuser.conf",
    password    => 'icinga',
    permissions => [ "*" ],
  }

  class { '::icinga2::pki::ca': }

  class { '::icinga2::feature::api':
    pki => 'none',
  }

  include ::mysql::server

  mysql::db { 'icinga2':
    user     => 'icinga2',
    password => 'supersecret',
    host     => 'localhost',
    grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER'],
  }

  -> class{ '::icinga2::feature::idomysql':
    user          => 'icinga2',
    password      => 'supersecret',
    database      => 'icinga2',
    import_schema => true,
    require       => Mysql::Db['icinga2'],
  }
}
