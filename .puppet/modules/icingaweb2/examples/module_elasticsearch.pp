include icingaweb2

class { 'icingaweb2::module::elasticsearch':
  git_revision => 'v0.9.0',
  instances    => {
    'elastic'  => {
      uri      => 'http://localhost:9200',
      user     => 'foo',
      password => 'bar',
    }
  },
  eventtypes   => {
    'filebeat' => {
      instance => 'elastic',
      index    => 'filebeat-*',
      filter   => 'beat.hostname={host.name}',
      fields   => 'input_type, source, message',
    }
  }
}