class profile::icinga::server {

    class { '::icinga2': }

    icinga2::object::zone { 'global-templates':
        global => true,
    }

    file { 'icinga2_global_templates':
        path    => '/etc/icinga2/zones.d/global-templates',
        ensure  => directory,
        purge   => true,
        recurse => true,
    }->
    File <<| ensure != 'directory' and tag == 'icinga2::scripts::file' |>> { }

    # Collect all hosts into their respective directories.
    file { 'icinga2_masterzone':
        path    => '/etc/icinga2/zones.d/master',
        ensure  => directory,
        purge   => true,
        recurse => true,
    }->
    file { 'icinga2_hosts':
        path    => '/etc/icinga2/conf.d/hosts',
        ensure  => directory,
        purge   => true,
        recurse => true,
    }->
    Icinga2::Object::Host <<| |>> { }

    # Export master zone and endpoint for all agents to collect
    @@icinga2::object::zone { 'master':
        endpoints => [ "$::fqdn", ],
    }
    @@icinga2::object::endpoint { "$::fqdn":
        host => "$::ipaddress_eth0",
    }

    # Collect and realize all agent zones and endpoints
    Icinga2::Object::Endpoint <<| |>> { }
    Icinga2::Object::Zone <<| |>> { }

    # Collect services and notifications exported on agent nodes
    # (and not created by the Apply Rules included below)
    file { 'icinga2_services':
        path    => '/etc/icinga2/conf.d/services',
        ensure  => directory,
        purge   => true,
        recurse => true,
    }->
    Icinga2::Object::Service <<| |>> { }

    file { 'icinga2_notifications':
        path    => '/etc/icinga2/conf.d/notifications',
        ensure  => directory,
        purge   => true,
        recurse => true,
    }->
    Icinga2::Object::Notification <<| |>> { }

    # Collect check and notification commands that are not created by Apply
    file { 'icinga2_commands':
        path    => '/etc/icinga2/conf.d/commands',
        ensure  => directory,
        purge   => true,
        recurse => true,
    }->
    Icinga2::Object::Checkcommand <<| |>> { }->
    Icinga2::Object::NotificationCommand <<| |>> { }

    # Define apply rules that
    contain profile::icinga::applyrules

    # Note: these manifests are not included in this example
    contain profile::icinga::hostgroups
    contain profile::icinga::users
    contain profile::icinga::timeperiods
    contain profile::icinga::notifications
    contain profile::icinga::checkcommands
}
