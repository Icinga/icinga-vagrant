class profiles::elastic::filebeat (
  $elasticsearch_host = '127.0.0.1',
  $elasticsearch_port = 9200
){

  include '::profiles::icinga2::install'
  include '::profiles::elastic::elasticsearch'

  class { 'filebeat':
    outputs => {
      'elasticsearch' => {
        'hosts' => [
          'http://${elasticsearch_host}:${elasticsearch_port}'
        ],
        'index' => 'filebeat'
      }
    },
    logging => {
      'level' => 'debug' #TODO reset after finishing the box
    }
  }

  exec { 'filebeat-default-index-pattern':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "curl -XPUT http://${elasticsearch_host}:${elasticsearch_port}/index-pattern/filebeat -d '{ \"title\":\"filebeat\", \"timeFieldName\":\"@timestamp\" }'",
    require => Es_Instance_Conn_Validator['elastic-es']
  }

  filebeat::prospector { 'syslogs':
    paths => [
      '/var/log/messages'
    ],
    doc_type => 'syslog-beat'
  }
  filebeat::prospector { 'icinga2logs':
    paths => [
      '/var/log/icinga2/icinga2.log'
    ],
    doc_type => 'syslog-beat'
  }

}
