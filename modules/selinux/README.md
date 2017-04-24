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

* Puppet 3.8.7 or later

## Module Description

This module will configure SELinux and/or deploy SELinux based modules to
running system.

Requires puppetlabs/stdlib
`https://github.com/puppetlabs/puppetlabs-stdlib`

## Usage

Parameters:

* `$mode` (enforced|permissive|disabled) - sets the operating state for SELinux.
* `$type` (targeted|minimum|mls) - sets the enforcement type.
* `$manage_package` (boolean) - Whether or not to manage the SELinux management package.
* `$package_name` (string) - sets the name of the selinux management package.

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
are `target`, `minimum`, and `mls`). Note that disabling SELinux requires a reboot
to fully take effect. It will run in `permissive` mode until then.

### Deploy a custom module

```puppet
selinux::module { 'resnet-puppet':
  ensure => 'present',
  source => 'puppet:///modules/site_puppet/site-puppet.te',
}
```

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

## Authors

James Fryman <james@fryman.io>
