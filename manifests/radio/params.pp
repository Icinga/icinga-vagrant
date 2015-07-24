# == Class: graylog2::radio::params
#
# === Authors
#
# Renan Silva <renanvice@gmail.com>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::radio::params {

  # OS specific settings.
  case $::osfamily {
    'Debian', 'RedHat': {
      # Nothing yet.
    }
    default: {
      fail("${::osfamily} is not supported by ${module_name}")
    }
  }

  $package_name = 'graylog-radio'
  $package_version = 'installed'

  $service_name  = 'graylog-radio'
  $service_ensure = 'running'
  $service_enable = true

  $config_file = '/etc/graylog/radio/radio.conf'
  $daemon_username = 'graylog-radio'

  # Config file variables.
  $node_id_file = '/etc/graylog/radio/node-id'
  $transport_type = 'amqp'
  $plugin_dir = '/usr/share/graylog-radio/plugin'
  $graylog2_server_uris = ['http://127.0.0.1:12900/']
  $rest_listen_uri = 'http://127.0.0.1:12950/'
  $rest_transport_uri = 'http://127.0.0.1:12950/'
  $rest_enable_cors = true
  $rest_enable_gzip = true
  $rest_enable_tls = false
  $rest_tls_cert_file = false
  $rest_tls_key_file = false
  $rest_tls_key_password = false
  $rest_max_chunk_size = '8192'
  $rest_max_header_size = '8192'
  $rest_max_initial_line_length = '4096'
  $rest_thread_pool_size = '16'
  $rest_worker_threads_max_pool_size = '16'
  $radio_transport_max_errors = '0'
  $amqp_broker_hostname = 'localhost'
  $amqp_broker_port = '5672'
  $amqp_broker_connect_timeout = '5s'
  $amqp_broker_vhost = '/'
  $amqp_broker_username = 'guest'
  $amqp_broker_password = 'guest'
  $amqp_broker_exchange_name = 'graylog2'
  $amqp_broker_queue_name = 'graylog2-radio-messages'
  $amqp_broker_queue_type = 'topic'
  $amqp_broker_routing_key = 'graylog2-radio-message'
  $amqp_persistent_messages_enabled = false
  $amqp_broker_parallel_queues = '1'
  $command_wrapper = ''
  $kafka_brokers = []
  $kafka_producer_type = 'sync'
  $kafka_batch_size = '200'
  $kafka_batch_max_wait_ms = '250'
  $kafka_required_acks = '0'
  $processbuffer_processors = '5'
  $processor_wait_strategy = 'blocking'
  $ring_size = '65536'
  $inputbuffer_ring_size = '65536'
  $inputbuffer_processors = '2'
  $inputbuffer_wait_strategy = 'blocking'
  $udp_recvbuffer_sizes = '1048576'
  $async_eventbus_processors = '2'
  $disable_sigar = false
  $http_proxy_uri = ''
  $java_opts = ''
  $extra_args = ''
  $template_file = ''
  $template_config_file = ''
}
