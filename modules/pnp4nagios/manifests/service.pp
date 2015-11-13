class pnp4nagios::service {
  $ensure = $pnp4nagios::params::ensure ? { present => true, absent => false }

  file { '/etc/systemd/system/npcd.service':
    owner => 'root',
    group => 'root',
    mode => '0755',
    content => template("pnp4nagios/npcd.service")
  } ->
  # hardcode systemd usage for now, TODO
  service { 'npcd':
    name => 'npcd',
    provider => 'systemd',
    ensure => $ensure,
    enable => $ensure,
    hasstatus => true,
    hasrestart => true,
  }
}
