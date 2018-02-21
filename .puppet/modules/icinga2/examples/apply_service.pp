include icinga2

icinga2::object::service { 'testservice':
  target        => '/etc/icinga2/conf.d/test.conf',
  apply         => true,
  assign        => [ 'host.vars.os == Linux' ],
  ignore        => [ 'host.vars.os == Windows' ],
  display_name  => 'Test Service',
  check_command => 'mysql',
}

icinga2::object::service { 'testservice2':
  target        => '/etc/icinga2/conf.d/test.conf',
  apply         => 'identifier => oid in host.vars.oids',
  apply_target  => 'Host',
  assign        => [ 'host.vars.os == Linux' ],
  ignore        => [ 'host.vars.os == Windows' ],
  display_name  => 'Test Service',
  check_command => 'mysql',
}

icinga2::object::notification { 'testnotification':
  target       => '/etc/icinga2/conf.d/test.conf',
  apply        => true,
  apply_target => 'Service',
  assign       => [ 'host.vars.os == Linux' ],
  ignore       => [ 'host.vars.os == Windows' ],
  import       => ['mail-service-notification'],
  user_groups  => ['icingaadmins']
}

