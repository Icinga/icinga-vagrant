class profiles::elastic::filebeat (
  $filebeat_major_version = '7',
  $elasticsearch_host = '127.0.0.1',
  $elasticsearch_port = 9200
){
  class { 'filebeat':
    major_version => $filebeat_major_version,
    package_ensure => latest,
    outputs => {
      'elasticsearch' => {
        'hosts' => [
          "http://${elasticsearch_host}:${elasticsearch_port}"
        ],
#        'index' => 'filebeat'
      }
    },
    logging => {
      'level' => 'debug' #TODO reset after finishing the box
    },
  }
  ->
  exec { 'filebeat-default-index-pattern':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "curl -XPUT http://${elasticsearch_host}:${elasticsearch_port}/index-pattern/filebeat -d '{ \"title\":\"filebeat\", \"timeFieldName\":\"@timestamp\" }'",
    require => Es_Instance_Conn_Validator['elastic-es']
  }

  filebeat::input { 'syslogs':
    paths => [
      '/var/log/messages'
    ],
    doc_type => 'syslog-beat'
  }
  filebeat::input { 'icinga2logs':
    paths => [
      '/var/log/icinga2/icinga2.log'
    ],
    doc_type => 'syslog-beat'
  }
}
