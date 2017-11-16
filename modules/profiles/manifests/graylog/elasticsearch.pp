class profiles::graylog::elasticsearch (
  $repo_version = '5.x',
  $elasticsearch_host = '127.0.0.1',
  $elasticsearch_port = 9200
) {

  include '::profiles::base::java'

  file { '/etc/security/limits.d/99-elasticsearch.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "elasticsearch soft nofile 64000\nelasticsearch hard nofile 64000\n",
  }
  ->
  class { 'elasticsearch':
    manage_repo  => true,
    repo_version => $repo_version,
    java_install => false,
    jvm_options => [
      '-Xms256m',
      '-Xmx256m'
    ],
    require => Class['java']
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
