# Net-SNMP

[![License](https://img.shields.io/github/license/voxpupuli/puppet-snmp.svg)](https://github.com/voxpupuli/puppet-snmp/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/voxpupuli/puppet-snmp.svg?branch=master)](https://travis-ci.org/voxpupuli/puppet-snmp)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/snmp.svg)](https://forge.puppetlabs.com/puppet/snmp)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/snmp.svg)](https://forge.puppetlabs.com/puppet/snmp)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/snmp.svg)](https://forge.puppetlabs.com/puppet/snmp)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/snmp.svg)](https://forge.puppetlabs.com/puppet/snmp)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with this module](#setup)
    * [What this module affects](#what-this-module-affects)
    * [What this module requires](#requirements)
    * [Beginning with this module](#beginning-with-this-module)
    * [Upgrading](#upgrading)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Client](#client)
    * [Trap Daemon](#trap-daemon)
    * [SNMPv3 Users](#snmpv3-users)
    * [Access Control](#access-control)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
    * [OS Support](#os-support)
    * [Notes](#notes)
    * [Issues](#issues)
7. [Development - Guide for contributing to the module](#development)

## Overview

This Puppet module manages the installation and configuration of [Net-SNMP](http://www.net-snmp.org/) client, server, and trap server.  It also can create a SNMPv3 user with authentication and privacy passwords.

## Module Description

Simple Network Management Protocol (SNMP) is a widely used protocol for monitoring the health and welfare of network and computer equipment. [Net-SNMP](http://www.net-snmp.org/) implements SNMP v1, SNMP v2c, and SNMP v3 using both IPv4 and IPv6.  This Puppet module manages the installation and configuration of the Net-SNMP client, server, and trap server.  It also can create a SNMPv3 user with authentication and privacy passwords.

Only platforms that have Net-SNMP available are supported.  This module will not work with AIX or Solaris SNMP.

## Setup

### What this module affects

* Installs the Net-SNMP client package and configuration.
* Installs the Net-SNMP daemon package, service, and configuration.
* Installs the Net-SNMP trap daemon service and configuration.
* Creates a SNMPv3 user with authentication and encryption paswords.

### Beginning with this module

This declaration will get you the SNMP daemon listening on the loopback IPv4 and IPv6 addresses with a v1 and v2c read-only community of 'public'.

```puppet
include snmp
```

### Upgrading

#### Deprecation Warning

##### Past module 3.x series

 * The classes `snmp::server` and `snmp::trapd` have been merged into class `snmp`.  All of their class parameters available in the `snmp` class.

##### Current module 4.x series

 * The parameter `install_client` is renamed to `manage_client`.

 * Support for Puppet < 4 is removed.

##### Future module 5.x series

 * The parameters `ro_community`, `rw_community`, `ro_network`, and `rw_network` will be removed.

 * The snmptrapd parameter name will become `authcommunity`.

## Usage

Most interaction with the snmp module can be done through the main snmp class. This means you can simply toggle the parameters in `::snmp` to have most functionality of the module.  Additional fuctionality can be achieved by only utilizing the `::snmp::client` class or the `::snmp::snmpv3_user` define.

To install the SNMP service listening on all IPv4 and IPv6 interfaces:

```puppet
class { 'snmp':
  agentaddress => [ 'udp:161', 'udp6:161' ],
}
```

To change the SNMP community from the default value and limit the netblocks that can use it:

```puppet
class { 'snmp':
  agentaddress => [ 'udp:161', ],
  ro_community => 'myPassword',
  ro_network   => '192.168.0.0/16',
}
```

Or more than one community:

```puppet
class { 'snmp':
  agentaddress => [ 'udp:161', ],
  ro_community => [ 'myPassword', 'myOtherPassword', ],
}
```

To set the responsible person and location of the SNMP system:

```puppet
class { 'snmp':
  contact  => 'root@yourdomain.org',
  location => 'Phoenix, Arizona, U.S.A., Earth, Milky Way',
}
```

### Client

If you just want to install the SNMP client:

```puppet
include snmp::client
```

To install the SNMP service and the client:

```puppet
class { 'snmp':
  manage_client => true,
}
```

If you want to pass client configuration stanzas to the snmp.conf file:

```puppet
class { 'snmp':
  snmp_config => [
    'defVersion 2c',
    'defCommunity public',
    'mibdirs +/usr/local/share/snmp/mibs',
  ],
}
```

### Trap Daemon

To only configure and run the snmptrap daemon:

```puppet
class { 'snmp':
  service_ensure      => 'stopped',
  trap_service_ensure => 'running',
  trap_service_enable => true,
  snmptrapdaddr       => [ 'udp:162', ],
  trap_handlers       => [
    'default /usr/bin/perl /usr/bin/traptoemail me@somewhere.local', # optional
    'TRAP-TEST-MIB::demo-trap /home/user/traptest.sh demo-trap', # optional
  ],
  trap_forwards       => [ 'default udp:55.55.55.55:162' ], # optional
}
```

### SNMPv3 Users

To install a SNMP version 3 user for snmpd:

```puppet
snmp::snmpv3_user { 'myuser':
  authpass => '1234auth',
  privpass => '5678priv',
}
class { 'snmp':
  snmpd_config => [ 'rouser myuser authPriv' ],
}
```

To install a SNMP version 3 user for snmptrapd:

```puppet
snmp::snmpv3_user { 'myuser':
  authpass => 'SeCrEt',
  privpass => 'PhRaSe',
  daemon   => 'snmptrapd',
}
```

### Access Control

With traditional access control, you can give a simple password and (optional) network restriction:
```puppet
class { 'snmp':
  ro_community => 'myPassword',
  ro_network   => '10.0.0.0/8',
}
```
and it becomes this in snmpd.conf:
```
rocommunity myPassword 10.0.0.0/8
```
This says that any host on network 10.0.0.0/8 can read any SNMP value via SNMP versions 1 and 2c as long as they provide the password 'myPassword'.

With View-based Access Control Model (VACM), you can do this (more complex) configuration instead:
```puppet
class { 'snmp':
  com2sec  => ['mySecName   10.0.0.0/8 myPassword'],
  groups   => ['myGroupName v1         mySecName',
               'myGroupName v2c        mySecName'],
  views    => ['everyThing  included   .'],
  accesses => ['myGroupName ""      any   noauth  exact  everyThing  none   none'],
}
```
where the variables have the following meanings:
* "mySecName": A security name you have selected.
* "myPassword": The community (password) for the security name.
* "myGroupName": A group name to which you assign security names.
* "everyThing": A view name (i.e. a list of MIBs that will be ACLed as a unit).

and it becomes this in snmpd.conf:
```
com2sec mySecName   10.0.0.0/8 myPassword
group   myGroupName v1         mySecName
group   myGroupName v2c        mySecName
view    everyThing  included   .
access  myGroupName ""      any   noauth  exact  everyThing  none   none
```
This also says that any host on network 10.0.0.0/8 can read any SNMP value via SNMP versions 1 and 2c as long as they provide the password 'myPassword'.  But it also gives you the ability to change *any* of those variables.

Reference: [Manpage of snmpd.conf - Access Control](http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAJ)

#### Multiple Network Restrictions

In traditional access control, you can also pass multiple networks for the community string.
```puppet
class { 'snmp':
  ro_community => 'shibboleth',
  ro_network   => [ '192.168.0.0/16', '1.2.3.4/32', ],
}
```
and it becomes this in snmpd.conf:
```
rocommunity shibboleth 192.168.0.0/16
rocommunity shibboleth 1.2.3.4/32
```

## Reference

See in file [REFERENCE.md](REFERENCE.md).

## Limitations

### OS Support:

Net-SNMP module support is available with these operating systems:

* RedHat family  - tested on CentOS 6, CentOS 7
* SuSE family    - tested on SLES 11 SP1
* Debian family  - tested on Debian 8, Debian 9, Ubuntu 14.04, Ubuntu 16.04, Ubuntu 18.04

### Notes:

* By default the SNMP service now listens on BOTH the IPv4 and IPv6 loopback
  addresses.
* There is a bug on Debian squeeze of net-snmp's status script. If snmptrapd is
  not running the status script returns 'not running' so puppet restarts the
  snmpd service. The following is a workaround: `class { 'snmp':
  service_hasstatus => false, trap_service_hasstatus => false, }`
* For security reasons, the SNMP daemons are configured to listen on the loopback
  interfaces (127.0.0.1 and [::1]).  Use `agentaddress` and `snmptrapdaddr` to change this
  configuration.
* Not all parts of [Traditional Access
  Control](http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAK) or [VACM
  Configuration](http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAL) are
  fully supported in this module.

### Issues:

* Debian will not support the use of non-numeric OIDs.  Something about [rabid
  freedom](http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=561578).
* Figure out how to install the RFC-standard MIBS on Debian so that `snmpwalk
  -v 2c -c public localhost system` will function.
* Possibly support USM and VACM?

## Development

This module is maintained by [Vox Pupuli](https://voxpupuli.org/). Voxpupuli welcomes new contributions to this module. We are happy to provide guidance if necessary.

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for information on how to contribute.

### Authors

* Mike Arnold <mike@razorsedge.org>
* Vox Pupuli Team
* List of contributors https://github.com/voxpupuli/puppet-snmp/graphs/contributors

Licensed under the Apache License, Version 2.0.
