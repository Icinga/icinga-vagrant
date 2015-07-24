node default {
  $es_cluster_name = 'gl2'
  $es_version = $::osfamily ? {
    'Debian' => '1.5.2',
    'Redhat' => '1.5.2-1',
  }

  # Dependencies
  class { 'elasticsearch':
    version      => $es_version,
    manage_repo  => true,
    repo_version => '1.5',
    java_install => true,
  }

  elasticsearch::instance { 'esgl2':
    config => {
      'cluster.name' => $es_cluster_name,
    },
  }

  class {'::mongodb::globals':
    manage_package_repo => true,
  }->
  class {'::mongodb::server': }


  # Graylog2
  class { 'graylog2::repo': version => '1.1' }

  class {'graylog2::server':
    package_version            => '1.1.3-1',
    password_secret            => '16BKgz0Qelg6eFeJYh8lc4hWU1jJJmAgHlPEx6qkBa2cQQTUG300FYlPOEvXsOV4smzRtnwjHAKykE3NIWXbpL7yGLN7V2P2',
    root_password_sha2         => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
    elasticsearch_cluster_name => $es_cluster_name,
    versionchecks              => false,
    usage_statistics_enabled   => false,
    require                    => [
      Elasticsearch::Instance['esgl2'],
      Class['mongodb::server'],
      Class['graylog2::repo'],
    ],
  }

  class {'graylog2::web':
    package_version    => '1.1.3-1',
    application_secret => '16BKgz0Qelg6eFeJYh8lc4hWU1jJJmAgHlPEx6qkBa2cQQTUG300FYlPOEvXsOV4smzRtnwjHAKykE3NIWXbpL7yGLN7V2P2',
    require            => Class['graylog2::server'],
    timeout            => '60s',
  }

  class {'graylog2::radio': }

  # Example workaround for dependency cycle.
  #Exec['apt_update'] -> Package <| title != 'apt-transport-https' |>
}
