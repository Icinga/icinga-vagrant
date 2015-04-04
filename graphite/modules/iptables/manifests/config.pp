class iptables::config {
  # defaults
  File {
    owner => 'root',
    group => 'root',
    mode  => '0600',
  }
  file { '/root/iptables.d':
    ensure => directory,
    mode   => '0700',
  }
  file { '/root/iptables.d/update':
    ensure  => present,
    mode    => '0700',
    content => template('iptables/update.erb'),
    notify  => Class['iptables::update'],
    require => File['/root/iptables.d'],
  }
}
