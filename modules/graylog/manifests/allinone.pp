class graylog::allinone(
  $elasticsearch,
  $graylog,
) inherits graylog::params {

  class {'::mongodb::globals':
    manage_package_repo => true,
  }->
  class {'::mongodb::server':
    bind_ip => ['127.0.0.1'],
  }


  if has_key($elasticsearch, 'version') {
    $es_version = $elasticsearch['version']
  } else {
    $es_version = '2.3.2'
  }
  if has_key($elasticsearch, 'repo_version') {
    $es_repo_version = $elasticsearch['repo_version']
  } else {
    $es_repo_version = '2.x'
  }

  class { 'elasticsearch':
    version      => $es_version,
    manage_repo  => true,
    repo_version => $es_repo_version,
  }->
  elasticsearch::instance { 'graylog':
    config => {
      'cluster.name' => 'graylog',
      'network.host' => '127.0.0.1',
    },
  }


  if has_key($graylog, 'major_version') {
    $graylog_major_version = $graylog['major_version']
  } else {
    $graylog_major_version = $graylog::params::major_version
  }

  class { 'graylog::repository':
    version => $graylog_major_version,
  }->
  class { 'graylog::server':
    config => $graylog['config'],
  }
}
