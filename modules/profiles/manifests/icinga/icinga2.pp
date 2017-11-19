class profiles::icinga::icinga2 {
  class { '::icinga2': } # TODO: Use official module with Puppet 5 support
  ->
  class { '::monitoring_plugins': } # TODO: Refactor module
  ->
  file { 'check_mysql_health':
    name => '/usr/lib64/nagios/plugins/check_mysql_health',
    owner => root,
    group => root,
    mode => '0755',
    content => template("profiles/icinga/check_mysql_health.erb")
  }

  package { 'icinga2-ido-mysql':
    ensure => latest,
    require => Class['icinga_rpm'],
    alias => 'icinga2-ido-mysql'
  }
  ->
  # TODO: remove hardcoded names
  mysql::db { 'icinga':
    user      => 'icinga',
    password  => 'icinga',
    host      => 'localhost',
    charset   => 'latin1',
    collate   => 'latin1_general_ci',
    grant     => [ 'ALL' ]
  }
  ->
  exec { 'populate-icinga2-ido-mysql-db':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => "mysql -uicinga -picinga icinga -e \"SELECT * FROM icinga_dbversion;\" &> /dev/null",
    command => "mysql -uicinga -picinga icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql",
    user => 'root',
    environment => [ "HOME=/root" ],
    require => [ Mysql::Db['icinga'], Package['icinga2-ido-mysql'] ]
  }
  ->
  icinga2::feature { 'ido-mysql':
    require => Exec['populate-icinga2-ido-mysql-db']
  }

  package { 'vim-icinga2':
    ensure => 'latest',
    require => [ Class['icinga_rpm'], Class['vim'] ],
    alias => 'vim-icinga2'
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
    owner  => root,
    group  => root,
    mode   => '0644',
    content   => template("profiles/icinga/icinga2/api-users.conf.erb"),
    notify    => Service['icinga2']
  }

  # TODO: Split demo based on parameters; standalone vs cluster
  file { '/etc/icinga2/icinga2.conf':
    ensure => present,
    owner  => icinga,
    group  => icinga,
    content => template("profiles/icinga/icinga2/config/icinga2_standalone.conf.erb"),
    require => Package['icinga2'],
    notify    => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/demo':
    ensure => directory,
    owner  => icinga,
    group  => icinga,
    notify    => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/demo/hosts.conf':
    ensure => present,
    owner  => icinga,
    group  => icinga,
    content => template("profiles/icinga/icinga2/config/demo/hosts.conf.erb"),
    notify    => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/demo/services.conf':
    ensure => present,
    owner  => icinga,
    group  => icinga,
    content => template("profiles/icinga/icinga2/config/demo/services.conf.erb"),
    notify    => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/demo/templates.conf':
    ensure => present,
    owner  => icinga,
    group  => icinga,
    content => template("profiles/icinga/icinga2/config/demo/templates.conf.erb"),
    notify    => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/demo/groups.conf':
    ensure => present,
    owner  => icinga,
    group  => icinga,
    content => template("profiles/icinga/icinga2/config/demo/groups.conf.erb"),
    notify    => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/demo/notifications.conf':
    ensure => present,
    owner  => icinga,
    group  => icinga,
    content => template("profiles/icinga/icinga2/config/demo/notifications.conf.erb"),
    notify    => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/demo/commands.conf':
    ensure => present,
    owner  => icinga,
    group  => icinga,
    content => template("profiles/icinga/icinga2/config/demo/commands.conf.erb"),
    notify    => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/demo/timeperiods.conf':
    ensure => present,
    owner  => icinga,
    group  => icinga,
    content => template("profiles/icinga/icinga2/config/demo/timeperiods.conf.erb"),
    notify    => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/demo/users.conf':
    ensure => present,
    owner  => icinga,
    group  => icinga,
    content => template("profiles/icinga/icinga2/config/demo/users.conf.erb"),
    notify    => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/demo/additional_services.conf':
    ensure => present,
    owner  => icinga,
    group  => icinga,
    content => template("profiles/icinga/icinga2/config/demo/additional_services.conf.erb"),
    notify    => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/demo/bp.conf':
    ensure => present,
    owner  => icinga,
    group  => icinga,
    content => template("profiles/icinga/icinga2/config/demo/bp.conf.erb"),
    notify    => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/demo/cube.conf':
    ensure => present,
    owner  => icinga,
    group  => icinga,
    content => template("profiles/icinga/icinga2/config/demo/cube.conf.erb"),
    notify    => Service['icinga2']
  }
  ->
  file { '/etc/icinga2/demo/maps.conf':
    ensure => present,
    owner  => icinga,
    group  => icinga,
    content => template("profiles/icinga/icinga2/config/demo/maps.conf.erb"),
    notify    => Service['icinga2']
  }


#  @user { vagrant: ensure => present }
#  User<| title == vagrant |>{
#    groups +> ['icinga', 'icingacmd'],
#    require => ['icinga2']
#  }

}

