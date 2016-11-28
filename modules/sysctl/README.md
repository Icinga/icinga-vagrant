# puppet-sysctl

## Overview

Manage sysctl variable values. All changes are immediately applied, as well as
configured to become persistent. Tested on Red Hat Enterprise Linux 6 and 7.

 * `sysctl` : Definition to manage sysctl variables by setting a value.
 * `sysctl::base`: Base class (included from the definition).

For persistence to work, your Operating System needs to support looking for
sysctl configuration inside `/etc/sysctl.d/`.

You may optionally enable purging of the `/etc/sysctl.d/` directory, so that
all files which are not (or no longer) managed by this module will be removed.

Beware that for the purge to work, you need to either have at least one
sysctl definition call left for the node, or include `sysctl::base` manually.

You may also force a value to `ensure => absent`, which will always work.

For the few original settings in the main `/etc/sysctl.conf` file, the value is
also replaced so that running `sysctl -p` doesn't revert any change made by
puppet.

## Examples

Enable IP forwarding globally :
```puppet
sysctl { 'net.ipv4.ip_forward': value => '1' }
```

Set a value for maximum number of connections per UNIX socket :
```puppet
sysctl { 'net.core.somaxconn': value => '65536' }
```

Make sure we don't have any explicit value set for swappiness, typically
because it was set at some point but no longer needs to be. The original
value for existing nodes won't be reset until the next reboot :
```puppet
sysctl { 'vm.swappiness': ensure => absent }
```

If the order in which the files get applied is important, you can set it by
using a file name prefix, which could also be set globally from `site.pp` :
```puppet
Sysctl { prefix => '60' }
```

To enable purging of settings, you can use hiera to set the `sysctl::base`
`$purge` parameter :
```yaml
---
# sysctl
sysctl::base::purge: true
```
 
## Hiera

It is also possible to manage all sysctl keys using hiera, through the
`$values` parameter of the `sysctl::base` class. If sysctl values are spread
across different hiera locations, it's also possible to merge all of them
instead of having only the last one applied, by setting the
`$hiera_merge_values` parameter to true.

```yaml
sysctl::base::values:
  net.ipv4.ip_forward:
    value: '1'
  net.core.somaxconn:
    value: '65536'
  vm.swappiness:
    ensure: absent
```

## Original /etc/sysctl.d entries

When purging, puppet might want to remove files from `/etc/sysctl.d/` which
have not been created by puppet, but need to be present. It's possible to
set the same values for the same keys using puppet, but if the file comes from
an OS package which gets updated, it might re-appear when the package gets
updated. To work around this issue, it's possible to simply manage an
identical file with this module. Example :

```puppet
package { 'libvirt': ensure => installed } ->
sysctl { 'libvirtd':
  suffix => '',
  source => "puppet:///modules/${module_name}/libvirtd.sysctl",
}
```

