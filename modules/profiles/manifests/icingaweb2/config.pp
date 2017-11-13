class profiles::icingaweb2::config {

  include '::profiles::icinga2::install'
  include '::profiles::icingaweb2::install'

  # present icinga2 in icingaweb2's module documentation
  file { '/usr/share/icingaweb2/modules/icinga2':
    ensure => 'directory',
    require => Package['icingaweb2']
  }

  file { '/usr/share/icingaweb2/modules/icinga2/doc':
    ensure => 'link',
    target => '/usr/share/doc/icinga2/markdown',
    require => [ Package['icinga2'], Package['icingaweb2'], File['/usr/share/icingaweb2/modules/icinga2'] ],
  }

  file { '/etc/icingaweb2/enabledModules/icinga2':
    ensure => 'link',
    target => '/usr/share/icingaweb2/modules/icinga2',
    require => File['/etc/icingaweb2/enabledModules'],
  }
}
