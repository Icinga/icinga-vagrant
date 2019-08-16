class profiles::elastic::icingabeat (
  $icingabeat_version = '7.4.2',
  $kibana_version = '7.4.2',
  $elasticsearch_host = '127.0.0.1',
  $elasticsearch_port = 9200,
  $kibana_host = '127.0.0.1',
  $kibana_port = 5601
) {
  yum::install { 'icingabeat':
    ensure => present,
    source => "https://github.com/Icinga/icingabeat/releases/download/v${icingabeat_version}/icingabeat-${icingabeat_version}-x86_64.rpm"
  }
  ->
  file { '/etc/icingabeat/icingabeat.yml':
    owner  => root,
    group  => root,
    content => template('profiles/elastic/icingabeat.yml.erb')
  }
  ->
  service { 'icingabeat':
    ensure => running
  }
  ->
  exec { 'http-conn-validator-kibana':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "/usr/local/bin/http-conn-validator \"http://$kibana_host:$kibana_port\"",
    timeout => 1800
  }
  ->
  exec { 'icingabeat-setup':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => 'icingabeat setup',
    require => Yum::Install['icingabeat']
  }
  ->
  exec { 'icingabeat-kibana-default-index-pattern':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "curl -XPUT http://${elasticsearch_host}:${elasticsearch_port}/.kibana/config/${kibana_version} -d '{ \"defaultIndex\":\"icingabeat-*\" }'",
    require => Es_Instance_Conn_Validator['elastic-es']
  }
}
