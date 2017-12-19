include icinga2

icinga2::object::hostgroup { 'monitoring-hosts':
  display_name => 'Linux Servers',
  groups       => [ 'linux-servers' ],
  target       => '/etc/icinga2/conf.d/groups2.conf',
  assign       => [ 'host.name == NodeName' ],
}
