class profiles::elastic::elasticsearch (
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
