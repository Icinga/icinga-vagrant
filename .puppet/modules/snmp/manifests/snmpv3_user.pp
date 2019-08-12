# @summary
#   Creates a SNMPv3 user with authentication and encryption paswords.
#
# @example
#   snmp::snmpv3_user { 'myuser':
#     authtype => 'MD5',
#     authpass => '1234auth',
#     privpass => '5678priv',
#   }
#
# @param authpass
#   Authentication password for the user.
#
# @param authtype
#   Authentication type for the user.  SHA or MD5
#
# @param privpass
#   Encryption password for the user.
#
# @param privtype
#   Encryption type for the user.  AES or DES
#
# @param daemon
#   Which daemon file in which to write the user.  snmpd or snmptrapd
#
define snmp::snmpv3_user (
  String[8]                 $authpass,
  Enum['SHA','MD5']         $authtype = 'SHA',
  Optional[String[8]]       $privpass = undef,
  Enum['AES','DES']         $privtype = 'AES',
  Enum['snmpd','snmptrapd'] $daemon   = 'snmpd'
) {

  include snmp

  if ($daemon == 'snmptrapd') and ($facts['os']['family'] != 'Debian') {
    $service_name   = 'snmptrapd'
  } else {
    $service_name   = 'snmpd'
  }

  $cmd = $privpass ? {
    undef   => "createUser ${title} ${authtype} \"${authpass}\"",
    default => "createUser ${title} ${authtype} \"${authpass}\" ${privtype} \"${privpass}\""
  }

  if ($title in $facts['snmpv3_user']) {
    # user details from config are available as fact
    $usm_user = $facts['snmpv3_user'][$title]

    $authhash = snmp::snmpv3_usm_hash($authtype, $usm_user['engine'], $authpass)

    # privacy protocol key may be empty; truncate to 128 bits if used
    $privhash = empty($privpass) ? {
      true    => '',
      default => snmp::snmpv3_usm_hash($authtype, $usm_user['engine'], $privpass, 128)
    }

    # (re)create the user if at least one of the hashes is different
    $create = ($authhash != $usm_user['authhash']) or ($privhash != $usm_user['privhash'])
  }
  else {
    # user is unknown
    $create = true
  }

  if $create {
    unless defined(Exec["stop-${service_name}"]) {
      #
      # TODO: update $command for different operating systems/releases
      #
      $command = "service ${service_name} stop ; sleep 5"

      exec { "stop-${service_name}":
        command => $command,
        user    => 'root',
        cwd     => '/',
        path    => '/bin:/sbin:/usr/bin:/usr/sbin',
        require => [ Package['snmpd'], File['var-net-snmp'], ],
      }
    }

    unless defined(File["${snmp::var_net_snmp}/${service_name}.conf"]) {
      #
      # For this file there is no content defined since the SNMP daemon
      # rewrites the content on exit. But the file needs to exist or the
      # following file_line resource will fail.
      #
      file { "${snmp::var_net_snmp}/${service_name}.conf":
        ensure => file,
        mode   => '0600',
        owner  => $snmp::varnetsnmp_owner,
        group  => $snmp::varnetsnmp_group,
      }
    }

    file_line { "create-snmpv3-user-${title}":
      path      => "${snmp::var_net_snmp}/${service_name}.conf",
      line      => $cmd,
      match     => "^createUser ${title} ",
      subscribe => Exec["stop-${service_name}"],
      require   => File["${snmp::var_net_snmp}/${service_name}.conf"],
      before    => Service[$service_name],
    }
  }

  # TODO: Add "rwuser ${title}" (or rouser) to /etc/snmp/${daemon}.conf
}
