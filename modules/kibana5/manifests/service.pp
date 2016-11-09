# == Class: kibana5::service
#
# Manages the Kibana5 service and restarts it as necessary.
#
# === Parameters
#
# See the kibana5 class
#
# === Authors
#
# Matt Wise <matt@nextdoor.com>
#
class kibana5::service (
  $ensure   = $kibana5::service_ensure,
  $enable   = $kibana5::service_enable,
  $provider = $kibana5::service_provider,
) inherits kibana5 {
  service { 'kibana5':
    ensure     => $ensure,
    enable     => $enable,
    name       => 'kibana',
    provider   => $provider,
    hasstatus  => true,
    hasrestart => true,
  }
}
