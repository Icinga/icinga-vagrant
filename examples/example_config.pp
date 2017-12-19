class { '::icinga2':
  manage_repo => true,
  confd       => 'example.d',
}

file { '/etc/icinga2/example.d':
  ensure => directory,
  tag    => 'icinga2::config::file',
}


/*
 * Hosts
 */
::icinga2::object::host { 'generic-host':
  template           => true,
  target             => '/etc/icinga2/example.d/templates.conf',
  check_interval     => '1m',
  retry_interval     => '30s',
  max_check_attempts => 3,
  check_command      => 'hostalive',
}

::icinga2::object::host { 'NodeName':
  target   => '/etc/icinga2/example.d/hosts.conf',
  import   => [ 'generic-host' ],
  address  => '127.0.0.1',
  address6 => '::1',
  vars           => {
    os           => 'Linux',
    http_vhosts  => {
      http       => {
        http_uri => '/',
      },
    },
    disks              => {
      disk             => {},
      'disk /'         => {
        disk_partition => '/',
      },
    },
    notification => {
      mail => {
        groups => [ 'icingaadmins' ],
      },
    },
  },
}

::icinga2::object::hostgroup { 'linux-servers':
  target       => '/etc/icinga2/example.d/groups.conf',
  display_name => 'Linux Servers',
  assign       => [ 'host.vars.os == Linux' ],
}

::icinga2::object::hostgroup { 'windows-servers':
  target       => '/etc/icinga2/example.d/groups.conf',
  display_name => 'Windows Servers',
  assign       => [ 'host.vars.os == Windows' ],
}

/*
 * Services
 */
::icinga2::object::service { 'generic-service':
  template           => true,
  target             => '/etc/icinga2/example.d/templates.conf',
  check_interval     => '1m',
  retry_interval     => '30s',
  max_check_attempts => 5,
}

::icinga2::object::service { 'ping4':
  target        => '/etc/icinga2/example.d/services.conf',
  apply         => true,
  import        => [ 'generic-service' ],
  check_command => 'ping4',
  assign        => [ 'host.address' ],
}

::icinga2::object::service { 'ping6':
  target        => '/etc/icinga2/example.d/services.conf',
  apply         => true,
  import        => [ 'generic-service' ],
  check_command => 'ping6',
  assign        => [ 'host.address6' ],
}

::icinga2::object::service { 'ssh':
  target        => '/etc/icinga2/example.d/services.conf',
  apply         => true,
  import        => [ 'generic-service' ],
  check_command => 'ssh',
  assign        => [ '(host.address || host.address6) && host.vars.os == Linux' ],
}

::icinga2::object::service { 'http':
  target        => '/etc/icinga2/example.d/services.conf',
  apply         => 'vhost => config in host.vars.http_vhosts',
  import        => [ 'generic-service' ],
  check_command => 'http',
  vars          => 'vars + config',
}

::icinga2::object::service { 'disk':
  target        => '/etc/icinga2/example.d/services.conf',
  apply         => 'fs => config in host.vars.disks',
  import        => [ 'generic-service' ],
  check_command => 'disk',
  vars          => 'vars + config',
}

::icinga2::object::service { 'icinga':
  target        => '/etc/icinga2/example.d/services.conf',
  apply         => true,
  import        => [ 'generic-service' ],
  check_command => 'icinga',
  assign        => [ 'host.name == NodeName' ],
}

::icinga2::object::service { 'load':
  target            => '/etc/icinga2/example.d/services.conf',
  apply             => true,
  import            => [ 'generic-service' ],
  check_command     => 'load',
  vars              => {
    backup_downtime => '02:00-03:00',
  },
  assign        => [ 'host.name == NodeName' ],
}

::icinga2::object::service { 'procs':
  target        => '/etc/icinga2/example.d/services.conf',
  apply         => true,
  import        => [ 'generic-service' ],
  check_command => 'procs',
  assign        => [ 'host.name == NodeName' ],
}

