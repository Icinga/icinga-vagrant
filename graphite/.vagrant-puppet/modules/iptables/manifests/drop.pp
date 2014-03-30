define iptables::drop (
  $port     = undef,
  $protocol = undef
) {
  include iptables
  $filename = "/root/iptables.d/drop_${port}_${protocol}"
  if ! defined(File[$filename]) {
    file { $filename:
      ensure  => file,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0600',
      require => Class['iptables::config'],
      notify  => Class['iptables::update'],
    }
  }
}
