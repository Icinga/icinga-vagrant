# Class prometheus::config
# Configuration class for prometheus monitoring system
class prometheus::config {

  assert_private()

  $max_open_files = $prometheus::max_open_files

  $prometheus_v2 = versioncmp($prometheus::server::version, '2.0.0') >= 0

  # Validation
  $invalid_args = if $prometheus_v2 {
    {
      'alertmanager.url'                 => $prometheus::alertmanager_url,
      'query.staleness-delta'            => $prometheus::query_staleness_delta,
      'web.telemetry-path'               => $prometheus::web_telemetry_path,
      'web.enable-remote-shutdown'       => $prometheus::web_enable_remote_shutdown,
    }
  } else {
    {
      'web.enable-lifecycle'                    => $prometheus::web_enable_lifecycle,
      'web.enable-admin-api'                    => $prometheus::web_enable_admin_api,
      'web.page-title'                          => $prometheus::web_page_title,
      'web.cors.origin'                         => $prometheus::web_cors_origin,
      'storage.tsdb.retention.size'             => $prometheus::storage_retention_size,
      'storage.tsdb.no-lockfile'                => $prometheus::storage_no_lockfile,
      'storage.tsdb.allow-overlapping-blocks'   => $prometheus::storage_allow_overlapping_blocks,
      'storage.tsdb.wal-compression'            => $prometheus::storage_wal_compression,
      'storage.remote.flush-deadline'           => $prometheus::storage_flush_deadline,
      'storage.remote.read-concurrent-limit'    => $prometheus::storage_read_concurrent_limit,
      'storage.remote.read-max-bytes-in-frame'  => $prometheus::storage_read_max_bytes_in_frame,
      'rules.alert.for-outage-tolerance'        => $prometheus::alert_for_outage_tolerance,
      'rules.alert.for-grace-period'            => $prometheus::alert_for_grace_period,
      'rules.alert.resend-delay'                => $prometheus::alert_resend_delay,
      'query.lookback-delta'                    => $prometheus::query_lookback_delta,
      'log.format'                              => $prometheus::log_format,
    }
  }

  $invalid_options = $invalid_args
  .filter |$key,$value| { $value or $key in $prometheus::server::extra_options}
  .map    |$key,$value| { $key }

  unless empty($invalid_options) {
    $error_message = if $prometheus_v2 {
      'no longer available in prometheus v2'
    } else {
      'require prometheus v2; consider upgrading'
    }
    $error = "invalid command line arguments: [${join($invalid_options, ', ')}] ${error_message}"
    fail($error)
  }
  unless $prometheus_v2 {
    if $prometheus::server::remote_read_configs != [] {
      fail('remote_read_configs requires prometheus v2')
    }
    if $prometheus::server::remote_write_configs != [] {
      fail('remote_write_configs requires prometheus v2')
    }
  }
  if ($prometheus_v2 and $prometheus::log_level == 'fatal') {
    fail('fatal is no longer a valid value in prometheus v2')
  }
  if versioncmp($prometheus::server::version, '2.7.0') < 0 and $prometheus::storage_retention_size {
    fail('storage.tsdb.retention.size is only available starting in prometheus 2.7')
  }

