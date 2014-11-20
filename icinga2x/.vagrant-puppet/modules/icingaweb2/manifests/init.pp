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
  
  file { '/etc/icingaweb2':
    ensure => directory,
	owner => 'apache',
	group => 'apache',
	mode => 750
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
  exec { 'create-mysql-icingaweb-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless  => 'mysql -uicingaweb -picingaweb icingaweb',
    command => 'mysql -uroot -e "CREATE DATABASE icingaweb; GRANT ALL ON icingaweb.* TO icingaweb@localhost IDENTIFIED BY \'icingaweb\';"',
    require => Service['mysqld']
  }

  exec { 'populate-icingaweb-mysql-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless  => 'mysql -uicingaweb -picingaweb icingaweb -e "SELECT * FROM icingaweb_user;" &> /dev/null',
    command => 'mysql -uicingaweb -picingaweb icingaweb < /usr/share/doc/icingaweb2-$(rpm -q icingaweb2 | cut -d\'-\' -f2)/schema/mysql.schema.sql; mysql -uicingaweb -picingaweb icingaweb -e "INSERT INTO icingaweb_user (name, active, password_hash) VALUES (\'icingaadmin\', 1, \'\$1\$iQSrnmO9\$T3NVTu0zBkfuim4lWNRmH.\');"',
    require => [ Exec['create-mysql-icingaweb-db'], Package['icingaweb2'] ]
  }
}
