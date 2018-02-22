# Definition
class profile::icinga2::agent(
  $endpoints,
  $zones,
) {

  class { 'icinga2':
    confd     => false,
    features  => ['mainlog'],
  }

  # Feature: api
  class { 'icinga2::feature::api':
    pki             => 'none',
    accept_config   => true,
    accept_commands => true,
    endpoints       => $endpoints,
    zones           => $zones,
  }

  icinga2::object::zone { 'global-templates':
    global => true,
  }
}


# Declaration
class { 'profile::icinga2::agent':
  endpoints  => {
    'NodeName' => {},
    'satellite.example.org' => {
      'host' => '172.16.2.11',
    },
  },
  zones     => {
    'ZoneName' => {
      'endpoints' => ['NodeName'],
      'parent' => 'dmz',
    },
    'dmz' => {
      'endpoints' => ['satellite.example.org'],
    },
  },
}
