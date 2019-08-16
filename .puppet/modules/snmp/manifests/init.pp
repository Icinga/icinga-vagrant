# @summary
#   Manage the Net-SNMP and Net-SNMP trap daemon package, service, and
#   configuration.
#
# @example
#   class { 'snmp':
#     com2sec       => [ 'notConfigUser default PassW0rd' ],
#     manage_client => true,
#   }
#
#   # Only configure and run the snmptrap daemon:
#   class { 'snmp':
#     ro_community        => 'SeCrEt',
#     service_ensure      => 'stopped',
#     trap_service_ensure => 'running',
#     trap_handlers       => [
#       'default /usr/bin/perl /usr/bin/traptoemail me@somewhere.local',
#       'IF-MIB::linkDown /home/nba/bin/traps down',
#     ],
#   }
#
# @param agentaddress
#   An array of addresses, on which snmpd will listen for queries.
#
# @param snmptrapdaddr
#   An array of addresses, on which snmptrapd will listen to receive incoming
#   SNMP notifications.
#
# @param ro_community
#   Read-only (RO) community string or array for agent and snmptrap daemon.
#
# @param ro_community6
#   Read-only (RO) community string or array for IPv6 agent.
#
# @param rw_community
#   Read-write (RW) community string or array agent.
#
# @param rw_community6
#   Read-write (RW) community string or array for IPv6 agent.
#
# @param ro_network
#   Network that is allowed to RO query the daemon.  Can be string or array.
#
# @param ro_network6
#   Network that is allowed to RO query the daemon via IPv6.  Can be string or array.
#
# @param rw_network
#   Network that is allowed to RW query the daemon.  Can be string or array.
#
# @param rw_network6
#   Network that is allowed to RW query the daemon via IPv6.  Can be string or array.
#
# @param contact
#   Responsible person for the SNMP system.
#
# @param location
#   Location of the SNMP system.
#
# @param sysname
#   Name of the system (hostname).
#
# @param services
#   For a host system, a good value is 72 (application + end-to-end layers).
#
# @param com2sec
#   An array of VACM com2sec mappings.
#   Must provide SECNAME, SOURCE and COMMUNITY.
#   See http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAL for details.
#
# @param com2sec6
#   An array of VACM com2sec6 mappings.
#   Must provide SECNAME, SOURCE and COMMUNITY.
#   See http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAL for details.
#
# @param groups
#   An array of VACM group mappings.
#   Must provide GROUP, <v1|v2c|usm|tsm|ksm>, SECNAME.
#   See http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAL for details.
#
# @param views
#   An array of views that are available to query.
#   Must provide VNAME, TYPE, OID, and [MASK].
#   See http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAL for details.
#
# @param accesses
#   An array of access controls that are available to query.
#   Must provide GROUP, CONTEXT, <any|v1|v2c|usm|tsm|ksm>, LEVEL, PREFX, READ, WRITE, and NOTIFY.
#   See http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAL for details.
#
# @param dlmod
#   Array of dlmod lines to add to the snmpd.conf file.
#   Must provide NAME and PATH (ex. "cmaX /usr/lib64/libcmaX64.so").
#   See http://www.net-snmp.org/docs/man/snmpd.conf.html#lbBD for details.
#
# @param extends
#   Array of extend lines to add to the snmpd.conf file.
#   Must provide NAME, PROG and ARG.
#   See http://www.net-snmp.org/docs/man/snmpd.conf.html#lbBA for details.
#
# @param snmpd_config
#   Safety valve.  Array of lines to add to the snmpd.conf file.
#   See http://www.net-snmp.org/docs/man/snmpd.conf.html for all options.
#
# @param disable_authorization
#   Disable all access control checks.
#
# @param do_not_log_traps
#   Disable the logging of notifications altogether.
#
# @param do_not_log_tcpwrappers
#   Disable the logging of tcpwrappers messages, e.g. "Connection from UDP: " messages in syslog.
#
# @param trap_handlers
#   An array of programs to invoke on receipt of traps.
#   Must provide OID and PROGRAM (ex. "IF-MIB::linkDown /bin/traps down").
#   See http://www.net-snmp.org/docs/man/snmptrapd.conf.html#lbAI for details.
#
# @param trap_forwards
#   An array of destinations to send to on receipt of traps.
#   Must provide OID and DESTINATION (ex. "IF-MIB::linkUp udp:1.2.3.5:162").
#   See http://www.net-snmp.org/docs/man/snmptrapd.conf.html#lbAI for details.
#
# @param snmptrapd_config
#   Safety valve.  Array of lines to add to the snmptrapd.conf file.
#   See http://www.net-snmp.org/docs/man/snmptrapd.conf.html for all options.
#
# @param manage_client
#   Whether to install the Net-SNMP client package.
#
# @param snmp_config
#   Safety valve.  Array of lines to add to the client's global snmp.conf file.
#   See http://www.net-snmp.org/docs/man/snmp.conf.html for all options.
#
# @param ensure
#   Ensure if present or absent.
#
# @param autoupgrade
#   Upgrade package automatically, if there is a newer version.
#
# @param package_name
#   Name of the package. Only set this if your platform is not supported or you know what you are doing.
#
# @param snmptrapd_package_name
#   Name of the package provinding snmptrapd. Only set this if your platform is not supported or you know what you are doing.
#
# @param snmpd_options
#   Commandline options passed to snmpd via init script.
#
# @param sysconfig
#   Path to sysconfig file for snmpd.
#
# @param trap_sysconfig
#   Path to sysconfig file for snmptrapd.
#
# @param trap_service_config
#   Path to snmptrapd.conf.
#
# @param service_config
#   Path to snmpd.conf.
#
# @param service_config_perms
#   Set permissions for the service configuration file.
#
# @param service_config_dir_path
#   Path to services configuration directory.
#
# @param service_config_dir_owner
#   Owner for the service configuration directory.
#
# @param service_config_dir_group
#   Set group ownership for the service configuration directory.
#
# @param service_config_dir_perms
#   Mode of the service configuration directory.
#
# @param service_ensure
#   Ensure if service is running or stopped.
#
# @param service_name
#   Name of SNMP service. Only set this if your platform is not supported or you know what you are doing.
#
# @param service_enable
#   Start service at boot.
#
# @param service_hasstatus
#   Service has status command.
#
# @param service_hasrestart
#   Service has restart command.
#
# @param snmptrapd_options
#   Commandline options passed to snmptrapd via init script.
#
# @param trap_service_ensure
#   Ensure if service is running or stopped.
#
# @param trap_service_name
#   Name of SNMP service
#   Only set this if your platform is not supported or you know what you are doing.
#
# @param trap_service_enable
#   Start service at boot.
#
# @param trap_service_hasstatus
#   Service has status command.
#
# @param trap_service_hasrestart
#   Service has restart command.
#
# @param openmanage_enable
#   Adds the smuxpeer directive to the snmpd.conf file to allow net-snmp to talk with Dell's OpenManage
#
# @param master
#   Include the *master* option to enable AgentX registrations.
#
# @param agentx_perms
#   Defines the permissions and ownership of the AgentX Unix Domain socket.
#
# @param agentx_ping_interval
#   This will make the subagent try and reconnect every NUM seconds to the
#   master if it ever becomes (or starts) disconnected.
#
# @param agentx_socket
#   Defines the address the master agent listens at, or the subagent should connect to.
#
# @param agentx_timeout
#   Defines the timeout period (NUM seconds) for an AgentX request.
#
# @param agentx_retries
#   Defines the number of retries for an AgentX request.
#
# @param snmpv2_enable
#   Disable com2sec, group, and access in snmpd.conf
#
# @param var_net_snmp
#   Path to snmp's var directory.
#
# @param varnetsnmp_perms
#   Mode of `var_net_snmp` directory.
#
# @param varnetsnmp_owner
#   Owner of `var_net_snmp` directory.
#
# @param varnetsnmp_group
#   Group of `var_net_snmp` directory.
#
class snmp (
  Enum['present','absent']                                        $ensure        = 'present',
  Array[String[1]]                                                $agentaddress  = [ 'udp:127.0.0.1:161', 'udp6:[::1]:161' ],
  Array[String[1]]                                                $snmptrapdaddr = [ 'udp:127.0.0.1:162', 'udp6:[::1]:162' ],
  Variant[Undef, String[1], Array[String[1]]]                     $ro_community  = 'public',
  Variant[Undef, String[1], Array[String[1]]]                     $ro_community6 = 'public',
  Variant[Undef, String[1], Array[String[1]]]                     $rw_community  = undef,
  Variant[Undef, String[1], Array[String[1]]]                     $rw_community6 = undef,
  Variant[Array, Stdlib::IP::Address::V4, Stdlib::IP::Address::V4::CIDR] $ro_network    = '127.0.0.1',
  Variant[Array, Stdlib::IP::Address::V6, Stdlib::IP::Address::V6::CIDR] $ro_network6   = '::1',
  Variant[Array, Stdlib::IP::Address::V4, Stdlib::IP::Address::V4::CIDR] $rw_network    = '127.0.0.1',
  Variant[Array, Stdlib::IP::Address::V6, Stdlib::IP::Address::V6::CIDR] $rw_network6   = '::1',
  String[1]                                                       $contact       = 'Unknown',
  String[1]                                                       $location      = 'Unknown',
  String[1]                                                       $sysname       = $facts['networking']['fqdn'],
  Integer                                                         $services      = 72,
  Array[String[1]]                                                $com2sec       = [ 'notConfigUser  default       public' ],
  Array[String[1]]                                                $com2sec6      = [ 'notConfigUser  default       public' ],
  Array[String[1]] $groups = [
    'notConfigGroup v1            notConfigUser',
    'notConfigGroup v2c           notConfigUser',
  ],
  Array[String[1]] $views = [
    'systemview    included   .1.3.6.1.2.1.1',
    'systemview    included   .1.3.6.1.2.1.25.1.1',
  ],
  Array[String[1]] $accesses = [
    'notConfigGroup ""      any       noauth    exact  systemview none  none',
  ],
  Optional[Array[String[1]]] $dlmod                        = undef,
  Optional[Array[String[1]]] $extends                      = undef,
  Optional[Array[String[1]]] $snmpd_config                 = undef,
  Enum['yes','no']           $disable_authorization        = 'no',
  Enum['yes','no']           $do_not_log_traps             = 'no',
  Enum['yes','no']           $do_not_log_tcpwrappers       = 'no',
  Optional[Array[String[1]]] $trap_handlers                = undef,
  Optional[Array[String[1]]] $trap_forwards                = undef,
  Optional[Array[String[1]]] $snmptrapd_config             = undef,
  Boolean                    $manage_client                = false,
  Optional[Array[String[1]]] $snmp_config                  = undef,
  Boolean                    $autoupgrade                  = false,
  String[1]                  $package_name                 = 'net-snmp',
  Optional[String[1]]        $snmptrapd_package_name       = undef,
  Optional[String[1]]        $snmpd_options                = undef,
  Stdlib::Absolutepath       $sysconfig                    = '/etc/sysconfig/snmpd',
  Stdlib::Absolutepath       $trap_sysconfig               = '/etc/sysconfig/snmptrapd',
  Stdlib::Absolutepath       $trap_service_config          = '/etc/snmp/snmptrapd.conf',
  Stdlib::Absolutepath       $service_config               = '/etc/snmp/snmpd.conf',
  Stdlib::Filemode           $service_config_perms         = '0600',
  Stdlib::Absolutepath       $service_config_dir_path      = '/usr/local/etc/snmp',
  String[1]                  $service_config_dir_owner     = 'root',
  String[1]                  $service_config_dir_group     = 'root',
  String[1]                  $service_config_dir_perms     = '0755',
  Stdlib::Ensure::Service    $service_ensure               = 'running',
  String[1]                  $service_name                 = 'snmpd',
  Boolean                    $service_enable               = true,
  Boolean                    $service_hasstatus            = true,
  Boolean                    $service_hasrestart           = true,
  Optional[String[1]]        $snmptrapd_options            = undef,
  Stdlib::Ensure::Service    $trap_service_ensure          = 'stopped',
  String[1]                  $trap_service_name            = 'snmptrapd',
  Boolean                    $trap_service_enable          = false,
  Boolean                    $trap_service_hasstatus       = true,
  Boolean                    $trap_service_hasrestart      = true,
  Boolean                    $openmanage_enable            = false,
  Boolean                    $master                       = false,
  Optional[Stdlib::Filemode] $agentx_perms                 = undef,
  Optional[Integer]          $agentx_ping_interval         = undef,
  Optional[String[1]]        $agentx_socket                = undef,
  Integer[0]                 $agentx_timeout               = 1,
  Integer[0]                 $agentx_retries               = 5,
  Boolean                    $snmpv2_enable                = true,
  Stdlib::Absolutepath       $var_net_snmp                 = '/var/lib/net-snmp',
  String[1]                  $varnetsnmp_owner             = 'root',
  String[1]                  $varnetsnmp_group             = 'root',
  Stdlib::Filemode           $varnetsnmp_perms             = '0755',
) {

  $template_snmpd_conf          = 'snmp/snmpd.conf.erb'
  $template_snmpd_sysconfig     = "snmp/snmpd.sysconfig-${facts['os']['family']}.erb"
  $template_snmptrapd           = 'snmp/snmptrapd.conf.erb'
  $template_snmptrapd_sysconfig = "snmp/snmptrapd.sysconfig-${facts['os']['family']}.erb"

  if $ensure == 'present' {
    if $autoupgrade {
      $package_ensure = 'latest'
    } else {
      $package_ensure = 'present'
    }
    $file_ensure = 'present'
    $trap_service_ensure_real = $trap_service_ensure
    $trap_service_enable_real = $trap_service_enable

    # Make sure that if $trap_service_ensure == 'running' that
    # $service_ensure_real == 'running' on Debian.
    if ($facts['os']['family'] == 'Debian') and ($trap_service_ensure_real == 'running') {
      $service_ensure_real = $trap_service_ensure_real
      $service_enable_real = $trap_service_enable_real
    } else {
      $service_ensure_real = $service_ensure
      $service_enable_real = $service_enable
    }
  } else {
    $package_ensure = 'absent'
    $file_ensure = 'absent'
    $service_ensure_real = 'stopped'
    $service_enable_real = false
    $trap_service_ensure_real = 'stopped'
    $trap_service_enable_real = false
  }

  if $service_ensure == 'running' {
    $snmpdrun = 'yes'
  } else {
    $snmpdrun = 'no'
  }
  if $trap_service_ensure == 'running' {
    $trapdrun = 'yes'
  } else {
    $trapdrun = 'no'
  }

  if $manage_client {
    class { 'snmp::client':
      ensure      => $ensure,
      autoupgrade => $autoupgrade,
      snmp_config => $snmp_config,
    }
  }

  package { 'snmpd':
    ensure => $package_ensure,
    name   => $package_name,
  }

  # Since ubuntu 16.04 platforms, there is a differente snmptrad package
  if $snmp::snmptrapd_package_name {
    package { 'snmptrapd':
      ensure => $package_ensure,
      name   => $snmp::snmptrapd_package_name,
    }
  }

  file { 'var-net-snmp':
    ensure  => 'directory',
    path    => $var_net_snmp,
    owner   => $varnetsnmp_owner,
    group   => $varnetsnmp_group,
    mode    => $varnetsnmp_perms,
    require => Package['snmpd'],
  }

  if $facts['os']['family'] == 'Suse' {
    file { '/etc/init.d/snmptrapd':
      source  => '/usr/share/doc/packages/net-snmp/rc.snmptrapd',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Package['snmpd'],
      before  => Service['snmptrapd'],
    }
  }

  file { 'snmpd.conf':
    ensure  => $file_ensure,
    path    => $service_config,
    owner   => 'root',
    group   => $service_config_dir_group,
    mode    => $service_config_perms,
    content => template($template_snmpd_conf),
    require => Package['snmpd'],
  }

  file { 'snmptrapd.conf':
    ensure  => $file_ensure,
    path    => $trap_service_config,
    owner   => 'root',
    group   => $service_config_dir_group,
    mode    => $service_config_perms,
    content => template($template_snmptrapd),
    require => Package['snmpd'],
  }


  file { 'snmpd.sysconfig':
    ensure  => $file_ensure,
    path    => $sysconfig,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($template_snmpd_sysconfig),
    require => Package['snmpd'],
    notify  => Service['snmpd'],
  }

  if $facts['os']['family'] == 'RedHat' {
    file { 'snmptrapd.sysconfig':
      ensure  => $file_ensure,
      path    => $trap_sysconfig,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template($template_snmptrapd_sysconfig),
      require => Package['snmpd'],
      notify  => Service['snmptrapd'],
    }
  } elsif
    ( $facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['major'], '16.04') >= 0 ) or
    ( $facts['os']['name'] == 'Debian' and versioncmp($facts['os']['release']['major'], '8') >= 0 )
  {
    file { 'snmptrapd.sysconfig':
      ensure  => $file_ensure,
      path    => $trap_sysconfig,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template($template_snmptrapd_sysconfig),
      require => Package['snmptrapd'],
      notify  => Service['snmptrapd'],
    }

    service { 'snmptrapd':
      ensure     => $trap_service_ensure_real,
      name       => $trap_service_name,
      enable     => $trap_service_enable_real,
      hasstatus  => $trap_service_hasstatus,
      hasrestart => $trap_service_hasrestart,
      require    => [
        File['var-net-snmp'],
        Package['snmptrapd'],
      ],
      subscribe  => File['snmptrapd.conf'],
    }
  }

  unless $facts['os']['family'] == 'Debian' {
    service { 'snmptrapd':
      ensure     => $trap_service_ensure_real,
      name       => $trap_service_name,
      enable     => $trap_service_enable_real,
      hasstatus  => $trap_service_hasstatus,
      hasrestart => $trap_service_hasrestart,
      require    => File['var-net-snmp'],
      subscribe  => File['snmptrapd.conf'],
    }
  }

  service { 'snmpd':
    ensure     => $service_ensure_real,
    name       => $service_name,
    enable     => $service_enable_real,
    hasstatus  => $service_hasstatus,
    hasrestart => $service_hasrestart,
    require    => File['var-net-snmp'],
    subscribe  => File['snmpd.conf'],
  }

  if $facts['os']['family'] == 'Debian' {
    File['snmptrapd.conf'] ~> Service['snmpd']
  }
}
