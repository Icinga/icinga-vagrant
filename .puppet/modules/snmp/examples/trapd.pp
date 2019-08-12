class { 'snmp':
  ro_community        => 'SeCrEt',
  service_ensure      => 'stopped',
  trap_service_ensure => 'running',
  trap_service_enable => true,
  trap_handlers       => [
    'default /usr/bin/perl /usr/bin/traptoemail me@somewhere.local',
    'IF-MIB::linkDown /home/nba/bin/traps down',
  ],
  trap_forwards       => [ 'default udp:55.55.55.55:162' ],
}
