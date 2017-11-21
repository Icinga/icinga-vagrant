####################################
# Global configuration
####################################

$hostonlyip                   = '192.168.33.7'
$hostonlyfqdn                 = 'icinga2x-elastic.vagrant.demo.icinga.com'
$kibanaversion                = '5.3.1'
$icingabeatversion            = '1.1.0'
$icingabeatdashboardschecksum = '9c98cf4341cbcf6d4419258ebcc2121c3dede020'
# keep this in sync with the icingabeat dashboard ids!
# http://192.168.33.7:5601/app/kibana#/dashboard/720f2f20-0979-11e7-a4dd-e96fa284b426
$kibanadefaultappid           = 'dashboard/720f2f20-0979-11e7-a4dd-e96fa284b426'

####################################
# Setup
####################################

class { '::profiles::base::system': }
-> class { '::profiles::base::mysql': }
-> class { '::profiles::base::apache': }
-> class { '::profiles::base::java': }
-> class { '::profiles::icinga::icinga2':
  features => [ 'elasticsearch' ]
}
-> class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostonlyip,
  icingaweb2_fqdn      => $hostonlyfqdn,
  modules              => {
    'elasticsearch' => {}
  }
}
-> class { '::profiles::elastic::elasticsearch':
  repo_version => '5.x',
}
-> class { '::profiles::elastic::logstash': }
-> class { '::profiles::elastic::kibana':
  kibana_revision       => "${kibanaversion}-1",
  kibana_host           => '127.0.0.1',
  kibana_port           => 5601,
  kibana_default_app_id => $kibanadefaultappid
}
-> class { '::profiles::elastic::httpproxy':
  listen_ip => $hostonlyip
}
-> class { '::profiles::elastic::filebeat':
}
-> class { '::profiles::elastic::icingabeat':
  icingabeat_version             => $icingabeatversion,
  icingabeat_dashboards_checksum => $icingabeatdashboardschecksum,
  kibana_version                 => $kibanaversion
}
