class profiles::iot::mqtt (
  $listen_ip,
  $listen_port
) {
  # requires base, epel
  package { 'mosquitto':
    ensure => latest
  }
  ->
  service { 'mosquitto':
    provider => 'systemd',
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

  vcsrepo { '/usr/share/mqttwarn':
    ensure   => 'present',
    path     => '/usr/share/mqttwarn',
    provider => 'git',
    revision => 'master',
    source   => 'https://github.com/jpmens/mqttwarn.git',
    force    => true,
    require  => Package['git']
  }->
  #package { [ 'python2-pip',
 # 	    'python-devel',
 # 	    'gcc' ]:
 #   ensure => 'installed',
 # }
 # ->
  package { [ 'paho-mqtt', 'requests' ]:
    provider => 'pip',
    ensure => latest,
  }


}
