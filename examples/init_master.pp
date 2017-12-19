class { '::icinga2':
  manage_repo => true,
  constants   => {
    'NodeName'   => 'master.localdomain',
    'ZoneName'   => 'master',
    'TicketSalt' => '5a3d695b8aef8f18452fc494593056a4',
  }
}

class { '::icinga2::feature::api':
  pki             => 'none',
  zones           => {
    'master' => {
      'endpoints' => [ 'NodeName' ],
    },
  }
}

class { '::icinga2::pki::ca': }

