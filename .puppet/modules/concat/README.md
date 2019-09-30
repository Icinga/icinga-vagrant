# concat

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
    * [Beginning with concat](#beginning-with-concat)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Removed functionality](#removed-functionality)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

<a id="overview"></a>
## Overview

The concat module lets you construct files from multiple ordered fragments of text.

<a id="module-description"></a>
## Module Description

The concat module lets you gather `concat::fragment` resources from your other modules and order them into a coherent file through a single `concat` resource.

<a id="beginning-with-concat"></a>
### Beginning with concat

To start using concat you need to create:

* A concat{} resource for the final file.
* One or more concat::fragment{}s.

A minimal example might be:

~~~
concat { '/tmp/file':
  ensure => present,
}

concat::fragment { 'tmpfile':
  target  => '/tmp/file',
  content => 'test contents',
  order   => '01'
}
~~~

<a id="usage"></a>
## Usage

### Maintain a list of the major modules on a node

To maintain an motd file that lists the modules on one of your nodes, first create a class to frame up the file:

~~~
class motd {
  $motd = '/etc/motd'

  concat { $motd:
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  concat::fragment { 'motd_header':
    target  => $motd,
    content => "\nPuppet modules on this server:\n\n",
    order   => '01'
  }

  # let local users add to the motd by creating a file called
  # /etc/motd.local
  concat::fragment { 'motd_local':
    target => $motd,
    source => '/etc/motd.local',
    order  => '15'
  }
}

# let other modules register themselves in the motd
define motd::register (
  $content = "",
  $order   = '10',
) {
  if $content == "" {
    $body = $name
  } else {
    $body = $content
  }

  concat::fragment { "motd_fragment_$name":
    target  => '/etc/motd',
    order   => $order,
    content => "    -- $body\n"
  }
}
~~~

Then, in the declarations for each module on the node, add `motd::register{ 'Apache': }` to register the module in the motd.

~~~
class apache {
  include apache::install, apache::config, apache::service

  motd::register { 'Apache': }
}
~~~

These two steps populate the /etc/motd file with a list of the installed and registered modules, which stays updated even if you just remove the registered modules' `include` lines. System administrators can append text to the list by writing to /etc/motd.local.

When you're finished, the motd file will look something like this:

~~~
  Puppet modules on this server:

    -- Apache
    -- MySQL

  <contents of /etc/motd.local>
~~~

<a id="reference"></a>
## Reference

See [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-concat/blob/master/REFERENCE.md)

<a id="removed-functionality"></a>
### Removed functionality

The following functionality existed in previous versions of the concat module, but was removed in version 2.0.0:

Parameters removed from `concat::fragment`:
* `gnu`
* `backup`
* `group`
* `mode`
* `owner`

The `concat::setup` class has also been removed.

Prior to concat version 2.0.0, if you set the `warn` parameter to a string value of `true`, `false`, 'yes', 'no', 'on', or 'off', the module translated the string to the corresponding boolean value. In concat version 2.0.0 and newer, the `warn_header` parameter treats those values the same as other strings and uses them as the content of your header message. To avoid that, pass the `true` and `false` values as booleans instead of strings.

<a id="limitations"></a>
## Limitations

This module has been tested on [all PE-supported platforms](https://forge.puppetlabs.com/supported#compat-matrix), and no issues have been identified.

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-concat/blob/master/metadata.json)

<a id="development"></a>
## Development

We are experimenting with a new tool for running acceptance tests. It's name is [puppet_litmus](https://github.com/puppetlabs/puppet_litmus) this replaces beaker as the test runner. To run the acceptance tests follow the instructions [here](https://github.com/puppetlabs/puppet_litmus/wiki/Tutorial:-use-Litmus-to-execute-acceptance-tests-with-a-sample-module-(MoTD)#install-the-necessary-gems-for-the-module).

Puppet modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide](https://puppet.com/docs/puppet/latest/contributing.html).

### Contributors

Richard Pijnenburg ([@Richardp82](http://twitter.com/richardp82))

Joshua Hoblitt ([@jhoblitt](http://twitter.com/jhoblitt))

[More contributors](https://github.com/puppetlabs/puppetlabs-concat/graphs/contributors).
