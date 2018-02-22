$master_cert = 'master.localdomain'
$master_ip   = '192.168.5.16'

class { '::icinga2':
  manage_repo  => true,
  constants    => {
    'NodeName' => 'slave.localdomain',
  },
}

class { '::icinga2::feature::api':
  pki             => 'icinga2',
  ca_host         => $master_ip,
  ticket_salt     => '5a3d695b8aef8f18452fc494593056a4',
  accept_config   => true,
  accept_commands => true,
  endpoints       => {
    'NodeName'       => {},
    "${master_cert}" => {
      'host' => $master_ip,
    }
  },
  zones           => {
    'ZoneName' => {
      'endpoints' => [ 'NodeName' ],
      'parent'    => 'master',
    },
    'master' => {
      'endpoints' => [ $master_cert ],
    },
  }
}
