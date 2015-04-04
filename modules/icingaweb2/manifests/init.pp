class icingaweb2 (
  $config_dir = $::icingaweb2::config_dir
) inherits icingaweb2::params {

  validate_string($config_dir)

  package { 'icingaweb2':
    ensure => latest,
    require => [ Package['httpd'], Class['icinga_rpm'], Class['epel'], Package['php-ZendFramework'], Package['php-ZendFramework-Db-Adapter-Pdo-Mysql'] ],
    alias => 'icingaweb2',
    notify => Class['Apache::Service']
  }

  package { 'php-Icinga':
    ensure => latest,
    require => [ Class['icinga_rpm'], Class['epel'], Package['php-ZendFramework'], Package['php-ZendFramework-Db-Adapter-Pdo-Mysql'] ],
    alias => 'php-Icinga'
  }

  package { 'icingacli':
    ensure => latest,
    require => [ Class['icinga_rpm'], Class['epel'], Package['php-ZendFramework'], Package['php-ZendFramework-Db-Adapter-Pdo-Mysql'] ],
    alias => 'icingacli'
  }

  package { ['php-ZendFramework', 'php-ZendFramework-Db-Adapter-Pdo-Mysql']:
    ensure => latest,
    require => Class['icinga_rpm']
  }

  file {
    $::icingaweb2::config_dir:
      ensure => directory,
      require => Class['apache'];

    "$::icingaweb2::config_dir/authentication.ini":
      content => template("icingaweb2/authentication.ini.erb");

    "$::icingaweb2::config_dir/config.ini":
      content => template("icingaweb2/config.ini.erb");

    "$::icingaweb2::config_dir/roles.ini":
      content => template("icingaweb2/roles.ini.erb");

    "$::icingaweb2::config_dir/resources.ini":
      content => template("icingaweb2/resources.ini.erb");

    "$::icingaweb2::config_dir/modules":
      ensure => directory;

    "$::icingaweb2::config_dir/enabledModules":
      ensure => directory;
  }

  file {
    "$::icingaweb2::config_dir/modules/monitoring":
      ensure => directory,
      require => File["$::icingaweb2::config_dir/modules"];
  }

  file {
    "$::icingaweb2::config_dir/modules/monitoring/backends.ini":
      content => template("icingaweb2/modules/monitoring/backends.ini.erb"),
      require => File["$::icingaweb2::config_dir/modules/monitoring"];

    "$::icingaweb2::config_dir/modules/monitoring/config.ini":
      content => template("icingaweb2/modules/monitoring/config.ini.erb"),
      require => File["$::icingaweb2::config_dir/modules/monitoring"];

    "$::icingaweb2::config_dir/modules/monitoring/instances.ini":
      content => template("icingaweb2/modules/monitoring/instances.ini.erb"),
      require => File["$::icingaweb2::config_dir/modules/monitoring"];
  }

  file {
    "$::icingaweb2::config_dir/enabledModules/monitoring":
      ensure => 'link',
      target => '/usr/share/icingaweb2/modules/monitoring',
      require => File["$::icingaweb2::config_dir/enabledModules"];

    "$::icingaweb2::config_dir/enabledModules/doc":
      ensure => 'link',
      target => '/usr/share/icingaweb2/modules/doc',
      require => File["$::icingaweb2::config_dir/enabledModules"];
  }
}

class icingaweb2-internal-db-mysql {
  exec { 'create-mysql-icingaweb2-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless  => 'mysql -uicingaweb2 -picingaweb2 icingaweb2',
    command => 'mysql -uroot -e "CREATE DATABASE icingaweb2; GRANT ALL ON icingaweb2.* TO icingaweb2@localhost IDENTIFIED BY \'icingaweb2\';"',
    require => Service['mariadb']
  }

  exec { 'populate-icingaweb2-mysql-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless  => 'mysql -uicingaweb2 -picingaweb2 icingaweb2 -e "SELECT * FROM icingaweb_user;" &> /dev/null',
    command => 'mysql -uicingaweb2 -picingaweb2 icingaweb2 < /usr/share/doc/icingaweb2/schema/mysql.schema.sql; mysql -uicingaweb2 -picingaweb2 icingaweb2 -e "INSERT INTO icingaweb_user (name, active, password_hash) VALUES (\'icingaadmin\', 1, \'\$1\$iQSrnmO9\$T3NVTu0zBkfuim4lWNRmH.\');"',
    require => [ Exec['create-mysql-icingaweb2-db'], Package['icingaweb2'] ]
  }
}
