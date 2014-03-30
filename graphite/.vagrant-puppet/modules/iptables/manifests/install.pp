class iptables::install {
  if ! defined(Package['iptables']) {
    package { 'iptables':
      ensure => installed,
    }
  }
}
