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

  exec { 'populate-icingaweb-mysql-db-accounts':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless  => 'mysql -uicingaweb -picingaweb icingaweb -e "SELECT * FROM account;" &> /dev/null',
    command => 'mysql -uicingaweb -picingaweb icingaweb < /usr/share/doc/icingaweb2-$(rpm -q icingaweb2 | cut -d\'-\' -f2)/schema/accounts.mysql.sql',
    require => [ Exec['create-mysql-icingaweb-db'], Package['icingaweb2'] ]
  }

  exec { 'populate-icingaweb-mysql-db-preferences':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless  => 'mysql -uicingaweb -picingaweb icingaweb -e "SELECT * FROM preference;" &> /dev/null',
    command => 'mysql -uicingaweb -picingaweb icingaweb < /usr/share/doc/icingaweb2-$(rpm -q icingaweb2 | cut -d\'-\' -f2)/schema/preferences.mysql.sql',
    require => [ Exec['create-mysql-icingaweb-db'], Package['icingaweb2'] ]
  }

}
