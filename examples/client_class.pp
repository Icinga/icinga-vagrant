class { 'snmp::client':
  snmp_config => [
    'defVersion 2c',
    'defCommunity public',
    'mibdirs +/usr/local/share/snmp/mibs',
  ],
}
