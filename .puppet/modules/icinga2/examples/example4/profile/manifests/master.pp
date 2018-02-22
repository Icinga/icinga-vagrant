class profile::icinga2::master {

  contain ::profile::icinga2::plugins

  class { '::icinga2':
    manage_repo    => true,
    purge_features => false,
    confd          => false,
    constants      => {
      'ZoneName' => 'master',
    }
  }

  # Feature: api
  class { '::icinga2::feature::api':
    accept_commands => true,
    accept_config   => true,
  }

  icinga2::object::zone { ['global-templates', 'windows-commands', 'linux-commands']:
    global => true,
    order  => '47',
  }

  # Zone directories
  file { ['/etc/icinga2/zones.d/master',
    '/etc/icinga2/zones.d/windows-commands',
    '/etc/icinga2/zones.d/linux-commands',
    '/etc/icinga2/zones.d/global-templates']:
    ensure => directory,
    owner  => 'icinga',
    group  => 'icinga',
    mode   => '0750',
    tag    => 'icinga2::config::file',
  }

  File <<| tag == "icinga2::slave::zone" |>>

  # Static Icinga 2 objects
  ::icinga2::object::service { 'ping4':
    import        => ['generic-service'],
    apply         => true,
    check_command => 'ping',
    assign        => ['host.address'],
    target        => '/etc/icinga2/zones.d/global-templates/services.conf',
  }

  ::icinga2::object::service { 'cluster zone':
    import        => ['generic-service'],
    apply         => true,
    check_command => 'cluster-zone',
    assign        => ['host.vars.os == Linux || host.vars.os == Windows'],
    ignore        => ['host.vars.noagent'],
    target        => '/etc/icinga2/zones.d/global-templates/services.conf',
  }

  ::icinga2::object::service { 'linux_load':
    import           => ['generic-service'],
    service_name     => 'load',
    apply            => true,
    check_command    => 'load',
    command_endpoint => 'host.name',
    assign           => ['host.vars.os == Linux'],
    ignore           => ['host.vars.noagent'],
    target           => '/etc/icinga2/zones.d/global-templates/services.conf',
  }

  ::icinga2::object::service { 'linux_disks':
    import           => ['generic-service'],
    apply            => 'disk_name => config in host.vars.disks',
    check_command    => 'disk',
    command_endpoint => 'host.name',
    vars             => 'vars + config',
    assign           => ['host.vars.os == Linux'],
    ignore           => ['host.vars.noagent'],
    target           => '/etc/icinga2/zones.d/global-templates/services.conf',
  }

  # Collect objects
  ::Icinga2::Object::Endpoint <<| |>>
  ::Icinga2::Object::Zone <<| |>>
  ::Icinga2::Object::Host <<| |>>

  # Static config files
  file { '/etc/icinga2/zones.d/global-templates/templates.conf':
    ensure => file,
    owner  => 'icinga',
    group  => 'icinga',
    mode   => '0640',
    source => 'puppet:///modules/profile/icinga2/templates.conf',
  }
}
