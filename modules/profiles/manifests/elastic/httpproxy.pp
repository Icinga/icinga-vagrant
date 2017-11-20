class profiles::elastic::httpproxy (
  $listen_ip = '192.168.33.7'
) {

  # defaults to icinga:icinga
  $elastic_basic_auth_file = '/etc/nginx/elastic.passwd'

  # TODO: Remove this when profiles::base::nginx is used
  class { 'nginx':
    confd_purge => true,
  }

  file { $elastic_basic_auth_file:
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('profiles/elastic/elastic.passwd.erb')
  }

  -> nginx::resource::server { 'elasticsearch.vagrant-demo.icinga.com':
    listen_ip            => $listen_ip,
    listen_port          => 9200,
    ssl                  => true,
    ssl_port             => 9202,
    ssl_cert             => '/var/lib/icinga2/certs/icinga2-elastic.crt',
    ssl_key              => '/var/lib/icinga2/certs/icinga2-elastic.key',
    ssl_trusted_cert     => '/var/lib/icinga2/certs/ca.crt',
    ipv6_listen_port     => 9200,
    proxy                => 'http://localhost:9200',
    auth_basic           => 'Elasticsearch auth',
    auth_basic_user_file => $elastic_basic_auth_file,
  }

  -> nginx::resource::server { 'kibana.vagrant-demo.icinga.com':
    listen_ip            => $listen_ip,
    listen_port          => 5601,
    ssl                  => true,
    ssl_port             => 5602,
    ssl_cert             => '/var/lib/icinga2/certs/icinga2-elastic.crt',
    ssl_key              => '/var/lib/icinga2/certs/icinga2-elastic.key',
    ssl_trusted_cert     => '/var/lib/icinga2/certs/ca.crt',
    ipv6_listen_port     => 5601,
    proxy                => 'http://localhost:5601',
    auth_basic           => 'Kibana auth',
    auth_basic_user_file => $elastic_basic_auth_file,
  }
}