  # Formatting
  $v1_log_format = if ($prometheus::log_format == 'json') { '?json=true' } else { undef }
  $web_page_title = if ($prometheus::web_page_title) { "\"${prometheus::web_page_title}\"" } else { undef }
  $web_cors_origin = if ($prometheus::web_cors_origin) { "\"${prometheus::web_cors_origin}\"" } else { undef }
  $rtntn_suffix = if versioncmp($prometheus::server::version, '2.8.0') >= 0 { '.time' } else { undef }
  $command_line_flags = if $prometheus_v2 {
    {
      'config.file'                              => "${prometheus::server::config_dir}/${prometheus::server::configname}",
      'web.listen-address'                       => $prometheus::web_listen_address,
      'web.read-timeout'                         => $prometheus::web_read_timeout,
      'web.max-connections'                      => $prometheus::web_max_connections,
      'web.external-url'                         => $prometheus::server::external_url,
      'web.route-prefix'                         => $prometheus::web_route_prefix,
      'web.user-assets'                          => $prometheus::web_user_assets,
      'web.enable-lifecycle'                     => $prometheus::web_enable_lifecycle,
      'web.enable-admin-api'                     => $prometheus::web_enable_admin_api,
      'web.console.templates'                    => "${prometheus::shared_dir}/consoles",
      'web.console.libraries'                    => "${prometheus::shared_dir}/console_libraries",
      'web.page-title'                           => $web_page_title,
      'web.cors.origin'                          => $web_cors_origin,
      'storage.tsdb.path'                        => $prometheus::server::localstorage,
      "storage.tsdb.retention${rtntn_suffix}"    => $prometheus::server::storage_retention,
      'storage.tsdb.retention.size'              => $prometheus::storage_retention_size,
      'storage.tsdb.no-lockfile'                 => $prometheus::storage_no_lockfile,
      'storage.tsdb.allow-overlapping-blocks'    => $prometheus::storage_allow_overlapping_blocks,
      'storage.tsdb.wal-compression'             => $prometheus::storage_wal_compression,
      'storage.remote.flush-deadline'            => $prometheus::storage_flush_deadline,
      'storage.remote.read-sample-limit'         => $prometheus::storage_read_sample_limit,
      'storage.remote.read-concurrent-limit'     => $prometheus::storage_read_concurrent_limit,
      'storage.remote.read-max-bytes-in-frame'   => $prometheus::storage_read_max_bytes_in_frame,
      'rules.alert.for-outage-tolerance'         => $prometheus::alert_for_outage_tolerance,
      'rules.alert.for-grace-period'             => $prometheus::alert_for_grace_period,
      'rules.alert.resend-delay'                 => $prometheus::alert_resend_delay,
      'alertmanager.notification-queue-capacity' => $prometheus::alertmanager_notification_queue_capacity,
      'alertmanager.timeout'                     => $prometheus::alertmanager_timeout,
      'query.lookback-delta'                     => $prometheus::query_lookback_delta,
      'query.timeout'                            => $prometheus::query_timeout,
      'query.max-concurrency'                    => $prometheus::query_max_concurrency,
      'query.max-samples'                        => $prometheus::query_max_samples,
      'log.level'                                => $prometheus::log_level,
      'log.format'                               => $prometheus::log_format
    }
  } else {
    {
      'config.file'                              => "${prometheus::server::config_dir}/${prometheus::server::configname}",
      'web.listen-address'                       => $prometheus::web_listen_address,
      'web.read-timeout'                         => $prometheus::web_read_timeout,
      'web.max-connections'                      => $prometheus::web_max_connections,
      'web.external-url'                         => $prometheus::server::external_url,
      'web.route-prefix'                         => $prometheus::web_route_prefix,
      'web.user-assets'                          => $prometheus::web_user_assets,
      'web.console.templates'                    => "${prometheus::shared_dir}/consoles",
      'web.console.libraries'                    => "${prometheus::shared_dir}/console_libraries",
      'web.telemetry-path'                       => $prometheus::web_telemetry_path,
      'web.enable-remote-shutdown'               => $prometheus::web_enable_remote_shutdown,
      'storage.local.path'                       => $prometheus::server::localstorage,
      'storage.local.retention'                  => $prometheus::server::storage_retention,
      'alertmanager.notification-queue-capacity' => $prometheus::alertmanager_notification_queue_capacity,
      'alertmanager.timeout'                     => $prometheus::alertmanager_timeout,
      'alertmanager.url'                         => $prometheus::alertmanager_url,
      'query.timeout'                            => $prometheus::query_timeout,
      'query.max-concurrency'                    => $prometheus::query_max_concurrency,
      'query.staleness-delta'                    => $prometheus::query_staleness_delta,
      'log.level'                                => $prometheus::log_level,
      'log.format'                               => 'logger:stdout',
    }
  }

  $flag_prefix   = if ($prometheus_v2) { '--' } else { '-' }
  $extra_options = [$prometheus::server::extra_options].filter |$opts| { $opts and $opts != '' }
  $flags         =  $command_line_flags
  .filter |$flag, $value| {
    $value ? {
      Boolean => $value,
      String  => $value != '',
      Undef   => false,
      default => fail("Illegal value for ${flag} parameter")
    }
  }
  .map    |$flag, $value| {
    $value ? {
      Boolean => "${flag_prefix}${flag}",
      String  => "${flag_prefix}${flag}=${value}",
      default => fail("Illegal value for ${flag} parameter")
    }
  }
  $daemon_flags = $flags + $extra_options

