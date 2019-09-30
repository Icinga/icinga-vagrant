class profiles::elastic::elasticsearch (
  $repo_version = 6,
  $elasticsearch_revision = '6.3.1',
  $elasticsearch_host = '127.0.0.1',
  $elasticsearch_port = 9200
) {
  class { 'elastic_stack::repo':
    version => $repo_version,
    oss     => true,
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
    oss         => true,
    version     => $elasticsearch_revision,
    # Commented out options is a workaround for https://github.com/elastic/puppet-elasticsearch/issues/1032
    jvm_options => [
      '-Xms256m',
      '-Xmx256m',
      '#PrintGCDetails',
      '#PrintGCDateStamps',
      '#PrintTenuringDistribution',
      '#PrintGCApplicationStoppedTime',
      "#Xloggc",
      '#UseGCLogFileRotation',
      "#NumberOfGCLogFiles",
      "#GCLogFileSize",
      "#XX:UseConcMarkSweepGC",
    ],
  }
  ->
  elasticsearch::instance { 'elastic-es':
    config => {
      'cluster.name' => 'elastic',
      'network.host' => $elasticsearch_host
    }
  }
  ->
  es_instance_conn_validator { 'elastic-es':
    server => $elasticsearch_host,
    port   => $elasticsearch_port,
    timeout => 1800
  }

}