::icinga2::object::service { 'swap':
  target        => '/etc/icinga2/example.d/services.conf',
  apply         => true,
  import        => [ 'generic-service' ],
  check_command => 'swap',
  assign        => [ 'host.name == NodeName' ],
}

::icinga2::object::servicegroup { 'ping':
  target       => '/etc/icinga2/example.d/groups.conf',
  display_name => 'Ping Checks',
  assign       => [ 'match(ping*, service.check_command)' ],
}

::icinga2::object::servicegroup { 'http':
  target       => '/etc/icinga2/example.d/groups.conf',
  display_name => 'HTTP Checks',
  assign       => [ 'match(http*, service.check_command)' ],
}

::icinga2::object::servicegroup { 'disk':
  target       => '/etc/icinga2/example.d/groups.conf',
  display_name => 'Disk Checks',
  assign       => [ 'match(disk*, service.check_command)' ],
}


/*
 * Users
 */
::icinga2::object::user { 'generic-user':
  template => true,
  target   => '/etc/icinga2/example.d/templates.conf',
}

::icinga2::object::service { 'users':
  target        => '/etc/icinga2/example.d/services.conf',
  apply         => true,
  import        => [ 'generic-service' ],
  check_command => 'users',
  assign        => [ 'host.name == NodeName' ],
}

::icinga2::object::scheduleddowntime { 'backup-downtime':
  target       => '/etc/icinga2/example.d/downtimes.conf',
  apply        => true,
  apply_target => 'Service',
  author       => 'icingaadmin',
  comment      => 'Scheduled downtime for backup',
  ranges   => {
    monday    => 'service.vars.backup_downtime',
    tuesday   => 'service.vars.backup_downtime',
    wednesday => 'service.vars.backup_downtime',
    thursday  => 'service.vars.backup_downtime',
    friday    => 'service.vars.backup_downtime',
    saturday  => 'service.vars.backup_downtime',
    sunday    => 'service.vars.backup_downtime',
  },
  assign => [ 'service.vars.backup_downtime' ],
}

::icinga2::object::user { 'icingaadmin':
  target       => '/etc/icinga2/example.d/users.conf',
  import       => [ 'generic-user' ],
  display_name => 'Icinga 2 Admin',
  groups       => [ 'icingaadmins'],
  email        => 'icinga@localhost',
}

::icinga2::object::usergroup { 'icingaadmins':
  target       => '/etc/icinga2/example.d/users.conf',
  display_name => 'Icinga 2 Admin Group',
}


/*
 * Notifications
 */
::icinga2::object::notificationcommand { 'mail-host-notification':
  target  => '/etc/icinga2/example.d/commands.conf',
  command => [ 'SysconfDir + /icinga2/scripts/mail-host-notification.sh' ],
  env     => {
    'NOTIFICATIONTYPE'       => '$notification.type$',
    'HOSTNAME'               => '$host.name$',
    'HOSTDISPLAYNAME'        => '$host.display_name$',
    'HOSTADDRESS'            => '$address$',
    'HOSTSTATE'              => '$host.state$',
    'LONGDATETIME'           => '$icinga.long_date_time$',
    'HOSTOUTPUT'             => '$host.output$',
    'NOTIFICATIONAUTHORNAME' => '$notification.author$',
    'NOTIFICATIONCOMMENT'    => '$notification.comment$',
    'HOSTDISPLAYNAME'        => '$host.display_name$',
    'USEREMAIL'              => '$user.email$',
  },
}

