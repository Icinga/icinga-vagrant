class {'::selinux::restorecond':}

selinux::restorecond::fragment{'test':
  content => "/etc/does_not_exist\n",
}
