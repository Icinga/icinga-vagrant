# Definition
class profile::icinga2::master(
  $endpoints,
  $zones,
) {

  class { 'icinga2':
    confd     => false,
    features  => ['checker','mainlog','notification','statusdata','compatlog','command'],
    constants => {
      'ZoneName' => 'master',
    },
  }

  class { 'icinga2::feature::api':
    accept_commands => true,
    endpoints       => $endpoints,
    zones           => $zones,
  }

  icinga2::object::zone { 'global-templates':
    global => true,
  }
}


# Declaration
class { 'profile::icinga2::master':
  endpoints => {
    'master.example.org'    => {},
    'satellite.example.org' => {
      'host' => '172.16.2.11',
    },
  },
  zones     => {
    'master' => {
      'endpoints' => ['master.example.org'],
    },
    'dmz'    => {
      'endpoints' => ['satellite.example.org'],
      'parent'    => 'master',
    },
  },
}
