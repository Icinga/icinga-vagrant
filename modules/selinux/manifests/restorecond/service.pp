# manages restorecond service
class selinux::restorecond::service {

  service{'restorecond':
    ensure => running,
    enable => true,
  }
}
