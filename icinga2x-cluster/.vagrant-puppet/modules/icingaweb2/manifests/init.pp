class icingaweb2 {
  package { 'icingaweb2':
    ensure => latest,
    require => [ Class['icinga-rpm-snapshot'], Class['epel'], Package['php-ZendFramework'], Package['php-ZendFramework-Db-Adapter-Pdo-Mysql'] ],
    alias => 'icinga2web',
    notify    => Service['apache']
  }

  package { 'php-Icinga':
    ensure => latest,
    require => [ Class['icinga-rpm-snapshot'], Class['epel'], Package['php-ZendFramework'], Package['php-ZendFramework-Db-Adapter-Pdo-Mysql'] ],
    alias => 'php-Icinga'
  }

  package { 'icingacli':
    ensure => latest,
    require => [ Class['icinga-rpm-snapshot'], Class['epel'], Package['php-ZendFramework'], Package['php-ZendFramework-Db-Adapter-Pdo-Mysql'] ],
    alias => 'icingacli'
  }

  package { ['php-ZendFramework', 'php-ZendFramework-Db-Adapter-Pdo-Mysql']:
    ensure => latest
  }
}

class icingaweb2-internal-db-mysql {
  exec { 'create-mysql-icingaweb-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless  => 'mysql -uicingaweb -picingaweb icingaweb',
    command => 'mysql -uroot -e "CREATE DATABASE icingaweb; GRANT ALL ON icingaweb.* TO icingaweb@localhost IDENTIFIED BY \'icingaweb\';"',
    require => Service['mysqld']
  }

  exec { 'populate-icingaweb-mysql-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless  => 'mysql -uicingaweb -picingaweb icingaweb -e "SELECT * FROM icingaweb_user;" &> /dev/null',
    command => 'mysql -uicingaweb -picingaweb icingaweb < /usr/share/doc/icingaweb2-$(rpm -q icingaweb2 | cut -d\'-\' -f2)/schema/mysql.schema.sql',
    require => [ Exec['create-mysql-icingaweb-db'], Package['icingaweb2'] ]
  }

  exec { 'populate-icingaweb-mysql-db-create-default-account':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => 'mysql -uicingaweb -picingaweb icingaweb -e "select * from icingaweb_user where name=\'icingaadmin\';"',
    command => 'mysql -uicingaweb -picingaweb icingaweb -e "INSERT INTO icingaweb_user (name, active, password_hash) VALUES (\'icingaadmin\', 1, \'\$1\$iQSrnmO9\$T3NVTu0zBkfuim4lWNRmH.\');"',
    require => [ Exec['populate-icingaweb-mysql-db'], Package['icingaweb2'] ]
  }
}
