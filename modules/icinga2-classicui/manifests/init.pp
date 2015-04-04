class icinga2-classicui {
  include icinga-rpm-snapshot
  include icinga2

  # workaround for package conflicts
  # icinga-gui pulls icinga-gui-config automatically
  package { 'icinga2-classicui-config':
    ensure => latest,
    before => Package["icinga-gui"],
    require => Class['icinga-rpm-snapshot'],
    notify => Class['Apache::Service']
  }

  package { 'icinga-gui':
    ensure => latest,
    alias => 'icinga-gui'
  }

  icinga2::feature { 'statusdata': }

  icinga2::feature { 'compatlog': }
}
