# == Class: graylog2::radio
#
# === Authors
#
# Renan Silva <renanvice@gmail.com>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::radio (
  $package_version           = $graylog2::radio::params::package_version,
  $service_ensure            = $graylog2::radio::params::service_ensure,
  $service_enable            = $graylog2::radio::params::service_enable,
  $config_file               = $graylog2::radio::params::config_file,
  $daemon_username           = $graylog2::radio::params::daemon_username,

  $node_id_file              = $graylog2::radio::params::node_id_file,
  $transport_type            = $graylog2::radio::params::transport_type,
  $plugin_dir                = $graylog2::radio::params::plugin_dir,
  $graylog2_server_uris      = $graylog2::radio::params::graylog2_server_uris,
  $rest_listen_uri           = $graylog2::radio::params::rest_listen_uri,
  $rest_transport_uri        = $graylog2::radio::params::rest_transport_uri,
  $rest_enable_cors          = $graylog2::radio::params::rest_enable_cors,
  $rest_enable_gzip          = $graylog2::radio::params::rest_enable_gzip,
  $rest_enable_tls           = $graylog2::radio::params::rest_enable_tls,
  $rest_tls_cert_file        = $graylog2::radio::params::rest_tls_cert_file,
  $rest_tls_key_file         = $graylog2::radio::params::rest_tls_key_file,
  $rest_tls_key_password     = $graylog2::radio::params::rest_tls_key_password,
  $rest_max_chunk_size       = $graylog2::radio::params::rest_max_chunk_size,
  $rest_max_header_size      = $graylog2::radio::params::rest_max_header_size,
  $rest_max_initial_line_length = $graylog2::radio::params::rest_max_initial_line_length,
  $rest_thread_pool_size     = $graylog2::radio::params::rest_thread_pool_size,
  $rest_worker_threads_max_pool_size = $graylog2::radio::params::rest_worker_threads_max_pool_size,
  $radio_transport_max_errors = $graylog2::radio::params::radio_transport_max_errors,
  $amqp_broker_hostname      = $graylog2::radio::params::amqp_broker_hostname,
  $amqp_broker_port          = $graylog2::radio::params::amqp_broker_port,
  $amqp_broker_connect_timeout = $graylog2::radio::params::amqp_broker_connect_timeout,
  $amqp_broker_vhost         = $graylog2::radio::params::amqp_broker_vhost,
  $amqp_broker_username      = $graylog2::radio::params::amqp_broker_username,
  $amqp_broker_password      = $graylog2::radio::params::amqp_broker_password,
  $amqp_broker_exchange_name = $graylog2::radio::params::amqp_broker_exchange_name,
  $amqp_broker_queue_name    = $graylog2::radio::params::amqp_broker_queue_name,
  $amqp_broker_queue_type    = $graylog2::radio::params::amqp_broker_queue_type,
  $amqp_broker_routing_key   = $graylog2::radio::params::amqp_broker_routing_key,
  $amqp_persistent_messages_enabled = $graylog2::radio::params::amqp_persistent_messages_enabled,
  $amqp_broker_parallel_queues = $graylog2::radio::params::amqp_broker_parallel_queues,
  $command_wrapper           = $graylog2::radio::params::command_wrapper,
  $kafka_brokers             = $graylog2::radio::params::kafka_brokers,
  $kafka_producer_type       = $graylog2::radio::params::kafka_producer_type,
  $kafka_batch_size          = $graylog2::radio::params::kafka_batch_size,
  $kafka_batch_max_wait_ms   = $graylog2::radio::params::kafka_batch_max_wait_ms,
  $kafka_required_acks       = $graylog2::radio::params::kafka_required_acks,
  $processbuffer_processors  = $graylog2::radio::params::processbuffer_processors,
  $processor_wait_strategy   = $graylog2::radio::params::processor_wait_strategy,
  $ring_size                 = $graylog2::radio::params::ring_size,
  $inputbuffer_ring_size     = $graylog2::radio::params::inputbuffer_ring_size,
  $inputbuffer_processors    = $graylog2::radio::params::inputbuffer_processors,
  $inputbuffer_wait_strategy = $graylog2::radio::params::inputbuffer_wait_strategy,
  $udp_recvbuffer_sizes      = $graylog2::radio::params::udp_recvbuffer_sizes,
  $async_eventbus_processors = $graylog2::radio::params::async_eventbus_processors,
  $disable_sigar             = $graylog2::radio::params::disable_sigar,
  $http_proxy_uri            = $graylog2::radio::params::http_proxy_uri,
  $java_opts                 = $graylog2::radio::params::java_opts,
  $extra_args                = $graylog2::radio::params::extra_args,
  $template_file             = $graylog2::radio::params::template_file,
  $template_config_file      = $graylog2::radio::params::template_config_file,


) inherits graylog2::radio::params {

  anchor {'graylog2::radio::start': }->
  class {'graylog2::radio::package':
    package => $graylog2::radio::params::package_name,
    version => $package_version,
  } ->
  class {'graylog2::radio::configure':
    config_file              => $config_file,
    daemon_username          => $daemon_username,

    node_id_file             => $node_id_file,
    transport_type           => $transport_type,
    plugin_dir               => $plugin_dir,
    graylog2_server_uris     => $graylog2_server_uris,
    rest_listen_uri          => $rest_listen_uri,
    rest_transport_uri       => $rest_transport_uri,
    rest_enable_cors         => $rest_enable_cors,
    rest_enable_gzip         => $rest_enable_gzip,
    rest_enable_tls          => $rest_enable_tls,
    rest_tls_cert_file       => $rest_tls_cert_file,
    rest_tls_key_file        => $rest_tls_key_file,
    rest_tls_key_password    => $rest_tls_key_password,
    rest_max_chunk_size      => $rest_max_chunk_size,
    rest_max_header_size     => $rest_max_header_size,
    rest_max_initial_line_length => $rest_max_initial_line_length,
    rest_thread_pool_size    => $rest_thread_pool_size,
    rest_worker_threads_max_pool_size => $rest_worker_threads_max_pool_size,
    radio_transport_max_errors => $radio_transport_max_errors,
    amqp_broker_hostname     => $amqp_broker_hostname,
    amqp_broker_port         => $amqp_broker_port,
    amqp_broker_connect_timeout => $amqp_broker_connect_timeout,
    amqp_broker_vhost        => $amqp_broker_vhost,
    amqp_broker_username     => $amqp_broker_username,
    amqp_broker_password     => $amqp_broker_password,
    amqp_broker_exchange_name => $amqp_broker_exchange_name,
    amqp_broker_queue_name   => $amqp_broker_queue_name,
    amqp_broker_queue_type   => $amqp_broker_queue_type,
    amqp_broker_routing_key  => $amqp_broker_routing_key,
    amqp_persistent_messages_enabled => $amqp_persistent_messages_enabled,
    amqp_broker_parallel_queues => $amqp_broker_parallel_queues,
    command_wrapper          => $command_wrapper,
    kafka_brokers            => $kafka_brokers,
    kafka_producer_type      => $kafka_producer_type,
    kafka_batch_size         => $kafka_batch_size,
    kafka_batch_max_wait_ms  => $kafka_batch_max_wait_ms,
    kafka_required_acks      => $kafka_required_acks,
    processbuffer_processors => $processbuffer_processors,
    processor_wait_strategy  => $processor_wait_strategy,
    ring_size                => $ring_size,
    inputbuffer_ring_size    => $inputbuffer_ring_size,
    inputbuffer_processors   => $inputbuffer_processors,
    inputbuffer_wait_strategy => $inputbuffer_wait_strategy,
    udp_recvbuffer_sizes     => $udp_recvbuffer_sizes,
    async_eventbus_processors => $async_eventbus_processors,
    disable_sigar            => $disable_sigar,
    http_proxy_uri           => $http_proxy_uri,
    java_opts                => $java_opts,
    extra_args               => $extra_args,
    template_file            => $template_file,
    template_config_file     => $template_config_file,
  }~>
  class {'graylog2::radio::service':
    service_name   => $graylog2::radio::params::service_name,
    service_ensure => $service_ensure,
    service_enable => $service_enable,
  } ->
  anchor {'graylog2::radio::end': }

}
