class iptables::update {
  exec { 'update-iptables':
    command     => '/root/iptables.d/update',
    notify      => Class['iptables::service'],
    refreshonly => true,
  }
}
