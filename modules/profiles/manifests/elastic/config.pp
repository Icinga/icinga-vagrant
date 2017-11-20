class profiles::elastic::config (

) {

  file { 'kibana-setup':
    name   => '/usr/local/bin/kibana-setup',
    owner  => root,
    group  => root,
    mode   => '0755',
    source => '/vagrant/files/usr/local/bin/kibana-setup',
  }
  
  -> exec { 'finish-kibana-setup':
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => '/usr/local/bin/kibana-setup',
    timeout => 3600
  }
}
