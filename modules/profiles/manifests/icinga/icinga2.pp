class profiles::icinga::icinga2 {
  include icinga2 # TODO: Use official module with Puppet 5 support
  include monitoring_plugins # TODO: Refactor module

  include '::profiles::base::system'

  package { 'icinga2-ido-mysql':
    ensure => latest,
    require => Class['icinga_rpm'],
    alias => 'icinga2-ido-mysql'
  }

  # TODO: remove hardcoded names
  mysql::db { 'icinga':
    user      => 'icinga',
    password  => 'icinga',
    host      => 'localhost',
    charset   => 'latin1',
    collate   => 'latin1_general_ci',
    grant     => [ 'ALL' ]
  }

  exec { 'populate-icinga2-ido-mysql-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => "mysql -uicinga -picinga icinga -e \"SELECT * FROM icinga_dbversion;\" &> /dev/null",
    command => "mysql -uicinga -picinga icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql",
    user => 'root',
    environment => [ "HOME=/root" ],
    require => [ Mysql::Db['icinga'], Package['icinga2-ido-mysql'] ]
  }

  icinga2::feature { 'ido-mysql':
    require => Exec['populate-icinga2-ido-mysql-db']
  }

  package { 'vim-icinga2':
    ensure => 'latest',
    require => [ Class['icinga_rpm'], Class['vim'] ],
    alias => 'vim-icinga2'
  }

  @user { vagrant: ensure => present }
  User<| title == vagrant |>{
    groups +> ['icinga', 'icingacmd'],
    require => Package['icinga2']
  }

  # api
  exec { 'enable-icinga2-api':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => 'icinga2 api setup',
    require => Package['icinga2'],
    notify  => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/conf.d/api-users.conf':
    owner  => icinga,
    group  => icinga,
    content   => template("profiles/icinga/icinga2/api-users.conf.erb"),
    require   => [ Package['icinga2'], Exec['enable-icinga2-api'] ],
    notify    => Service['icinga2']
  }
}

