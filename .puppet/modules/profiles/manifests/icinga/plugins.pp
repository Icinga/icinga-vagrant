class profiles::icinga::plugins (
  $packages = [],
){
  # Allow to add more packages
  $real_packages = [ 'nagios-plugins-all' ] + $packages

  package { $real_packages:
    ensure => 'latest',
  }
  ->
  package { [ 'perl-Net-SNMP', 'perl-Digest-MD5', 'perl-Module-Load', 'sysstat' ]:
   ensure => 'latest',
   require => Class['snmp']
  }
  ->
  file { 'check_nwc_health':
    name => '/usr/lib64/nagios/plugins/check_nwc_health',
    owner => root,
    group => root,
    mode => '0755',
    content => template("profiles/icinga/check_nwc_health.erb")
  }
  ->
  file { 'check_mysql_health':
    name => '/usr/lib64/nagios/plugins/check_mysql_health',
    owner => root,
    group => root,
    mode => '0755',
    content => template("profiles/icinga/check_mysql_health.erb")
  }
  ->
  wget::retrieve { 'check_sar_perf.py':
    source      => 'https://raw.githubusercontent.com/dnsmichi/check-sar-perf/master/check_sar_perf.py',
    destination => '/usr/lib64/nagios/plugins/check_sar_perf.py',
    mode 	=> '0755',
    timeout     => 180,
    verbose     => false,
    unless      => "test $(ls -A /usr/lib64/nagios/plugins/check_sar_perf.py 2>/dev/null)",
  }

}

