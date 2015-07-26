class icinga_web {
  php::module { ['php-mysql']:
    require => [ Class['mysql::server'] ]
  }

  php::module { ['php-pgsql']:
    require => [ Class['postgresql::server'] ]
  }

  package { 'icinga-web':
    ensure => latest,
    require => Class['icinga_rpm'],
    notify => Class['Apache::Service']
  }

  package { 'icinga-web-mysql':
    ensure => latest,
    require => Class['icinga_rpm'],
    notify => Class['Apache::Service']
  }

  exec { 'create-mysql-icinga-web-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => 'mysql -uicinga_web -picinga_web icinga_web',
    command => 'mysql -uroot -e "CREATE DATABASE icinga_web; GRANT ALL ON icinga_web.* TO icinga_web@localhost IDENTIFIED BY \'icinga_web\';"',
    require => [ Class['mysql::server'] ]
  }

  exec { 'populate-icinga-web-mysql-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => 'mysql -uicinga_web -picinga_web icinga_web -e "SELECT * FROM nsm_user;" &> /dev/null',
    command => 'mysql -uicinga_web -picinga_web icinga_web < /usr/share/icinga-web/etc/schema/mysql.sql',
    require => [ Package['icinga-web'], Exec['create-mysql-icinga-web-db'] ]
  }
}
