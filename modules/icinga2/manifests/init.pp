class icinga2 {
  package { 'icinga2':
    ensure => latest,
    require => Class['icinga_rpm'],
    alias => 'icinga2'
  }

  package { 'icinga2-bin':
    ensure => latest,
    require => Class['icinga_rpm'],
    alias => 'icinga2-bin'
  }

  package { 'icinga2-common':
    ensure => latest,
    require => Class['icinga_rpm'],
    alias => 'icinga2-common'
  }

  package { 'icinga2-doc':
    ensure => latest,
    require => Class['icinga_rpm'],
    alias => 'icinga2-doc'
  }

  package { 'icinga2-debuginfo':
    ensure => latest,
    require => Class['icinga_rpm'],
    alias => 'icinga2-debuginfo'
  }

  service { 'icinga2':
    enable => true,
    ensure => running,
    hasrestart => true,
    alias => 'icinga2',
    require => Package['icinga2']
  }

  file { "/etc/icinga2/features-enabled/*":
    notify => Service['icinga2']
  }

  icinga2::feature { 'livestatus': }
}

class icinga2-ido-mysql {
  include icinga_rpm

  package { 'icinga2-ido-mysql':
    ensure => latest,
    require => Class['icinga_rpm'],
    alias => 'icinga2-ido-mysql'
  }

  exec { 'create-mysql-icinga2-ido-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => 'mysql -uicinga -picinga icinga',
    command => 'mysql -uroot -e "CREATE DATABASE icinga; GRANT ALL ON icinga.* TO icinga@localhost IDENTIFIED BY \'icinga\';"',
    require => Class['mysql::server']
  }

  exec { 'populate-icinga2-ido-mysql-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => 'mysql -uicinga -picinga icinga -e "SELECT * FROM icinga_dbversion;" &> /dev/null',
    command => 'mysql -uicinga -picinga icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql',
    require => [ Package['icinga2-ido-mysql'], Exec['create-mysql-icinga2-ido-db'] ]
  }

  icinga2::feature { 'ido-mysql':
    require => Exec['populate-icinga2-ido-mysql-db']
  }
}

class icinga2-ido-pgsql {
  include icinga_rpm
  include pgsql

  package { 'icinga2-ido-pgsql':
    ensure => latest,
    require => Class['icinga_rpm'],
    alias => 'icinga2-ido-pgsql'
  }

  exec { 'create-pgsql-icinga2-ido-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => 'sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname=\'icinga\'" | grep -q 1',
    command => 'sudo -u postgres psql -c "CREATE ROLE icinga WITH LOGIN PASSWORD \'icinga\';" && \
                sudo -u postgres createdb -O icinga -E UTF8 icinga && \
                sudo -u postgres createlang plpgsql icinga',
    require => Service['postgresql']
  }

  exec { 'populate-icinga2-ido-pgsql-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    environment => ['PGPASSWORD=icinga'],
    unless => 'psql -U icinga -d icinga -c "SELECT * FROM icinga_dbversion;" &> /dev/null',
    command => 'psql -U icinga -d icinga < /usr/share/icinga2-ido-pgsql/schema/pgsql.sql',
    require => [ Package['icinga2-ido-pgsql'], Exec['create-pgsql-icinga2-ido-db'] ]
  }

  icinga2::feature { 'ido-pgsql':
    require => Exec['populate-icinga2-ido-pgsql-db']
  }
}

define icinga2::feature ($feature = $title) {
  exec { "icinga2-feature-${feature}":
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => "readlink /etc/icinga2/features-enabled/${feature}.conf",
    command => "icinga2 feature enable ${feature}",
    require => [ Package['icinga2'] ],
    notify => Service['icinga2']
  }
}
