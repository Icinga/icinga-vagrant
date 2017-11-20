class profiles::icinga::director {

  include '::profiles::base::mysql'
  include '::profiles::icinga::icingaweb2'

  mysql::db { 'director':
    user     => 'director',
    password => 'director',
    host     => 'localhost',
    grant    => [ 'ALL' ]
  }

  icingaweb2::module { 'director':
    builtin => false
  }

  -> exec { 'fix-binary-blog-bug-zend-655':
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => 'sed -i \'s/$value = addcslashes/\/\/$value = addcslashes/\' /usr/share/php/Zend/Db/Adapter/Pdo/Abstract.php'
  }
  # ship box specific director module config
  -> file {'/etc/icingaweb2/modules/director':
    ensure  => directory,
    owner   => root,
    group   => icingaweb2,
    mode    => '2770',
    require => Class['::profiles::icinga::icingaweb2']
  }

  -> file { '/etc/icingaweb2/modules/director/config.ini':
    ensure  => file,
    owner   => root,
    group   => icingaweb2,
    mode    => '2770',
    source  => '/vagrant/files/etc/icingaweb2/modules/director/config.ini', #TODO use hiera and templates
    require => File['/etc/icingaweb2/modules/director']
  }

  -> exec { 'Icinga Director DB migration':
    path    => '/usr/local/bin:/usr/bin:/bin',
    command => 'icingacli director migration run',
    onlyif  => 'icingacli director migration pending',
    require => [ Mysql::Db['director'], Package['icingacli'] ]
  }

  -> file { '/etc/icingaweb2/modules/director/kickstart.ini':
    ensure  => file,
    owner   => root,
    group   => icingaweb2,
    mode    => '2770',
    source  => '/vagrant/files/etc/icingaweb2/modules/director/kickstart.ini', #TODO use hiera and templates
    require => File['/etc/icingaweb2/modules/director']
  }

  -> exec { 'Icinga Director Kickstart':
    path    => '/usr/local/bin:/usr/bin:/bin',
    command => 'icingacli director kickstart run',
    onlyif  => 'icingacli director kickstart required',
    require => [ Service['icinga2'], Exec['enable-icinga2-api'] ]
  }
