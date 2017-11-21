class profiles::elastic::filebeat (
  $logstash_host = '127.0.0.1',
  $logstash_port = 9200
){
  class { 'filebeat':
    outputs => {
      'logstash' => {
        'hosts' => [ "http://${logstash_host}:${logstash_port}"
        ],
      }
    },
    logging => {
      'level' => 'debug' #TODO reset after finishing the box
    }
  }

  filebeat::prospector { 'syslogs':
    paths    => [
      '/var/log/messages'
    ],
    doc_type => 'syslog'
  }
  filebeat::prospector { 'icinga2logs':
    paths    => [
      '/var/log/icinga2/icinga2.log'
    ],
    doc_type => 'icinga2logs'
  }
}