  # Service files (init-files/systemd unit files) need to trigger a full service restart
  # prometheus.yaml and associated scrape file changes should only trigger a reload (and not use $notify)
  $notify = $prometheus::server::restart_on_change ? {
    true    => Class['prometheus::run_service'],
    default => undef,
  }

  case $prometheus::server::init_style { # lint:ignore:case_without_default
    'upstart': {
      file { '/etc/init/prometheus.conf':
        ensure  => file,
        mode    => '0444',
        owner   => 'root',
        group   => 'root',
        content => template('prometheus/prometheus.upstart.erb'),
        notify  => $notify,
      }
      file { '/etc/init.d/prometheus':
        ensure => link,
        target => '/lib/init/upstart-job',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        notify => $notify,
      }
    }
    'systemd': {
      systemd::unit_file {'prometheus.service':
        content => template('prometheus/prometheus.systemd.erb'),
        notify  => $notify,
      }
      if versioncmp($facts['puppetversion'],'6.1.0') < 0 {
        # Puppet 5 doesn't have https://tickets.puppetlabs.com/browse/PUP-3483
        # and camptocamp/systemd only creates this relationship when managing the service
        Class['systemd::systemctl::daemon_reload'] -> Class['prometheus::run_service']
      }
    }
    'sysv', 'redhat', 'debian', 'sles': {
      $content = $prometheus::server::init_style ? {
        'redhat' => template('prometheus/prometheus.sysv.erb'), # redhat and sysv share the same template file
        default  => template("prometheus/prometheus.${prometheus::server::init_style}.erb"),
      }
      file { '/etc/init.d/prometheus':
        ensure  => file,
        mode    => '0555',
        owner   => 'root',
        group   => 'root',
        content => $content,
        notify  => $notify,
      }
    }
    'launchd': {
      file { '/Library/LaunchDaemons/io.prometheus.daemon.plist':
        ensure  => file,
        mode    => '0644',
        owner   => 'root',
        group   => 'wheel',
        content => template('prometheus/prometheus.launchd.erb'),
        notify  => $notify,
      }
    }
    'none': {}
  }

  # TODO: promtool currently does not support checking the syntax of file_sd_config "includes".
  # Ideally we'd check them the same way the other config files are checked.
  file { "${prometheus::config_dir}/file_sd_config.d":
    ensure  => directory,
    group   => $prometheus::server::group,
    purge   => true,
    recurse => true,
    notify  => Class['prometheus::service_reload'], # After purging, a reload is needed
  }

  $prometheus::server::collect_scrape_jobs.each |Hash $job_definition| {
    if !has_key($job_definition, 'job_name') {
      fail('collected scrape job has no job_name!')
    }

    $job_name = $job_definition['job_name']

    Prometheus::Scrape_job <<| job_name == $job_name |>> {
      collect_dir => "${prometheus::config_dir}/file_sd_config.d",
      notify      => Class['::prometheus::service_reload'],
    }
  }
  # assemble the scrape jobs in a single list that gets appended to
  # $scrape_configs in the template
  $collected_scrape_jobs = $prometheus::server::collect_scrape_jobs.map |$job_definition| {
    $job_name = $job_definition['job_name']
    merge($job_definition, {
      file_sd_configs => [{
        files => [ "${prometheus::config_dir}/file_sd_config.d/${job_name}_*.yaml" ]
      }]
      })
  }

  if versioncmp($prometheus::server::version, '2.0.0') >= 0 {
    $cfg_verify_cmd = 'check config'
  } else {
    $cfg_verify_cmd = 'check-config'
  }

  if $prometheus::server::manage_config {
    file { 'prometheus.yaml':
      ensure       => file,
      path         => "${prometheus::server::config_dir}/${prometheus::server::configname}",
      owner        => 'root',
      group        => $prometheus::server::group,
      mode         => $prometheus::server::config_mode,
      notify       => Class['prometheus::service_reload'],
      content      => template($prometheus::server::config_template),
      validate_cmd => "${prometheus::server::bin_dir}/promtool ${cfg_verify_cmd} %",
    }
  }

}
