class pnp4nagios::install {
  $ensure = $pnp4nagios::params::ensure

  package { 'pnp4nagios':
    ensure => $ensure,
  }
}
