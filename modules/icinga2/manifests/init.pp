class icinga2 (
) inherits icinga2::params {
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

  file { '/var/spool/icinga2/perfdata':
    ensure => directory,
    owner => 'icinga',
    group => 'icinga',
    mode => '0775',
    require => Package['icinga2-common']
  }

  icinga2::feature { 'livestatus': }
}

class icinga2_ido_mysql (
  $ido_db_user = $::icinga2_ido_mysql::ido_db_user,
  $ido_db_pass = $::icinga2_ido_mysql::ido_db_pass,
  $ido_db_name = $::icinga2_ido_mysql::ido_db_name,
  $ido_db_schema = $::icinga2_ido_mysql::ido_db_schema,
) inherits icinga2_ido_mysql::params {

  validate_string($ido_db_user)
  validate_string($ido_db_pass)
  validate_string($ido_db_name)
  validate_string($ido_db_schema)

  package { 'icinga2-ido-mysql':
    ensure => latest,
    require => Class['icinga_rpm'],
    alias => 'icinga2-ido-mysql'
  }

  exec { 'create-mysql-icinga2-ido-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => "mysql -u$ido_db_user -p$ido_db_pass $ido_db_name",
    command => "mysql -uroot -e \"CREATE DATABASE $ido_db_name ; GRANT ALL ON $ido_db_name.* TO $ido_db_user@localhost IDENTIFIED BY \'$ido_db_pass\';\"",
    require => Class['mysql::server']
  }

  exec { 'populate-icinga2-ido-mysql-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => "mysql -u$ido_db_user -p$ido_db_pass $ido_db_name -e \"SELECT * FROM icinga_dbversion;\" &> /dev/null",
    command => "mysql -u$ido_db_user -p$ido_db_pass $ido_db_name < $ido_db_schema",
    require => [ Package['icinga2-ido-mysql'], Exec['create-mysql-icinga2-ido-db'] ]
  }

  icinga2::feature { 'ido-mysql':
    require => Exec['populate-icinga2-ido-mysql-db']
  }
}

class icinga2_ido_pgsql (
  $ido_db_user = $::icinga2_ido_pgsql::ido_db_user,
  $ido_db_pass = $::icinga2_ido_pgsql::ido_db_pass,
  $ido_db_name = $::icinga2_ido_pgsql::ido_db_name,
  $ido_db_schema = $::icinga2_ido_pgsql::ido_db_schema,
) inherits icinga2_ido_pgsql::params {

  validate_string($ido_db_user)
  validate_string($ido_db_pass)
  validate_string($ido_db_name)
  validate_string($ido_db_schema)

  package { 'icinga2-ido-pgsql':
    ensure => latest,
    require => Class['icinga_rpm'],
    alias => 'icinga2-ido-pgsql'
  }

  exec { 'create-pgsql-icinga2-ido-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => "sudo -u postgres psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname=\'icinga\'\" | grep -q 1",
    command => "sudo -u postgres psql -c \"CREATE ROLE $ido_db_user WITH LOGIN PASSWORD \'$ido_db_pass\';\" && \
                sudo -u postgres createdb -O $ido_db_name -E UTF8 $ido_db_name && \
                sudo -u postgres createlang plpgsql $ido_db_name",
    require => Service['postgresql']
  }

  exec { 'populate-icinga2-ido-pgsql-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    environment => ["PGPASSWORD=$ido_db_pass"],
    unless => "psql -U $ido_db_user -d $ido_db_name -c \"SELECT * FROM icinga_dbversion;\" &> /dev/null",
    command => "psql -U $ido_db_user -d $ido_db_name < $ido_db_schema",
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
