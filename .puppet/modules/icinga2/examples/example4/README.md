NOTICE: This example is for Puppet 4 only.

The following syntax that's used in profile::icinga2::agent and profile::icinga2::slave is for Puppet 4.
```
  @@::icinga2::object::host { $::fqdn:
    * => merge({
      display_name => $::hostname,
      address      => $agent_ip,
      target       => "/etc/icinga2/zones.d/${parent_zone}/${::hostname}.conf",
    }, hiera_hash(icinga2::host)),
  }
```
