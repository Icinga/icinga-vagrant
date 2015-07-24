# selinux

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Defined Types](#defined-types)
7. [Development - Guide for contributing to the module](#development)
8. [Authors](#authors)

## Overview

This class manages SELinux on RHEL based systems.

## Module Description

This module will configure SELinux and/or deploy SELinux based modules to running system.

Requires puppetlabs/stdlib
[https://github.com/puppetlabs/puppetlabs-stdlib]

## Usage

Parameters:

 * `$mode` (enforced|permissive|disabled) - sets the operating state for SELinux.

## Reference

Basic usage:

```puppet
include selinux
```

More advanced usage:

```puppet
class { selinux:
  mode => 'enforcing'
}
```

Deploy a custom module:

```puppet
selinux::module { 'resnet-puppet':
  ensure => 'present',
  source => 'puppet:///modules/site_puppet/site-puppet.te',
}
```

## Defined Types
* `fcontext` - Define fcontext types and equals values
* `boolean` - Set seboolean values
* `port` - Set selinux port context policies


## Development

## Authors
James Fryman <james@fryman.io>
