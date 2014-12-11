#
# Class selinux::restorecond::install
#
class selinux::restorecond::install {
  package {
    'policycoreutils':
      ensure => present;
  }
}
