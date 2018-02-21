# Notice: this code contains Puppet 4 syntax! It doesn't run on Puppet 3.
class profile::icinga2::slave(
  $slave_zone,
  $parent_endpoints,
  $parent_zone = 'master',
  $slave_ip = $::ipaddress,
) {

  contain ::profile::icinga2::plugins

  validate_array($parent_endpoints)

  class { '::icinga2':
    manage_repo => true,
    confd       => false,
    features  => ['checker','mainlog'],
    constants   => {
      'ZoneName' => $slave_zone,
    }
  }

  # Feature: api
  class { '::icinga2::feature::api':
    accept_config   => true,
    accept_commands => true,
    zones           => {
      'ZoneName' => {
        'endpoints' => [ 'NodeName' ],
        'parent'    => $parent_zone,
      }
    }
  }

  ::icinga2::object::endpoint { $parent_endpoints: }

  ::icinga2::object::zone { $parent_zone:
    endpoints => $parent_endpoints,
  }

  ::icinga2::object::zone { ['global-templates', 'windows-commands', 'linux-commands']:
    global => true,
    order  => '47',
  }

  @@::icinga2::object::endpoint { $::fqdn:
    host => $slave_ip,
    tag  => "icinga2::parent::${parent_zone}",
  }

  @@::icinga2::object::zone { $slave_zone:
    endpoints => [ $::fqdn ],
    parent    => $parent_zone,
    tag       => "icinga2::parent::${parent_zone}",
  }

  @@file { "/etc/icinga2/zones.d/${slave_zone}":
    ensure => directory,
    owner  => 'icinga',
    group  => 'icinga',
    mode   => '0750',
    tag    => 'icinga2::slave::zone',
  }

  ::Icinga2::Object::Endpoint <<| tag == "icinga2::parent::${slave_zone}" |>>
  ::Icinga2::Object::Zone <<| tag == "icinga2::parent::${slave_zone}" |>>

  @@::icinga2::object::host { $::fqdn:
    # Puppet 4 syntax
    * => deep_merge({
      display_name => $::hostname,
      address      => $slave_ip,
      target       => "/etc/icinga2/zones.d/${slave_zone}/${::hostname}.conf",
      zone         => $parent_zone,
      vars         => {
        'cluster_zone' => $slave_zone,
      },
    }, hiera_hash(icinga2::host)),
  }
}
