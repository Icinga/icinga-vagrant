class profile::icinga::agent {

    # By default, the icinga module only installs monitoring-plugins-base
    ensure_packages([
        'monitoring-plugins-standard',
        'nagios-plugins-contrib',
        'libmonitoring-plugin-perl',
    ], {
        install_options => ['--no-install-recommends'],
    })

    # Options valid for all agents, thus defined inside the manifest
    class { '::icinga2':
        manage_repo => true,
        confd       => false,
        features    => [ 'mainlog' ],
    }

    # Leave this here or put it in a yaml file common
    # to icinga agent nodes only.
    class { '::icinga2::feature::api':
        pki             => 'puppet',
        accept_config   => true,
        accept_commands => true,
        endpoints       => {},
        zones           => {},
    }

    icinga2::object::zone { 'global-templates':
        global => true,
    }

    # All nodes export resources for icinga monitoring
    # The vars (set in the various nodes hiera files) are used to Apply Services
    # to these hosts. (See profile::icinga::server)
    @@::icinga2::object::host { $::fqdn:
        display_name            => $::fqdn,
        address                 => $::ipaddress_eth0,
        check_command           => 'hostalive',
        vars                    => hiera_hash('icinga_vars', {}),
        target                  => "/etc/icinga2/zones.d/master/${::fqdn}.conf"
    }

    # Create virtual resources for this agent node
    @@::icinga2::object::endpoint { "$::fqdn":
        host => "$::ipaddress_eth0",
    }

    @@::icinga2::object::zone { "$::fqdn":
        endpoints => [ "$::fqdn", ],
        parent    => 'master',
    }

    # Collect and realize info about self and master, but no other nodes.
    Icinga2::Object::Endpoint <<| title == $::fqdn or title == 'master.sub.domain.tld' |>> { }
    Icinga2::Object::Zone <<| title == $::fqdn or title == 'master' |>> { }
}
