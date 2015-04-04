class iptables::clean {
  exec { 'iptables-clean':
    command  => '/bin/rm -f /root/iptables.d/allow_* /root/iptables.d/drop_*',
  }
}
