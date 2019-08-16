# == Class: influxdb
#
#
# === Author
#
# Dejan Golja <dejan@golja.org>
#
class influxdb(
  $version                   = $influxdb::params::version,
  $ensure                    = $influxdb::params::ensure,
  $service_enabled           = $influxdb::params::service_enabled,
  $service_ensure            = $influxdb::params::service_ensure,
  $manage_service            = $influxdb::params::manage_service,
  $conf_template             = $influxdb::params::conf_template,
  $config_file               = $influxdb::params::config_file,

  $global_config             = $influxdb::params::global_config,
  $meta_config               = $influxdb::params::meta_config,
  $data_config               = $influxdb::params::data_config,
  $logging_config            = $influxdb::params::logging_config,
  $coordinator_config        = $influxdb::params::coordinator_config,
  $retention_config          = $influxdb::params::retention_config,
  $shard_precreation_config  = $influxdb::params::shard_precreation_config,
  $monitor_config            = $influxdb::params::monitor_config,
  $admin_config              = $influxdb::params::admin_config,
  $http_config               = $influxdb::params::http_config,
  $subscriber_config         = $influxdb::params::subscriber_config,
  $graphite_config           = $influxdb::params::graphite_config,
  $collectd_config           = $influxdb::params::collectd_config,
  $opentsdb_config           = $influxdb::params::opentsdb_config,
  $udp_config                = $influxdb::params::udp_config,
  $continuous_queries_config = $influxdb::params::continuous_queries_config,
  $hinted_handoff_config     = $influxdb::params::hinted_handoff_config,

  $influxdb_stderr_log       = $influxdb::params::influxdb_stderr_log,
  $influxdb_stdout_log       = $influxdb::params::influxdb_stdout_log,
  $influxd_opts              = $influxdb::params::influxd_opts,
  $manage_install            = $influxdb::params::manage_install,
  $manage_repos              = $influxdb::params::manage_repos,
) inherits influxdb::params {

  anchor { 'influxdb::start': }
  -> class { 'influxdb::install': }
  -> class { 'influxdb::config': }
  -> class { 'influxdb::service': }
  -> anchor { 'influxdb::end': }

}
