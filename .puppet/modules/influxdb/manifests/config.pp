#
class influxdb::config(
  $conf                      = $influxdb::config_file,
  $conf_owner                = 'root',
  $conf_group                = 'root',
  $conf_mode                 = '0644',
  $conf_template             = $influxdb::conf_template,

  $startup_conf              = $influxdb::startup_conf,
  $startup_conf_template     = $influxdb::startup_conf_template,

  $influxdb_stderr_log       = $influxdb::influxdb_stderr_log,
  $influxdb_stdout_log       = $influxdb::influxdb_stdout_log,
  $influxd_opts              = $influxdb::influxd_opts,

  $global_config             = $influxdb::global_config,
  $meta_config               = $influxdb::meta_config,
  $data_config               = $influxdb::data_config,
  $logging_config            = $influxdb::logging_config,
  $coordinator_config        = $influxdb::coordinator_config,
  $retention_config          = $influxdb::retention_config,
  $shard_precreation_config  = $influxdb::shard_precreation_config,
  $monitor_config            = $influxdb::monitor_config,
  $admin_config              = $influxdb::admin_config,
  $http_config               = $influxdb::http_config,
  $subscriber_config         = $influxdb::subscriber_config,
  $graphite_config           = $influxdb::graphite_config,
  $collectd_config           = $influxdb::collectd_config,
  $opentsdb_config           = $influxdb::opentsdb_config,
  $udp_config                = $influxdb::udp_config,
  $continuous_queries_config = $influxdb::continuous_queries_config,
  $hinted_handoff_config     = $influxdb::hinted_handoff_config,
) {

  $notify = $influxdb::manage_service ? {
    true => Service['influxdb'],
    false => undef,
    default => undef,
  }

  file { $conf:
    ensure  => 'file',
    owner   => $conf_owner,
    group   => $conf_group,
    mode    => $conf_mode,
    content => template($conf_template),
    notify  => $notify,
    require => Package['influxdb'],
  }

  if $startup_conf {

    file { $startup_conf:
      ensure  => 'file',
      owner   => $conf_owner,
      group   => $conf_group,
      mode    => $conf_mode,
      content => template($startup_conf_template),
      notify  => $notify,
      require => Package['influxdb'],
    }

  }

}
