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
