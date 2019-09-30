# Systemd

[![Puppet Forge](http://img.shields.io/puppetforge/v/camptocamp/systemd.svg)](https://forge.puppetlabs.com/camptocamp/systemd)
[![Build Status](https://travis-ci.org/camptocamp/puppet-systemd.png?branch=master)](https://travis-ci.org/camptocamp/puppet-systemd)

## Overview

This module declares exec resources to create global sync points for reloading systemd.

**Version 2 and newer of the module don't work with Hiera 3! You need to migrate your existing Hiera setup to Hiera 5**

## Usage and examples

There are two ways to use this module.

### unit files

Let this module handle file creation and systemd reloading.

```puppet
systemd::unit_file { 'foo.service':
 source => "puppet:///modules/${module_name}/foo.service",
}
~> service {'foo':
  ensure => 'running',
}
```

Or handle file creation yourself and trigger systemd.

```puppet
include systemd::systemctl::daemon_reload

file { '/usr/lib/systemd/system/foo.service':
  ensure => file,
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => "puppet:///modules/${module_name}/foo.service",
}
~> Class['systemd::systemctl::daemon_reload']

service {'foo':
  ensure    => 'running',
  subscribe => File['/usr/lib/systemd/system/foo.service'],
}
```

You can also use this module to more fully manage the new unit. This example deploys the unit, reloads systemd and then enables and starts it.

```puppet
systemd::unit_file { 'foo.service':
 source => "puppet:///modules/${module_name}/foo.service",
 enable => true,
 active => true,
}
```

### drop-in files

Drop-in files are used to add or alter settings of a unit without modifying the
unit itself. As for the unit files, the module can handle the file and
directory creation and systemd reloading:

```puppet
systemd::dropin_file { 'foo.conf':
  unit   => 'foo.service',
  source => "puppet:///modules/${module_name}/foo.conf",
}
~> service {'foo':
  ensure    => 'running',
}
```

Or handle file and directory creation yourself and trigger systemd:

```puppet
include systemd::systemctl::daemon_reload

file { '/etc/systemd/system/foo.service.d':
  ensure => directory,
  owner  => 'root',
  group  => 'root',
}

file { '/etc/systemd/system/foo.service.d/foo.conf':
  ensure => file,
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => "puppet:///modules/${module_name}/foo.conf",
}
~> Class['systemd::systemctl::daemon_reload']

service {'foo':
  ensure    => 'running',
  subscribe => File['/etc/systemd/system/foo.service.d/foo.conf'],
}
```

Sometimes it's desirable to reload the systemctl daemon before a service is refreshed (for example:
when overriding `ExecStart` or adding environment variables to the drop-in file).  In that case,
use `daemon_reload => 'eager'` instead of the default `'lazy'`.  Be aware that the daemon could be
reloaded multiple times if you have multiple `systemd::dropin_file` resources and any one of them
is using `'eager'`.

### tmpfiles

Let this module handle file creation and systemd reloading

```puppet
systemd::tmpfile { 'foo.conf':
  source => "puppet:///modules/${module_name}/foo.conf",
}
```

Or handle file creation yourself and trigger systemd.

```puppet
include systemd::tmpfiles

file { '/etc/tmpfiles.d/foo.conf':
  ensure => file,
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => "puppet:///modules/${module_name}/foo.conf",
}
~> Class['systemd::tmpfiles']
```

### service limits

Manage soft and hard limits on various resources for executed processes.

```puppet
systemd::service_limits { 'foo.service':
  limits => {
    'LimitNOFILE' => 8192,
    'LimitNPROC'  => 16384,
  }
}
```

Or provide the configuration file yourself. Systemd reloading and restarting of the service are handled by the module.

```puppet
systemd::service_limits { 'foo.service':
  source => "puppet:///modules/${module_name}/foo.conf",
}
```

### network

systemd-networkd is able to manage your network configuration. We provide a
defined resource which can write the interface configurations. systemd-networkd
needs to be restarted to apply the configs. The defined resource can do this
for you:

```puppet
systemd::network{'eth0.network':
  source          => "puppet:///modules/${module_name}/eth0.network",
  restart_service => true,
}
```

### Services

Systemd provides multiple services. Currently you can manage `systemd-resolved`,
`systemd-timesyncd` and `systemd-networkd` via the main class:

```puppet
class{'systemd':
  manage_resolved  => true,
  manage_networkd  => true,
  manage_timesyncd => true,
}
```

$manage_networkd is required if you want to reload it for new
`systemd::network` resources. Setting $manage_resolved will also manage your
`/etc/resolv.conf`.

When configuring `systemd::resolved` you could set `dns_stub_resolver` to false (default) to use a *standard* `/etc/resolved.conf`, or you could set it to `true` to use the local resolver provided by `systemd-resolved`.

Systemd has introduced `DNS Over TLS` in the release 239. Currently two states are supported `no` and `opportunistic`. When enabled with `opportunistic` `systemd-resolved` will start a TCP-session to a DNS server with `DNS Over TLS` support. Note that there will be no host checking for `DNS Over TLS` due to missing implementation in `systemd-resolved`.

It is possible to configure the default ntp servers in /etc/systemd/timesyncd.conf:

```puppet
class{'systemd':
  manage_timesyncd    => true,
  ntp_server          => ['0.pool.ntp.org', '1.pool.ntp.org'],
  fallback_ntp_server => ['2.pool.ntp.org', '3.pool.ntp.org'],
}
```

This requires puppetlabs-inifile, which is only a soft dependency in this module (you need to explicitly install it). Both parameters accept a string or an array.

### Resource Accounting

Systemd has support for different accounting option. It can track
CPU/Memory/Network stats per process. This is explained in depth at [systemd-system.conf](https://www.freedesktop.org/software/systemd/man/systemd-system.conf.html).
This defaults to off (default on most operating systems). You can enable this
with the `$manage_accounting` parameter. The module provides a default set of
working accounting options per operating system, but you can still modify them
with `$accounting`:

```puppet
class{'systemd':
  manage_accounting => true,
  accounting        => {
    'DefaultCPUAccounting'    => 'yes',
    'DefaultMemoryAccounting' => 'no',
  }
}
```
### journald configuration

It also allows you to manage journald settings. You can manage journald settings through setting the `journald_settings` parameter. If you want a parameter to be removed, you can pass its value as params.

```yaml
systemd::journald_settings:
  Storage: auto
  MaxRetentionSec: 5day
  MaxLevelStore:
    ensure: absent
```
