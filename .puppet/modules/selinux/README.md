# SELinux module for Puppet

[![Build Status](https://travis-ci.org/voxpupuli/puppet-selinux.png?branch=master)](https://travis-ci.org/voxpupuli/puppet-selinux)
[![Code Coverage](https://coveralls.io/repos/github/voxpupuli/puppet-selinux/badge.svg?branch=master)](https://coveralls.io/github/voxpupuli/puppet-selinux)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/selinux.svg)](https://forge.puppetlabs.com/puppet/selinux)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/selinux.svg)](https://forge.puppetlabs.com/puppet/selinux)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/selinux.svg)](https://forge.puppetlabs.com/puppet/selinux)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/selinux.svg)](https://forge.puppetlabs.com/puppet/selinux)

#### Table of Contents

1. [Overview](#overview)
1. [Module Description - What the module does and why it is useful](#module-description)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Defined Types](#defined-types)
1. [Development - Guide for contributing to the module](#development)
1. [Authors](#authors)

## Overview

This class manages SELinux on RHEL based systems.

## Requirements

* Puppet 5 or later

## Module Description

This module will configure SELinux and/or deploy SELinux based modules to
running system.

## Get in touch

* IRC: [#voxpupuli on irc.freenode.net](irc://irc.freenode.net/voxpupuli)
  ([Freenode WebChat](http://webchat.freenode.net/?channels=%23voxpupuli))
* Mailinglist: <voxpupuli@groups.io>
  ([groups.io Webinterface](https://groups.io/g/voxpupuli/topics))

## Upgrading from puppet-selinux 0.8.x

* Previously, module building always used the refpolicy framework. The default
  module builder is now 'simple', which uses only checkmodule. Not all features are
  supported with this builder.

  To build modules using the refpolicy framework like previous versions did,
  specify the  'refpolicy' builder either explicitly per module or globally
  via the main class

* The interfaces to the various helper manifests has been changed to be more in line
  with Puppet file resource naming conventions.

  You will need to update your manifests to use the new parameter names.

* The selinux::restorecond manifest to manage the restorecond service no longer exists

## Known problems / limitations

* If SELinux is disabled and you want to switch to permissive or enforcing you
  are required to reboot the system (limitation of SELinux). The module won't
  do this for you.
* If SELinux is disabled and the user wants enforcing mode, the module
  will downgrade to permissive mode instead to avoid transitioning directly from
  disabled to enforcing state after a reboot and potentially breaking the system.
  The user will receive a warning when this happens,
* If you add filecontexts with `semanage fcontext` (what `selinux::fcontext`
  does) the order is important. If you add /my/folder before /my/folder/subfolder
  only /my/folder will match (limitation of SELinux). There is no such limitation
  to file-contexts defined in SELinux modules. (GH-121)
* While SELinux is disabled the defined types `selinux::boolean`,
  `selinux::fcontext`, `selinux::port` will produce puppet agent runtime errors
  because the used tools fail.
* If you try to remove a built-in permissive type, the operation will appear to succeed
  but will actually have no effect, making your puppet runs non-idempotent.
* The `selinux_port` provider may misbehave if the title does not correspond to
  the format it expects. Users should use the `selinux::port` define instead except
  when purging resources
* Defining port ranges that overlap with existing ranges is currently not detected, and will
  cause semanage to error when the resource is applied.

## Usage

Generated puppet strings documentation with examples is available from
https://voxpupuli.org/puppet-selinux/

It's also included in the docs/ folder as simple html pages.

## Reference

### Basic usage

```puppet
include selinux
```

This will include the module and allow you to use the provided defined types,
but will not modify existing SELinux settings on the system.

### More advanced usage

```puppet
class { selinux:
  mode => 'enforcing',
  type => 'targeted',
}
```

This will include the module and manage the SELinux mode (possible values are
`enforcing`, `permissive`, and `disabled`) and enforcement type (possible values
are `targeted`, `minimum`, and `mls`). Note that disabling SELinux requires a reboot
to fully take effect. It will run in `permissive` mode until then.

### Deploy a custom module using the refpolicy framework

```puppet
selinux::module { 'resnet-puppet':
  ensure    => 'present',
  source_te => 'puppet:///modules/site_puppet/site-puppet.te',
  source_fc => 'puppet:///modules/site_puppet/site-puppet.fc',
  source_if => 'puppet:///modules/site_puppet/site-puppet.if',
  builder   => 'refpolicy'
}
```

### Using pre-compiled policy packages

```puppet
selinux::module { 'resnet-puppet':
  ensure    => 'present',
  source_pp => 'puppet:///modules/site_puppet/site-puppet.pp',
}
```

Note that pre-compiled policy packages may not work reliably
across all RHEL / CentOS releases. It's up to you as the user
to test that your packages load properly.

### Set a boolean value

```puppet
selinux::boolean { 'puppetagent_manage_all_files': }
```

## Defined Types

* `boolean` - Set seboolean values
* `fcontext` - Define fcontext types and equals values
* `module` - Manage an SELinux module
* `permissive` - Set a context to `permissive`.
* `port` - Set selinux port context policies

## Development

### Things to remember

* The SELinux tools behave odd when SELinux is disabled
    * `semanage` requires `--noreload` while in disabled mode when
      adding or changing something
    * Only few `--list` operations work
* run acceptance tests:

```
BEAKER_debug=yes BEAKER_set="centos-6-x64" PUPPET_INSTALL_TYPE="agent" bundle exec rake beaker &&
BEAKER_debug=yes BEAKER_set="centos-7-x64" PUPPET_INSTALL_TYPE="agent" bundle exec rake beaker &&
BEAKER_debug=yes BEAKER_set="fedora-25-x64" PUPPET_INSTALL_TYPE="agent" bundle exec rake beaker &&
BEAKER_debug=yes BEAKER_set="fedora-26-x64" PUPPET_INSTALL_TYPE="agent" bundle exec rake beaker &&
BEAKER_debug=yes BEAKER_set="fedora-27-x64" PUPPET_INSTALL_TYPE="agent" bundle exec rake beaker
```

### Facter facts

The fact values might be unexpected while in disabled mode. One could expect
the config\_mode to be set, but only the boolean `enabled` is set.

The most important facts:

| Fact                                      | Fact (old)                | Mode: disabled | Mode: permissive                        | Mode:  enforcing                        |
|-------------------------------------------|---------------------------|----------------|-----------------------------------------|-----------------------------------------|
| `$facts['os']['selinux']['enabled']`      | `$::selinux`              | false          | true                                    | true                                    |
| `$facts['os']['selinux']['config_mode']`   | `$::selinux_config_mode`  | undef          | Value of SELINUX in /etc/selinux/config | Value of SELINUX in /etc/selinux/config |
| `$facts['os']['selinux']['current_mode']` | `$::selinux_current_mode` | undef          | Value of `getenforce` downcased         | Value of `getenforce` downcased         |

## Authors

* VoxPupuli <voxpupuli@groups.io>
* James Fryman <james@fryman.io>
