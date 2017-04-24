#
# Class selinux::restorecond::config
#
class selinux::restorecond::config {

  concat { $selinux::restorecond::config_file:
    ensure => present,
    mode   => $selinux::restorecond::config_file_mode,
    owner  => $selinux::restorecond::config_file_owner,
    group  => $selinux::restorecond::config_file_group,
    notify => Service['restorecond'],
  }

  concat::fragment {'restorecond_config_default':
    target => $selinux::restorecond::config_file,
    source => 'puppet:///modules/selinux/restorecond.conf',
    order  => '01',
  }
}
