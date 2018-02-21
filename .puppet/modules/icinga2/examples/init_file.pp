include icinga2

file { '/etc/icinga2/conf.d/test.conf':
  ensure => file,
  tag    => 'icinga2::config::file',
}
