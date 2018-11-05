class profiles::elastic::httpproxy (
  $listen_ip = '192.168.33.7',
  $node_name = 'icinga2',
  $listen_ports = {
     'kibana' => 5602,
     'kibana_tls' => 5603,
     'elasticsearch' => 9202,
     'elasticsearch_tls' => 9203
  }
) {

  # defaults to icinga:icinga
  $elastic_basic_auth_file = '/etc/nginx/elastic.passwd'

  # TODO: Remove this when profiles::base::nginx is used
  class { 'nginx':
    confd_purge => true,
  }

  file { "$elastic_basic_auth_file":
    owner  => root,
    group  => root,
    mode   => '0755',
    content => template("profiles/elastic/elastic.passwd.erb")
  }->
  nginx::resource::server { 'elasticsearch.vagrant-demo.icinga.com':
    listen_port => $listen_ports['elasticsearch'],
    ssl         => true,
    ssl_port    => $listen_ports['elasticsearch_tls'],
    ssl_cert    => "/var/lib/icinga2/certs/${node_name}.crt",
    ssl_key     => "/var/lib/icinga2/certs/${node_name}.key",
    ssl_trusted_cert => '/var/lib/icinga2/certs/ca.crt',
    ipv6_listen_port => 9200,
    proxy       => 'http://localhost:9200',
    auth_basic  => 'Elasticsearch auth',
    auth_basic_user_file => "$elastic_basic_auth_file",
  }->
  nginx::resource::server { 'kibana.vagrant-demo.icinga.com':
    listen_port => $listen_ports['kibana'],
    ssl         => true,
    ssl_port    => $listen_ports['kibana_tls'],
    ssl_cert    => "/var/lib/icinga2/certs/${node_name}.crt",
    ssl_key     => "/var/lib/icinga2/certs/${node_name}.key",
    ssl_trusted_cert => '/var/lib/icinga2/certs/ca.crt',
    ipv6_listen_port => 5601,
    proxy       => 'http://localhost:5601',
    auth_basic  => 'Kibana auth',
    auth_basic_user_file => "$elastic_basic_auth_file",
  }
}
