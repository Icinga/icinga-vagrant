Graylog
=======

[![Build Status](https://travis-ci.org/Graylog2/graylog2-puppet.png)](https://travis-ci.org/Graylog2/graylog2-puppet)


Table of Contents
-----------------

1. [Overview](#overview)
1. [Installation](#installation)
    * [Librarian-Puppet](#librarian-puppet)
    * [Puppet Module Tool](#puppet-module-tool)
    * [Manual Installation](#manual-installation)
1. [Usage](#usage)
1. [Authors](#authors)
1. [Credits](#credits)
1. [License](#license)


Overview
--------

This module manages a [Graylog](http://www.graylog.org) setup including the
[server](https://github.com/Graylog2/graylog2-server) and the
[web-interface](https://github.com/Graylog2/graylog2-web-interface).

Supported Graylog versions:

* 1.0, 1.1

Supported platforms:

* Debian 7
* Ubuntu 14.04
* CentOS 6.5


Installation
------------

There is an implicit dependency to Elasticsearch and MongoDB - make sure to
set those up properly before using this module! You can use existing Puppet
modules to do that.

* [elasticsearch/elasticsearch](https://forge.puppetlabs.com/elasticsearch/elasticsearch)
* [puppetlabs/mongodb](https://forge.puppetlabs.com/puppetlabs/mongodb)

### Librarian-Puppet

    mod 'graylog2/graylog2', 'x.x.x'

Check for the latest version!

### Puppet Module Tool

    puppet module install graylog2/graylog2

### Manual Installation

This module depends on:
* [puppetlabs/apt](https://github.com/puppetlabs/puppetlabs-apt)
* [puppetlabs/stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)

So all repositories have to be checked out:

```bash
git clone https://github.com/Graylog2/graylog2-puppet.git modules/graylog2
git clone https://github.com/puppetlabs/puppetlabs-apt.git modules/apt
git clone https://github.com/puppetlabs/puppetlabs-stdlib.git modules/stdlib
```


Usage
-----

A Graylog example including the server and the web-interface component. The
module does **not** setup Elasticsearch and MongoDB so make sure to have those
installed as well!

```puppet
class {'graylog2::repo':
  version => '1.1'
} ->
class {'graylog2::server':
  password_secret    => 'veryStrongSecret',
  root_password_sha2 => 'sha256PasswordHash'
} ->
class {'graylog2::web':
  application_secret => 'veryStrongSecret',
}
```

Installing graylog-radio with default settings (deprecated since Graylog 1.0)

```puppet
class {'graylog2::repo':
  version => '1.1'
}->
class {'graylog2::radio': }
```

Authors
-------

* Johannes Graf ([@grafjo](https://github.com/grafjo))
* Jonathan Buch ([@BuJo](https://github.com/BuJo))
* Sascha Rüssel ([@zivis](https://github.com/zivis))
* Bernd Ahlers ([@bernd](https://github.com/bernd))

Credits
-------

To the community package maintainers. (The [official Graylog packages](https://www.graylog.org/documentation/general/packages/)
are used now.)

* [@hggh](https://github.com/hggh) for providing debs
* [@jaxxstorm](https://github.com/jaxxstorm) for providing rpms

License
-------

graylog2-puppet is released under the MIT License. See the bundled LICENSE file
for details.
