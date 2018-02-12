class profiles::graylog::server (
  $repo_version = '2.4',
  $listen_ip = '192.169.33.6',
  $listen_port = 9000
) {
  class { 'graylog::repository':
    version => $repo_version
  }->
  # workaround for missing refresh in graylog::repository
  exec { 'refresh-yum-repo':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => 'yum makecache'
  }->
  class { 'graylog::server':
    config                       => {
      'password_secret'          => '0CDCipdUvE3cSPN8OXARpAKU6bO9N41DuVNEMD95KyPgI3oGExLJiiZdy57mwpbqrvXqta5C2yaARe2tLPpmTfos47QOoBDP',
      'root_password_sha2'       => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
      'rest_listen_uri'          => "http://$listen_ip:$listen_port/api/",
      'web_listen_uri'           => "http://$listen_ip:$listen_port/",
      'web_endpoint_uri'         => "http://$listen_ip:$listen_port/api/",
      'versionchecks'            => false,
      'usage_statistics_enabled' => false,
    }
  }

  package { "ruby":
    ensure => installed,
  }
  ->
  file { "graylog-seed-setup":
    name => "/usr/local/bin/graylog-seed.rb",
    owner => root,
    group => root,
    mode => "0755",
    content => template("profiles/graylog/graylog-seed.rb.erb")
  }
  ->
  exec { "finish-graylog-seed-setup":
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    command => "/usr/local/bin/graylog-seed.rb",
    timeout => 1800
  }
}