::icinga2::object::notificationcommand { 'mail-service-notification':
  target  => '/etc/icinga2/example.d/commands.conf',
  command => [ 'SysconfDir + /icinga2/scripts/mail-service-notification.sh' ],
  env     => {
    'NOTIFICATIONTYPE'       => '$notification.type$',
    'SERVICENAME'            => '$service.name$',
    'HOSTNAME'               => '$host.name$',
    'HOSTDISPLAYNAME'        => '$host.display_name$',
    'HOSTADDRESS'            => '$address$',
    'SERVICESTATE'           => '$service.state$',
    'LONGDATETIME'           => '$icinga.long_date_time$',
    'SERVICEOUTPUT'          => '$service.output$',
    'NOTIFICATIONAUTHORNAME' => '$notification.author$',
    'NOTIFICATIONCOMMENT'    => '$notification.comment$',
    'HOSTDISPLAYNAME'        => '$host.display_name$',
    'SERVICEDISPLAYNAME'     => '$service.display_name$',
    'USEREMAIL'              => '$user.email$',
  },
}

::icinga2::object::notification { 'mail-host-notification':
  target   => '/etc/icinga2/example.d/templates.conf',
  template => true,
  command  => 'mail-host-notification',
  states   => [ 'Up', 'Down' ],
  types    => [ 'Problem', 'Acknowledgement', 'Recovery', 'Custom', 'FlappingStart', 'FlappingEnd', 'DowntimeStart', 'DowntimeEnd', 'DowntimeRemoved' ],
  period   => '24x7',
}

::icinga2::object::notification { 'mail-service-notification':
  target   => '/etc/icinga2/example.d/templates.conf',
  template => true,
  command  => 'mail-service-notification',
  states   => [ 'OK', 'Warning', 'Critical', 'Unknown' ],
  types    => [ 'Problem', 'Acknowledgement', 'Recovery', 'Custom', 'FlappingStart', 'FlappingEnd', 'DowntimeStart', 'DowntimeEnd', 'DowntimeRemoved' ],
  period   => '24x7',
}

::icinga2::object::notification { 'mail-host-icingaadmin':
  target            => '/etc/icinga2/example.d/notifications.conf',
  notification_name => 'mail-icingaadmin',
  apply             => true,
  apply_target      => 'Host',
  import            => [ 'mail-host-notification' ],
  user_groups       => 'host.vars.notification.mail.groups',
  users             => 'host.vars.notification.mail.users',
  assign            => [ 'host.vars.notification.mail' ],
}

::icinga2::object::notification { 'mail-service-icingaadmin':
  target            => '/etc/icinga2/example.d/notifications.conf',
  notification_name => 'mail-icingaadmin',
  apply             => true,
  apply_target      => 'Service',
  import            => [ 'mail-service-notification' ],
  user_groups       => 'host.vars.notification.mail.groups',
  users             => 'host.vars.notification.mail.users',
  assign            => [ 'host.vars.notification.mail' ],
}


/*
 * Timeperiods
 */
::icinga2::object::timeperiod { '24x7':
  target       => '/etc/icinga2/example.d/timeperiods.conf',
  import       => [ 'legacy-timeperiod' ],
  display_name => 'Icinga 2 24x7 TimePeriod',
  ranges       => {
    monday    => '00:00-24:00',
    tuesday   => '00:00-24:00',
    wednesday => '00:00-24:00',
    thursday  => '00:00-24:00',
    friday    => '00:00-24:00',
    saturday  => '00:00-24:00',
    sunday    => '00:00-24:00',
  },
}

::icinga2::object::timeperiod { '9to5':
  target       => '/etc/icinga2/example.d/timeperiods.conf',
  import       => [ 'legacy-timeperiod' ],
  display_name => 'Icinga 2 9to5 TimePeriod',
  ranges       => {
    monday    => '09:00-17:00',
    tuesday   => '09:00-17:00',
    wednesday => '09:00-17:00',
    thursday  => '09:00-17:00',
    friday    => '09:00-17:00',
    saturday  => '09:00-17:00',
    sunday    => '09:00-17:00',
  },
}

::icinga2::object::timeperiod { 'never':
  target       => '/etc/icinga2/example.d/timeperiods.conf',
  import       => [ 'legacy-timeperiod' ],
  display_name => 'Icinga 2 never TimePeriod',
  ranges       => {},
}
