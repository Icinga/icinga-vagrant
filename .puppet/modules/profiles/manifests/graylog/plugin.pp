class profiles::graylog::plugin {

  exec { 'download-check-graylog2-stream':
    command => '/usr/bin/wget -O /var/tmp/check-graylog2-stream.tar.gz https://github.com/graylog-labs/check-graylog2-stream/releases/download/1.4/check-graylog2-stream.linux_x86.tar.gz',
    creates => '/var/tmp/check-graylog2-stream.tar.gz',
  } ->
  exec { 'extract-check-graylog2-stream':
    command => '/usr/bin/tar -C /usr/lib64/nagios/plugins -xzf /var/tmp/check-graylog2-stream.tar.gz',
    creates => '/usr/lib64/nagios/plugins/check-graylog2-stream',
  } ->
  file { '/usr/lib64/nagios/plugins/check-graylog2-stream':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
  }
}
