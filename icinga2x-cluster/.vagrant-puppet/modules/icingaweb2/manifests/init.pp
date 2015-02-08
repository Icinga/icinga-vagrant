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
    ensure => latest,
    require => Class['icinga-rpm-snapshot']
  }
  
  file { '/etc/icingaweb2':
    ensure => directory,
    owner => 'apache',
    group => 'apache',
    mode => 750,
    require => Package['apache']
  }
  
  file { '/etc/icingaweb2/authentication.ini':
    source => 'puppet:////vagrant/.vagrant-puppet/files/etc/icingaweb2/authentication.ini',
	require => File['/etc/icingaweb2'],
  }

  file { '/etc/icingaweb2/config.ini':
    source => 'puppet:////vagrant/.vagrant-puppet/files/etc/icingaweb2/config.ini',
	require => File['/etc/icingaweb2'],
  }

  file { '/etc/icingaweb2/permissions.ini':
    source => 'puppet:////vagrant/.vagrant-puppet/files/etc/icingaweb2/permissions.ini',
	require => File['/etc/icingaweb2'],
  }
  
  file { '/etc/icingaweb2/resources.ini':
    source => 'puppet:////vagrant/.vagrant-puppet/files/etc/icingaweb2/resources.ini',
	require => File['/etc/icingaweb2'],
  }

  file { '/etc/icingaweb2/modules':
    ensure => directory,
	owner => 'apache',
	group => 'apache',
	mode => 750,
	require => File['/etc/icingaweb2'],
  }
  
  file { '/etc/icingaweb2/enabledModules':
    ensure => directory,
	owner => 'apache',
	group => 'apache',
	mode => 750,
	require => File['/etc/icingaweb2'],
  }
  
  file { '/etc/icingaweb2/enabledModules/monitoring':
    ensure => 'link',
    target => '/usr/share/icingaweb2/modules/monitoring',
    require => File['/etc/icingaweb2/enabledModules'],
  }

  file { '/etc/icingaweb2/enabledModules/doc':
    ensure => 'link',
    target => '/usr/share/icingaweb2/modules/doc',
    require => File['/etc/icingaweb2/enabledModules'],
  }
  
  file { '/etc/icingaweb2/modules/monitoring':
    ensure => directory,
	owner => 'apache',
	group => 'apache',
	mode => 750,
	require => File['/etc/icingaweb2/modules'],
  }

  file { '/etc/icingaweb2/modules/monitoring/backends.ini':
    source => 'puppet:////vagrant/.vagrant-puppet/files/etc/icingaweb2/modules/monitoring/backends.ini',
	require => File['/etc/icingaweb2/modules/monitoring'],
  }
  
  file { '/etc/icingaweb2/modules/monitoring/config.ini':
    source => 'puppet:////vagrant/.vagrant-puppet/files/etc/icingaweb2/modules/monitoring/config.ini',
	require => File['/etc/icingaweb2/modules/monitoring'],
  }
  
  file { '/etc/icingaweb2/modules/monitoring/instances.ini':
    source => 'puppet:////vagrant/.vagrant-puppet/files/etc/icingaweb2/modules/monitoring/instances.ini',
	require => File['/etc/icingaweb2/modules/monitoring'],
  }
}

class icingaweb2-internal-db-mysql {
  exec { 'create-mysql-icingaweb2-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless  => 'mysql -uicingaweb2 -picingaweb2 icingaweb2',
    command => 'mysql -uroot -e "CREATE DATABASE icingaweb2; GRANT ALL ON icingaweb2.* TO icingaweb2@localhost IDENTIFIED BY \'icingaweb2\';"',
    require => Service['mysqld']
  }

  exec { 'populate-icingaweb2-mysql-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless  => 'mysql -uicingaweb2 -picingaweb2 icingaweb2 -e "SELECT * FROM icingaweb_user;" &> /dev/null',
    command => 'mysql -uicingaweb2 -picingaweb2 icingaweb2 < /usr/share/doc/icingaweb2/schema/mysql.schema.sql; mysql -uicingaweb2 -picingaweb2 icingaweb2 -e "INSERT INTO icingaweb_user (name, active, password_hash) VALUES (\'icingaadmin\', 1, \'\$1\$iQSrnmO9\$T3NVTu0zBkfuim4lWNRmH.\');"',
    require => [ Exec['create-mysql-icingaweb2-db'], Package['icingaweb2'] ]
  }
}
