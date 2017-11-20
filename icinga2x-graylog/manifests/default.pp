####################################
# Global configuration
####################################

$hostOnlyIP = '192.168.33.6'
$hostOnlyFQDN = 'icinga2x-graylog.vagrant.demo.icinga.com'


####################################
# Setup
####################################

class { '::profiles::base::system': }
->
class { '::profiles::base::mysql': }
->
class { '::profiles::base::apache': }
->
class { '::profiles::base::java': }
->
class { '::profiles::icinga::icinga2':
  features => [ "gelf" ]
}
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN,
  modules => {}
}
->
class { '::profiles::graylog::elasticsearch':
  repo_version => '5.x',
}
->
class { '::profiles::graylog::mongodb': }
->
class { '::profiles::graylog::server':
  repo_version => '2.3',
  listen_ip => $hostOnlyIP
}
->
class { '::profiles::graylog::plugin': }

# TODO: Move this somewhere else
file { '/etc/icinga2/demo/graylog2-demo.conf':
  owner  => icinga,
  group  => icinga,
  content   => template("icinga2/graylog2-demo.conf.erb"),
  require   => [ Package['icinga2'], File['/etc/icinga2/demo'] ],
  notify    => Service['icinga2']
}



