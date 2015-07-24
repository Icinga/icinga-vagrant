# == Class: graylog2::server::params
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::server::params {
  # OS specific settings.
  case $::osfamily {
    'Debian', 'RedHat': {
      # Nothing yet.
    }
    default: {
      fail("${::osfamily} is not supported by ${module_name}")
    }
  }

  $package_name = 'graylog-server'
  $package_version = 'installed'

  $service_name  = 'graylog-server'

  $service_ensure = 'running'
  $service_enable = true

  $config_file = '/etc/graylog/server/server.conf'
  $daemon_username = 'graylog'

  # Config file variables.
  $alert_check_interval = '60'
  $allow_highlighting = false
  $allow_leading_wildcard_searches = false
  $async_eventbus_processors = '2'
  $collector_expiration_threshold = '14d'
  $collector_inactive_threshold = '1m'
  $command_wrapper = ''
  $dashboard_widget_default_cache_time = '10s'
  $dead_letters_enabled = false
  $disable_index_optimization = false
  $disable_index_range_calculation = true
  $disable_sigar = false
  $elasticsearch_analyzer = 'standard'
  $elasticsearch_cluster_discovery_timeout = '5000'
  $elasticsearch_cluster_name = 'graylog2'
  $elasticsearch_config_file = false
  $elasticsearch_disable_version_check = false
  $elasticsearch_discovery_initial_state_timeout = '3s'
  $elasticsearch_discovery_zen_ping_multicast_enabled = true
  $elasticsearch_discovery_zen_ping_unicast_hosts = false
  $elasticsearch_http_enabled = false
  $elasticsearch_index_prefix = 'graylog2'
  $elasticsearch_max_docs_per_index = '20000000'
  $elasticsearch_max_number_of_indices = '20'
  $elasticsearch_max_size_per_index = '1073741824'
  $elasticsearch_max_time_per_index = '1d'
  $elasticsearch_network_bind_host = false
  $elasticsearch_network_host = false
  $elasticsearch_network_publish_host = false
  $elasticsearch_node_data = false
  $elasticsearch_node_master = false
  $elasticsearch_node_name = 'graylog2-server'
  $elasticsearch_replicas = '0'
  $elasticsearch_shards = '4'
  $elasticsearch_store_timestamps_as_doc_values = true
  $elasticsearch_transport_tcp_port = '9350'
  $enable_metrics_collection = false
  $extra_args = ''
  $gc_warning_threshold = '1s'
  $groovy_shell_enable = false
  $groovy_shell_port = '6789'
  $http_connect_timeout = '5s'
  $http_proxy_uri = false
  $http_read_timeout = '10s'
  $http_write_timeout = '10s'
  $index_optimization_max_num_segments = '1'
  $inputbuffer_processors = '2'
  $inputbuffer_ring_size = '65536'
  $inputbuffer_wait_strategy = 'blocking'
  $is_master = true
  $java_opts = '-Xms1g -Xmx1g -XX:NewRatio=1 -XX:PermSize=128m -XX:MaxPermSize=256m -server -XX:+ResizeTLAB -XX:+UseConcMarkSweepGC -XX:+CMSConcurrentMTEnabled -XX:+CMSClassUnloadingEnabled -XX:+UseParNewGC -XX:-OmitStackTraceInFastThrow'
  $lb_recognition_period_seconds = '3'
  $ldap_connection_timeout = '2000'
  $message_journal_dir = '/var/lib/graylog-server/journal'
  $message_journal_enabled = true
  $message_journal_flush_age = '1m'
  $message_journal_flush_interval = '1000000'
  $message_journal_max_age = '12h'
  $message_journal_max_size = '5gb'
  $message_journal_segment_age = '1h'
  $message_journal_segment_size = '100mb'
  $mongodb_database = 'graylog2'
  $mongodb_host = '127.0.0.1'
  $mongodb_uri = false
  $mongodb_max_connections = '100'
  $mongodb_password = false
  $mongodb_port = '27017'
  $mongodb_replica_set = false
  $mongodb_threads_allowed_to_block_multiplier = '5'
  $mongodb_useauth = false
  $mongodb_user = false
  $node_id_file = '/etc/graylog/server/node-id'
  $no_retention = false
  $output_batch_size = '500'
  $outputbuffer_processor_keep_alive_time = '5000'
  $outputbuffer_processors = '3'
  $outputbuffer_processor_threads_core_pool_size = '3'
  $outputbuffer_processor_threads_max_pool_size = '30'
  $output_fault_count_threshold = '5'
  $output_fault_penalty_seconds = '30'
  $output_flush_interval = '1'
  $output_module_timeout = '10000'
  $password_secret = undef
  $plugin_dir = '/usr/share/graylog-server/plugin'
  $processbuffer_processors = '5'
  $processor_wait_strategy = 'blocking'
  $rest_enable_cors = false
  $rest_enable_gzip = false
  $rest_enable_tls = false
  $rest_listen_uri = 'http://127.0.0.1:12900/'
  $rest_max_chunk_size = '8192'
  $rest_max_header_size = '8192'
  $rest_max_initial_line_length = '4096'
  $rest_thread_pool_size = '16'
  $rest_tls_cert_file = false
  $rest_tls_key_file = false
  $rest_tls_key_password = false
  $rest_transport_uri = 'http://127.0.0.1:12900/'
  $rest_worker_threads_max_pool_size = '16'
  $retention_strategy = 'delete'
  $ring_size = '65536'
  $root_email = ''
  $root_password_sha2 = undef
  $root_timezone = 'UTC'
  $root_username = 'admin'
  $rotation_strategy = 'count'
  $rules_file = false
  $shutdown_timeout = '30000'
  $stale_master_timeout = '2000'
  $stream_processing_max_faults = '3'
  $stream_processing_timeout = '2000'
  $transport_email_auth_password = 'secret'
  $transport_email_auth_username = 'you@example.com'
  $transport_email_enabled = false
  $transport_email_from_email = 'graylog@example.com'
  $transport_email_hostname = 'mail.example.com'
  $transport_email_port = '587'
  $transport_email_subject_prefix = '[Graylog]'
  $transport_email_use_auth = true
  $transport_email_use_ssl = true
  $transport_email_use_tls = false
  $transport_email_web_interface_url = false
  $udp_recvbuffer_sizes = '1048576'
  $usage_statistics_cache_timeout = '15m'
  $usage_statistics_dir = '/var/lib/graylog-server/usage-statistics'
  $usage_statistics_enabled = true
  $usage_statistics_gzip_enabled = true
  $usage_statistics_initial_delay = '5m'
  $usage_statistics_max_queue_size = '10'
  $usage_statistics_offline_mode = false
  $usage_statistics_report_interval = '6h'
  $usage_statistics_url = 'https://stats-collector.graylog.com/submit/'
  $versionchecks = true
  $versionchecks_uri = 'https://versioncheck.graylog.com/check'
}
