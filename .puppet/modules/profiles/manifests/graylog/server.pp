class profiles::graylog::server (
  $repo_version = '3.1',
  $graylog_version = '3.1.3',
  $listen_ip = '192.169.33.6',
  $listen_port = 9000,
  $web_content_pack_id = lookup('graylog::web::content_pack_id'),
  $web_content_pack_rev = lookup('graylog::web::content_pack_rev')
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
      'http_bind_address'        => "$listen_ip:$listen_port",
      'password_secret'          => '0CDCipdUvE3cSPN8OXARpAKU6bO9N41DuVNEMD95KyPgI3oGExLJiiZdy57mwpbqrvXqta5C2yaARe2tLPpmTfos47QOoBDP',
      'root_password_sha2'       => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
    }
  }

  $web_content_pack_name = "$web_content_pack_id-$web_content_pack_rev"

  file { "icinga-vagrant-dashboard-content-pack-$web_content_pack_name.json":
    name => "/etc/icinga2/icinga-vagrant-dashboard-content-pack-$web_content_pack_name.json",
    owner => root,
    group => root,
    mode => "0755",
    content => template("profiles/graylog/icinga-vagrant-dashboard-content-pack-$web_content_pack_name.json.erb")
  }
  ->
  file { "graylog-seed-setup":
    name => "/usr/local/bin/graylog-seed.py",
    owner => root,
    group => root,
    mode => "0755",
    content => template("profiles/graylog/graylog-seed.py.erb"),
    require => Package['python36-requests']
  }
  ->
  exec { "finish-graylog-seed-setup":
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    command => "python3 /usr/local/bin/graylog-seed.py",
    timeout => 1800
  }
}
