class pnp4nagios {
  class{'pnp4nagios::params':} ->
  class{'pnp4nagios::install':} ->
  class{'pnp4nagios::config':} ->
  class{'pnp4nagios::service':} ->
  Class["pnp4nagios"]
}
