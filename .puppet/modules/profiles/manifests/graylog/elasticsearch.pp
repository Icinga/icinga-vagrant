class profiles::graylog::elasticsearch (
  $repo_version = 6,
  $elasticsearch_revision = '´6.8.5',
  $elasticsearch_host = '127.0.0.1',
  $elasticsearch_port = 9200
) {
  class { 'elastic_stack::repo':
    version => $repo_version,
  #  oss     => true,
  }

  file { '/etc/security/limits.d/99-elasticsearch.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "elasticsearch soft nofile 64000\nelasticsearch hard nofile 64000\n",
  }
  ->
  class { 'elasticsearch':
  #  oss         => true,
    version     => $elasticsearch_revision,
    jvm_options => [
      '-Xms256m',
      '-Xmx256m'
    ],
  }
  ->
  elasticsearch::instance { 'graylog-es':
    config => {
      'cluster.name' => 'graylog',
      'network.host' => $elasticsearch_host
    }
  }
  ->
  es_instance_conn_validator { 'graylog-es':
    server => $elasticsearch_host,
    port   => $elasticsearch_port,
    timeout => 1800
  }
}
