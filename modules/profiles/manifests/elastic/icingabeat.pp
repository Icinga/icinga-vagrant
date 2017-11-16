class profiles::elastic::icingabeat (
  $icingabeat_version = '1.1.0',
  $icingabeat_dashboards_checksum = '9c98cf4341cbcf6d4419258ebcc2121c3dede020',
  $kibana_version = '5.3.1',
  $elasticsearch_host = '127.0.0.1',
  $elasticsearch_port = 9200
) {
  include '::profiles::elastic::elasticsearch'

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
  archive { '/tmp/icingabeat-dashboards.zip':
    ensure => present,
    extract => true,
    extract_path => '/tmp',
    source => "https://github.com/Icinga/icingabeat/releases/download/v${icingabeat_version}/icingabeat-dashboards-${icingabeat_version}.zip",
    checksum => "${icingabeat_dashboards_checksum}",
    checksum_type => 'sha1',
    creates => "/tmp/icingabeat-dashboards-${icingabeat_version}",
    cleanup => true,
    require => Package['unzip']
  }
  ->
  exec { 'icingabeat-kibana-dashboards':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "/usr/share/icingabeat/scripts/import_dashboards -dir /tmp/icingabeat-dashboards-${icingabeat_version} -es http://${elasticsearch_host}:${elasticsearch_port}"
  }
  ->
  exec { 'icingabeat-kibana-default-index-pattern':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "curl -XPUT http://${elasticsearch_host}:${elasticsearch_port}/.kibana/config/${kibana_version} -d '{ \"defaultIndex\":\"icingabeat-*\" }'",
    require => Es_Instance_Conn_Validator['elastic-es']
  }
}
