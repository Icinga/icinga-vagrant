class profiles::icinga2::install {
  include icinga2 # TODO: Use official module with Puppet 5 support
  include icinga2_ido_mysql # TODO: Refactor module
  include monitoring_plugins # TODO: Refactor module

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
    content   => template("profiles/api-users.conf.erb"),
    require   => [ Package['icinga2'], Exec['enable-icinga2-api'] ],
    notify    => Service['icinga2']
  }
}

