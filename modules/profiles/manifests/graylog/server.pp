class profiles::graylog::server (
  $repo_version = '2.3',
  $listen_ip = '192.169.33.6',
  $listen_port = 9000
) {

  include '::profiles::base::java'

  class { 'graylog::repository':
    version => $repo_version
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
}
