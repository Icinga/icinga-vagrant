class { 'icinga2':
  manage_repo => true,
  confd       => '/etc/icinga/local.d',
}

file { '/etc/icinga2/local.d':
  ensure => directory,
  tag    => 'icinga2::config::file',
}
