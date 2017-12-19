# Definition
class profile::icinga2::satellite(
  $zone_name,
  $endpoints,
  $zones,
) {

  class { 'icinga2':
    confd     => false,
    features  => ['checker','mainlog'],
    constants => {
      'ZoneName' => $zone_name,
    },
  }

  # Feature: api
  class { 'icinga2::feature::api':
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
class { 'profile::icinga2::satellite':
  zone_name => 'dmz',
  endpoints => {
    'satellite.example.org' => {},
    'master.example.org' => {
      'host' => '172.16.1.11',
    },
  },
  zones     => {
    'master' => {
      'endpoints' => ['master.example.org'],
    },
    'dmz' => {
      'endpoints' => ['satellite.example.org'],
      'parent'    => 'master',
    },
  },
}
