class { 'snmp':
  ro_community        => 'SeCrEt',
  trap_service_ensure => 'running',
  trap_service_enable => true,
  trap_handlers       => [
    'default /usr/bin/perl /usr/bin/traptoemail me@somewhere.local',
    'IF-MIB::linkDown /home/nba/bin/traps down',
  ],
  trap_forwards       => [ 'default udp:2.3.4.5:162' ],
}
