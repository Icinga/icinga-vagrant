[![Build Status](https://travis-ci.org/Icinga/puppet-icinga2.svg?branch=master)](https://travis-ci.org/Icinga/puppet-icinga2)

# Icinga 2 Puppet Module

![Icinga Logo](https://www.icinga.com/wp-content/uploads/2014/06/icinga_logo.png)

#### Table of Contents

1. [Overview][Overview]
2. [Module Description - What the module does and why it is useful][Module description]
3. [Setup - The basics of getting started with icinga2][Setup]
    * [What Icinga 2 affects][]
4. [Usage - Configuration options and additional functionality][Usage]
5. [Reference - An under-the-hood peek at what the module is doing and how][Reference]
    * [Public Classes][]
    * [Private Classes][]
    * [Public defined types][]
    * [Private defined types][]
6. [Development - Guide for contributing to the module][Development]

## Overview

Icinga 2 is a widely used open source monitoring software. This Puppet module helps with installing and managing
configuration of Icinga 2 on multiple operating systems.

### Notices

For Icinga 2 v2.8.0 and higher version v1.3.4 and above is needed and the parameter repositoryd
can set to false. See issue #403.

## Module Description

This module installs and configures Icinga 2 on your Linux or Windows hosts.

By default it uses packages provided by your distribution's repository or
[Chocolatey] on Windows.

The module can also be configured to use [packages.icinga.com] as the primary repository, which enables you to install
Icinga 2 versions that are newer than the ones provided by your distribution's vendor. All features and objects
available in Icinga 2 can be enabled and configured with this module.

## Setup

### What the Icinga 2 Puppet module supports

* Installation of packages
* Configuration of features
* Configuration of objects (also apply rules)
* Service
* MySQL / PostgreSQL Database Schema Import
* Repository Management
* Certification Authority

### Dependencies

This module depends on:

* [puppetlabs/stdlib] >= 4.10.0
* [puppetlabs/concat] >= 2.0.1

Depending on your setup following modules may also be required:

* [puppetlabs/apt] >= 2.0.0
* [puppetlabs/chocolatey] >= 0.7.0
* [puppet/zypprepo] >= 2.0.0

### Limitations

This module has been tested on:

* Ruby >= 1.9
* Debian 7, 8
* Ubuntu 14.04, 16.04
* CentOS/RHEL 6, 7
    * **Caution:** CentOS 6 comes with Ruby 1.8.7 by default
* OracleLinux 7
* FreeBSD 10, 11
* SLES 12
* Windows Server 2012

Other operating systems or versions may work but have not been tested.

It's recommended to enable the future parser when using this module in combination with exported resources.

## Usage

### Installing Icinga 2

The default class `icinga2` installs and configures a basic installation of Icinga 2. The features `checker`, `mainlog`
and `notification` are enabled by default.

By default, your distribution's packages are used to install Icinga 2. On Windows systems we use the [Chocolatey]
package manager.

Use the `manage_repo` parameter to configure the official [packages.icinga.com] repositories.

``` puppet
class { '::icinga2':
  manage_repo => true,
}
```

*Info:* If you are using the [Icinga Web 2](https://github.com/Icinga/puppet-icingaweb2/) Puppet module on the same
server, make sure to disable the repository management for one of the modules!

If you want to manage the version of Icinga 2, you have to disable the package management of this module and handle
packages in your own Puppet code. The attribute manage_repo is also disabled automattically and you have to manage
a repository within icinga in front of the package resource, i.e. for a RedHat system:

``` puppet
yumrepo { 'icinga-stable-release':
  baseurl  => "http://packages.icinga.com/epel/${::operatingsystemmajrelease}/release/",
  descr    => 'ICINGA (stable release for epel)',
  enabled  => 1,
  gpgcheck => 1,
  gpgkey   => 'http://packages.icinga.com/icinga.key',
  before   => Package['icinga2'],
}

package { 'icinga2':
  ensure => latest,
  notify => Class['icinga2'],
}

class { '::icinga2':
  manage_package => false,
}
```

Note: Be careful with this option: Setting `manage_package` to false means that this module will not install any package at
all, including IDO packages!

### Enabling Features

There are two options how you can enable features:

A default set of features is set with the `features` parameter in the `::icinga2` class:

``` puppet
class { '::icinga2':
  manage_repo => true,
  features    => ['checker', 'mainlog', 'command'],
}
```

To enable a feature and change its configuration, declare the specified feature class:

``` puppet
class { '::icinga2::feature::graphite':
  host                   => '10.10.0.15',
  port                   => 2003,
  enable_send_thresholds => true,
  enable_send_metadata   => true,
}
```

Make sure that you enable features **either** in the `::icinga2` class **or** by declaring the feature class.

### Setting up Icinga IDO

The IDO feature can be enabled either in combination with MySQL or PostgreSQL.

Depending on your database you need to enable the feature `icinga2::feature::idomysql` or `icinga2::feature::idopgsql`.

Both features are capable of importing the base schema into the database, however this is disabled by default.
Updating the database schema to another version is currently not supported.

The IDO features require a pre-existing database and an user with permissions to create schema, and edit data

#### MySQL

When using MySQL we recommend the [puppetlabs/mysql] Puppet module to install the database server, create a database
and manage user permissions. Here's an example how you create a MySQL database with the corresponding user with
permissions by using the [puppetlabs/mysql] module:

``` puppet
include ::icinga2
include ::mysql::server

mysql::db { 'icinga2':
  user     => 'icinga2',
  password => 'supersecret',
  host     => '127.0.0.1',
  grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER'],
}

class{ '::icinga2::feature::idomysql':
  user          => 'icinga2',
  password      => 'supersecret',
  database      => 'icinga2',
  import_schema => true,
  require       => Mysql::Db['icinga2'],
}
```

#### PostgreSQL

For PostgreSQL we recommend the [puppetlabs/puppetlabs-postgresql] module. You can install the server, create databases
and manage user permissions with the module. Here's an example on how to use it in combination with Icinga 2:

``` puppet
include ::icinga2
include ::postgresql::server

postgresql::server::db { 'icinga2':
  user     => 'icinga2',
  password => postgresql_password('icinga2', 'supersecret'),
}

class{ '::icinga2::feature::idopgsql':
  user          => 'icinga2',
  password      => 'supersecret',
  database      => 'icinga2',
  import_schema => true,
  require       => Postgresql::Server::Db['icinga2'],
}
```

### Clustering Icinga 2

Icinga 2 can run in three different roles:

* in a master zone which is on top of the hierarchy
* in a satellite zone which is a child of a satellite or master zone
* a standalone client node/zone which works as an agent connected to master and/or satellite zones

To learn more about Icinga 2 Clustering, follow the official docs on [distributed monitoring]. The following examples show
how these roles can be configured using this Puppet module.

#### Master

A Master zone has no parent and is usually also the place where you enable the IDO and notification features. A master
sends configurations over the Icinga 2 protocol to satellites and/or clients.

More detailed examples can be found in the [examples] directory.

Ths examples creates the configuration for a master that has one satellite connected. A global zone is created for
templates, and all features of a typical master are enabled.

``` puppet
class { '::icinga2':
  confd     => false,
  features  => ['checker','mainlog','notification','statusdata','compatlog','command'],
  constants => {
    'ZoneName' => 'master',
  },
}

class { '::icinga2::feature::api':
  accept_commands => true,
  # when having multiple masters, you should enable:
  # accept_config => true,
  endpoints       => {
    'master.example.org'    => {},
    'satellite.example.org' => {
      'host' => '172.16.2.11'
    }
  },
  zones           => {
    'master' => {
      'endpoints' => ['master.example.org'],
    },
    'dmz'    => {
      'endpoints' => ['satellite.example.org'],
      'parent'    => 'master',
    },
  }
}

icinga2::object::zone { 'global-templates':
  global => true,
}
```

#### Satellite

A satellite has a parent zone and one or multiple child zones. Satellites are usually created to distribute the
monitoring load or to reach delimited zones in the network. A satellite either executes checks itself or delegates them
to a client.

The satellite has less features enabled, but executes checks similar to a master. It connects to a master zone, and to
and satellite or client below in the hierarchy. As parent acts either the master zone, or another satellite zone.

``` puppet
class { '::icinga2':
  confd     => false,
  features  => ['checker','mainlog'],
  constants => {
    'ZoneName' => 'dmz',
  },
}

class { '::icinga2::feature::api':
  accept_config   => true,
  accept_commands => true,
  endpoints       => {
    'satellite.example.org' => {},
    'master.example.org'    => {
      'host' => '172.16.1.11',
    },
  },
  zones           => {
    'master' => {
      'endpoints' => ['master.example.org'],
    },
    'dmz'    => {
      'endpoints' => ['satellite.example.org'],
      'parent'    => 'master',
    },
  }
}

icinga2::object::zone { 'global-templates':
  global => true,
}
```

#### Client

Icinga 2 runs as a client usually on each of your servers. It receives config or commands from a satellite or master
zones and runs the checks that have to be executed locally.

The client is connected to the satellite, which is the direct parent zone.

``` puppet
class { '::icinga2':
  confd     => false,
  features  => ['checker','mainlog'],
}

class { '::icinga2::feature::api':
  pki             => 'none',
  accept_config   => true,
  accept_commands => true,
  endpoints       => {
    'NodeName'              => {},
    'satellite.example.org' => {
      'host' => '172.16.2.11',
    }
  },
  zones           => {
    'ZoneName' => {
      'endpoints' => ['NodeName'],
      'parent'    => 'dmz',
    },
    'dmz'      => {
      'endpoints' => ['satellite.example.org'],
    }
  }
}

icinga2::object::zone { 'global-templates':
  global => true,
}
```

### Config Objects

With this module you can create almost every object that Icinga 2 knows about. When creating objects some parameters are
required. This module sets the same requirements as Icinga 2 does. When creating an object you must set a target for the
configuration.

Here are some examples for some object types:

#### Host
``` puppet
icinga2::object::host { 'srv-web1.fqdn.com':
  display_name  => 'srv-web1.fqdn.com',
  address       => '127.0.0.1',
  address6      => '::1',
  check_command => 'hostalive',
  target        => '/etc/icinga2/conf.d/srv-web1.fqdn.com.conf',
}
```

#### Service
``` puppet
icinga2::object::service { 'uptime':
  host_name      => 'srv-web1.fqdn.com',
  display_name   => 'Uptime',
  check_command  => 'check_uptime',
  check_interval => '600m',
  groups         => ['uptime', 'linux'],
  target         => '/etc/icinga2/conf.d/uptime.conf',
}
```

#### Hostgroup
``` puppet
icinga2::object::hostgroup { 'monitoring-hosts':
  display_name => 'Linux Servers',
  groups       => [ 'linux-servers' ],
  target       => '/etc/icinga2/conf.d/groups2.conf',
  assign       => [ 'host.vars.os == "linux"' ],
}
```

#### Parsing Configuration

To generate a valid Icinga 2 configuration all object attributes are parsed. This simple parsing algorithm takes a
decision for each attribute, whether part of the string is to be quoted or not, and how an array or dictionary is to be
formatted.

Parsing of a single attribute can be disabled by tagging it with -: at the front of the string.
```
   attr => '-:"unparsed string with quotes"'
```
An array, a hash or a string can be assigned to an object attribute. True and false are also valid values.

Hashes and arrays are created recursively, and all parts – such as single items of an array, keys and its values
are parsed separately as strings.

Strings are parsed in chunks, by splitting the original string into separate substrings at specific keywords (operators)
such as `+`, `-`, `in`, `&&`, `||`, etc.

**NOTICE**: This splitting only works for keywords that are surrounded by whitespace, e.g.:
```
   attr => 'string1 + string2 - string3'
```

The algorithm will loop over the parameter and start by splitting it into 'string1' and 'string2 - string3'.
'string1' will be passed to the sub function 'value_types' and then the algorithm will continue parsing the rest of the
string ('string2 - string3'), splitting it, passing it to value_types, etc.

Brackets are parsed for expressions:
```
  attr => '3 * (value1 - value2) / 2'
```

The parser also detects function calls and will parse all parameters separately.
```
  attr => 'function(param1, param2, ...)'
```

True and false can be used as either booleans or strings.
```
  attrs => true or  attr => 'true'
```

In Icinga you can write your own lambda functions with {{ ... }}. For Puppet use:
```
  attrs => '{{ ... }}'
```

The parser analyzes which parts of the string have to be quoted and which do not.

As a general rule, all fragments are quoted except for the following:

* Boolean: `true`, `false`
* Numbers: `3` or `2.5`
* Time Intervals: `3m` or `2.5h`  (s = seconds, m = minutes, h = hours, d = days)
* Functions: `{{ ... }}` or function `()` `{}`
* All constants, which are declared in the constants parameter in main class `icinga2`
    * `NodeName`
* Names of attributes that belong to the same type of object:
    * e.g. `name` and `check_command` for a host object
* All attributes or variables (custom attributes) from the host, service or user contexts:
    * `host.name`, `service.check_command`, `user.groups`, ...

###### What isn't supported?

It's not currently possible to use arrays or dictionaries in a string, like
```
  attr => 'array1 + [ item1, item2, ... ]'
```

Assignments other than simple attribution are not currently possible either, e.g. building something like
```
  vars += config
```
but you can use the following instead:
```
  vars = vars + config
```

#### Reading objects from hiera data

The following example is for puppet 4 and higher. It shows how icinga2 objects can be read from
a hiera datastore. See also examples/objects_from_hiera.pp.

```
class { 'icinga2':
  manage_repo => true,
}

$defaults = lookup('monitoring::defaults')

lookup('monitoring::objects').each |String $object_type, Hash $content| {
  $content.each |String $object_name, Hash $object_config| {
    ensure_resource(
      $object_type,
      $object_name,
      deep_merge($defaults[$object_type], $object_config))
  }
}
```

The datastore could be like:

```
---
monitoring::objects:
  'icinga2::object::host':
    centos7.localdomain:
      address: 127.0.0.1
      vars:
        os: Linux
  'icinga2::object::service':
    ping4:
      check_command: ping4
      apply: true
      assign:
        - host.address
    ssh:
      check_command: ssh
      apply: true
      assign:
        - host.address && host.vars.os == Linux

monitoring::defaults:
  'icinga2::object::host':
    import:
      - generic-host
    target: /etc/icinga2/conf.d/hosts.conf
  'icinga2::object::service':
    import:
      - generic-service
    target: /etc/icinga2/conf.d/services.conf
```


### Apply Rules

Some objects support to be applied to other objects. To create a simple apply rule you must set the `apply` parameter to
`true`. If this parameter is set to a string, this string will be used to build an `apply for` loop. A service object
always targets a host object. All other objects need to explicitly set an `apply_target`

Apply a SSH service to all Linux hosts:

``` puppet
icinga2::object::service { 'SSH':
  target        => '/etc/icinga2/conf.d/test.conf',
  apply         => true,
  assign        => [ 'host.vars.os == Linux' ],
  ignore        => [ 'host.vars.os == Windows' ],
  display_name  => 'Test Service',
  check_command => 'ssh',
}
```

Apply notifications to services:

``` puppet
icinga2::object::notification { 'testnotification':
  target       => '/etc/icinga2/conf.d/test.conf',
  apply        => true,
  apply_target => 'Service',
  assign       => [ 'host.vars.os == Linux' ],
  ignore       => [ 'host.vars.os == Windows' ],
  user_groups  => ['icingaadmins']
}
```

Assign all Linux hosts to a hostgroup:
``` puppet
icinga2::object::hostgroup { 'monitoring-hosts':
  display_name => 'Linux Servers',
  groups       => [ 'linux-servers' ],
  target       => '/etc/icinga2/conf.d/groups2.conf',
  assign       => [ 'host.vars.os == "linux"' ],
}
```

A loop to create HTTP services for all vHosts of a host object:
``` puppet
icinga2::object::service { 'HTTP':
  target        => '/etc/icinga2/conf.d/http.conf',
  apply         => 'http_vhost => config in host.vars_http_vhost',
  assign        => [ 'host.vars.os == Linux' ],
  display_name  => 'HTTP Service',
  check_command => 'http',
}
```

### CA and Certificates

Handling the CA and certificates is an important part of Icinga 2, because the communication between Icinga processes
requires SSL/TLS client certificates. This module offers multiple choices to configure this.

#### CA on your Icinga Master

One of your Icinga master needs to behave as a CA. With the class `icinga2::pki::ca` you can do following to fulfil
this requirement:

* Use the the `icinga2` CLI to generate a complete new CA
``` puppet
include ::icinga2
class { '::icinga2::pki::ca':
}
```

* Set a custom content of the CA certificate and key
``` puppet
include ::icinga2
class { '::icinga2::pki::ca':
  ca_cert => '-----BEGIN CERTIFICATE----- ...',
  ca_key  => '-----BEGIN RSA PRIVATE KEY----- ...',
}
```

* Transfer a CA certificate and key from an existing CA by using the file resource:
``` puppet
include ::icinga2
file { '/var/lib/icinga2/ca/ca.crt':
  source => '...',
  tag    => 'icinga2::config::file',
}

file { '/var/lib/icinga2/ca/ca.key':
  source => '...',
  tag    => 'icinga2::config::file',
}
```

* Create a new CA with the `icinga2` CLI command and a certificate signed by this new CA. This is useful especially when
seting up a new Icinga 2 master.
```puppet
class { '::icinga2':
  constants => {
    'TicketSalt'   => '5a3d695b8aef8f18452fc494593056a4',
  }
}

class { '::icinga2::pki::ca': }

class { '::icinga2::feature::api':
  pki             => 'none',
  endpoints       => {
    'localhost' => {
      'host' => 'localhost',
    }
  },
  zones           => {
    'master' => {
      'endpoints' => ['localhost']
    }
  }
}
```

If you are looking for an option to use your Puppet CA, have a look to the
[Client/Satellite Certificates](#clientsatellite-certificates) section.

#### Client/Satellite Certificates

In addition to the master, each client and satellite needs valid certificates to communicate with other Icinga 2
instances. This module offers following options to create these certificates:

* Use Puppet's CA and its client certificates. This is convenient since you don't need to maintain an additional CA.
``` puppet
include ::icinga2::feature::api
```

* Use a custom function implemented in this module to generate a certificate. This feature will to the following:
  * Generate a key and certificate based on the FQDN of the host
  * Save the certificate of another Icinga 2 instance, usually the Icinga master where your Icinga CA is located
  * Generate a ticket based on the TicketSalt
  * Request a signed certificate at your Icinga CA

``` puppet
class { '::icinga2::feature::api':
  pki             => 'icinga2',
  ca_host         => 'icinga2-master.example.com',
  ticket_salt     => '5a3d695b8aef8f18452fc494593056a4',
  accept_config   => true,
  accept_commands => true,
  endpoints       => {
    'NodeName'                   => {},
    'icinga2-master.example.com' => {
      'host' => '192.168.56.103',
    }
  },
  zones           => {
    'NodeName' => {
      'endpoints' => ['NodeName'],
      'parent'    => 'master',
    },
    'master' => {
      'endpoints' => ['icinga2-master.example.com']
    }
  }
}
```

* Use custom file resources to transfer your own certificate and key
``` puppet
class { '::icinga2::feature::api':
  pki => 'none',
}

file { "/etc/icinga2/pki/${::fqdn}.crt":
  ensure => file,
  tag    => 'icinga2::config::file,
  source => "puppet:///modules/profiles/certificates/${::fqdn}.crt",
}

file { "/etc/icinga2/pki/${::fqdn}.key":
  ensure => file,
  tag    => 'icinga2::config::file,
  source => "puppet:///modules/profiles/private_keys/${::fqdn}.key",
}
```

* Set a custom content for the certificate and key

``` puppet
class { '::icinga2::feature::api':
  pki         => 'none',
  ssl_cacert  => '-----BEGIN CERTIFICATE----- ...',
  ssl_key     => '-----BEGIN RSA PRIVATE KEY----- ...',
  ssl_cert    => '-----BEGIN CERTIFICATE----- ...',
}
```

* Fine tune TLS / SSL settings

``` puppet
class { '::icinga2::feature::api':
  ssl_protocolmin => 'TLSv1.2',
  ssl_cipher_list => 'HIGH:MEDIUM:!aNULL:!MD5:!RC4',
}
```

### Custom configuration

Sometimes it's necessary to cover very special configurations, that you cannot handle with this module. In this case you
can use the `icinga2::config::file` tag on your file resource. The module collects all file resource types with this
tag and triggers a reload of Icinga 2 on a file change.

``` puppet
include ::icinga2
file { '/etc/icinga2/conf.d/for-loop.conf':
  ensure => file,
  source => '...',
  tag    => 'icinga2::config::file',
}
```

If you want to add custom configuration fragments to existing config files, you can do this with
`icinga2::config::fragment`. It adds content into a specified target to the position you set in the order parameter.
You can use also Puppet templates to set the content of the config fragment.

For example, you can add custom functions to existing config files:

``` puppet
include ::icinga2

icinga2::object::service { 'load':
  display_name  => 'Load',
  apply         => true,
  check_command => 'load',
  assign        => ['vars.os == Linux'],
  target        => '/etc/icinga2/conf.d/service_load.conf',
  order         => '30',
}

icinga2::config::fragment { 'load-function':
  target => '/etc/icinga2/conf.d/service_load.conf',
  order => '10',
  content => 'vars.load_wload1 = {{
    if (get_time_period("backup").is_inside) {
      return 20
    } else {
      return 5
    }
  }}',
}
```

## Reference

- [**Public classes**](#public-classes)
    - [Class: icinga2](#class-icinga2)
    - [Class: icinga2::feature::checker](#class-icinga2featurechecker)
    - [Class: icinga2::feature::mainlog](#class-icinga2featuremainlog)
    - [Class: icinga2::feature::notification](#class-icinga2featurenotification)
    - [Class: icinga2::feature::command](#class-icinga2featurecommand)
    - [Class: icinga2::feature::compatlog](#class-icinga2featurecompat)
    - [Class: icinga2::feature::graphite](#class-icinga2featuregraphite)
    - [Class: icinga2::feature::livestatus](#class-icinga2featurelivestatus)
    - [Class: icinga2::feature::opentsdb](#class-icinga2featureopentsdb)
    - [Class: icinga2::feature::perfdata](#class-icinga2featureperfdata)
    - [Class: icinga2::feature::statusdata](#class-icinga2featurestatusdata)
    - [Class: icinga2::feature::syslog](#class-icinga2featuresyslog)
    - [Class::icinga2::feature::debuglog](#class-icinga2featuredebuglog)
    - [Class::icinga2::feature::gelf](#class-icinga2featuregelf)
    - [Class::icinga2::feature::influxdb](#class-icinga2featureinfluxdb)
    - [Class::icinga2::feature::api](#class-icinga2featureapi)
    - [Class::icinga2::feature::idopgsql](#class-icinga2featureidopgsql)
    - [Class::icinga2::feature::idomysql](#class-icinga2featureidomysql)
    - [Class::icinga2::pki::ca](#class-icinga2pkica)
- [**Private classes**](#private-classes)
    - [Class: icinga2::repo](#class-icinga2repo)
    - [Class: icinga2::install](#class-icinga2install)
    - [Class: icinga2::config](#class-icinga2config)
    - [Class: icinga2::service](#class-icinga2service)
- [**Public defined types**](#public-defined-types)
    - [Defined type: icinga2::object::endpoint](#defined-type-icinga2objectendpoint)
    - [Defined type: icinga2::object::zone](#defined-type-icinga2objectzone)
    - [Defined type: icinga2::object::apiuser](#defined-type-icinga2objectapiuser)
    - [Defined type: icinga2::object::checkcommand](#defined-type-icinga2objectcheckcommand)
    - [Defined type: icinga2::object::host](#defined-type-icinga2objecthost)
    - [Defined type: icinga2::object::hostgroup](#defined-type-icinga2objecthostgroup)
    - [Defined type: icinga2::object::dependency](#defined-type-icinga2objectdependency)
    - [Defined type: icinga2::object::timeperiod](#defined-type-icinga2objecttimeperiod)
    - [Defined type: icinga2::object::usergroup](#defined-type-icinga2objectusergroup)
    - [Defined type: icinga2::object::notificationcommand](#defined-type-icinga2objectnotificationcommand)
    - [Defined type: icinga2::object::notification](#defined-type-icinga2objectnotification)
    - [Defined type: icinga2::object::service](#defined-type-icinga2objectservice)
    - [Defined type: icinga2::object::servicegroup](#defined-type-icinga2objectservicegroup)
    - [Defined type: icinga2::object::downtime](#defined-type-icinga2objectdowntime)
    - [Defined type: icinga2::object::scheduleddowntime](#defined-type-icinga2objectscheduleddowntime)
    - [Defined type: icinga2::object::eventcommand](#defined-type-icinga2objecteventcommand)
    - [Defined type: icinga2::object::checkresultreader](#defined-type-icinga2objectcheckresultreader)
    - [Defined type: icinga2::object::compatlogger](#defined-type-icinga2objectcompatlogger)
    - [Defined type: icinga2::config::fragment](#defined-type-icinga2configfragment)
- [**Private defined types**](#private-defined-types)
    - [Defined type: icinga2::feature](#defined-type-icinga2feature)
    - [Defined type: icinga2::object](#defined-type-icinga2object)

### Public Classes

#### Class: `icinga2`

The default class of this module. It handles the basic installation and configuration of Icinga 2. When you declare this
class, Puppet will do the following:

* Install Icinga 2
* Place a default configuration for the Icinga 2 daemon
* Keep the default configuration of the Icinga 2 package
* Start Icinga 2 and enable the service

This class can be declared without adjusting any parameter:

``` puppet
class { '::icinga2': }
```

**Parameters within `icinga2`:**

##### `ensure`
Defines if the service should be `running` or `stopped`. Defaults to `running`

##### `enable`
If set to `true` the Icinga 2 service will start on boot. Defaults to `true`.

##### `manage_repo`
When set to `true` this module will install the [packages.icinga.com] repository. With this official repo
you can get the latest version of Icinga. When set to `false` the operating systems default will be used. As the Icinga
Project does not offer a [Chocolatey] repository, you will get a warning if you enable this parameter on Windows.
Default is `false`. NOTE: will be ignored if manage_package is set to false.

##### `manage_package`
If set to false packages aren't managed. Defaults to `true`.

##### `manage_service`
Lets you decide if the Icinga 2 daemon should be reloaded when configuration files have changed. Defaults to `true`

##### `features`
A list of features to enable by default. Defaults to `[checker, mainlog, notification]`

##### `purge_features`
Define if configuration files for features not managed by Puppet should be purged. Defaults to true.

##### `constants`
Hash of constants. Defaults are set in the params class. Your settings will be merged with the defaults.

##### `plugins`
A list of the ITL plugins to load. Defaults to `[ 'plugins', 'plugins-contrib', 'windows-plugins', 'nscp' ]`.

##### `confd`
`conf.d` is the directory where Icinga 2 stores its object configuration by default. To disable it,
set this parameter to `false`. By default this parameter is `true`. It's also possible to assign your
own directory. This directory and must be managed outside of this module as file resource
with tag icinga2::config::file.

##### `repositoryd`
`repository.d` is removed since Icinga 2 2.8.0, set to true (default) will handle the directory.
This Parameter will change to false by default in v2.0.0 and will be removed in the future.

#### Class: `icinga2::feature::checker`
Enables or disables the `checker` feature.

**Parameters of `icinga2::feature::checker`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `checker` should be enabled. Defaults to `present`.

##### `concurrent_checks`
The maximum number of concurrent checks. Defaults to `512`.

#### Class: `icinga2::feature::mainlog`
Enables or disables the `mainlog` feature.

**Parameters of `icinga2::feature::mainlog`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `mainlog` should be enabled. Defaults to `present`.

##### `severity`
Sets the severity of the `mainlog` feature. Can be set to:

* `information`
* `notice`
* `warning`
* `debug`

Defaults to `information`

##### `path`
Absolute path to the logging file. Default depends on platform:

* Linux: `/var/log/icinga2/icinga2.log`
* Windows: `C:/ProgramData/icinga2/var/log/icinga2/icinga2.log`

#### Class: `icinga2::feature::notification`
Enables or disables the `notification` feature.

**Parameters of `icinga2::feature::notification`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `notification` should be enabled. Defaults to `present`.

##### `enable_ha`
Notifications are load-balanced amongst all nodes in a zone. By default this functionality is enabled. If your nodes should send out notifications independently from any other nodes (this will cause duplicated notifications if not properly handled!), you can set enable_ha to false.

#### Class: `icinga2::feature::command`
Enables or disables the `command` feature.

**Parameters of `icinga2::feature::command`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `command` should be enabled. Defaults to `present`.

##### `commandpath`
Absolute path to the command pipe. Default depends on platform:

* Linux: `/var/run/icinga2/cmd/icinga2.cmd`
* Windows: `C:/ProgramData/icinga2/var/run/icinga2/cmd/icinga2.cmd`

#### Class: `icinga2::feature::compatlog`
Enables or disables the `compatlog` feature.

**Parameters of `icinga2::feature::compatlog`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `compatlog` should be enabled. Defaults to `present`.

##### `commandpath`
Absolute path to the command pipe. Default depends on platform:

* Linux: `/var/run/icinga2/cmd/icinga2.cmd`
* Windows: `C:/ProgramData/icinga2/var/run/icinga2/cmd/icinga2.cmd`

##### `log_dir`
Absolute path to the log directory. Default depends on platform:

* Linux: `/var/log/icinga2/compat`
* Windows: `C:/ProgramData/icinga2/var/log/icinga2/compat`

##### `rotation_method`
Sets how often should the log file be rotated. Valid options are:

* `HOURLY`
* `DAILY`
* `WEEKLY`
* `MONTHLY`

Defaults to `DAILY`

#### Class: `icinga2::feature::graphite`
Enables or disables the `graphite` feature.

**Parameters of `icinga2::feature::graphite`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `graphite` should be enabled. Defaults to `present`.

##### `host`
Graphite Carbon host address. Defaults to `127.0.0.1`.

##### `port`
Graphite Carbon port. Defaults to `2003`.

##### `host_name_template`
Template for metric path of hosts. Defaults to `icinga2.$host.name$.host.$host.check_command$`.

##### `service_name_template`
Template for metric path of services. Defaults to `icinga2.$host.name$.services.$service.name$.$service.check_command$`.

##### `enable_send_thresholds`
Send thresholds as metrics. Defaults to false.

##### `enable_send_metadata`
Send metadata as metrics. Defaults to false.

#### Class: `icinga2::feature::livestatus`
Enables or disables the `livestatus` feature.

**Parameters of `icinga2::feature::livestatus`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `livestatus` should be enabled. Defaults to `present`.

##### `socket_type`
Specifies the socket type. Can be either 'tcp' or 'unix'. Defaults to 'unix'

##### `bind_host`
IP address to listen for connections. Only valid when socket_type is `tcp`. Defaults to `127.0.0.1`

##### `bind_port`
Port to listen for connections. Only valid when socket_type is `tcp`. Defaults to `6558`

##### `socket_path`
Specifies the path to the UNIX socket file. Only valid when socket_type is `unix`. Default depends on platform:

* Linux: `/var/run/icinga2/cmd/livestatus`
* Windows: `C:/ProgramData/icinga2/var/run/icinga2/cmd/livestatus`

##### `compat_log_path`
Required for historical table queries. Requires `CompatLogger` feature to be enabled. Default depends platform:

Linux: `var/icinga2/log/icinga2/compat`
Windows: `C:/ProgramData/icinga2/var/log/icinga2/compat`

#### Class: `icinga2::feature::opentsdb`
Enables or disables the `opentsdb` feature.

**Parameters of `icinga2::feature::opentsdb`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `opentsdb` should be enabled. Defaults to `present`.

##### `host`
OpenTSDB host address. Defaults to `127.0.0.1`

##### `port`
OpenTSDB port. Defaults to `4242`

#### Class: `icinga2::feature::perfdata`
Enables or disables the `perfdata` feature.

**Parameters of `icinga2::feature::perfdata`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `perfdata` should be enabled. Defaults to `present`.

##### `host_perfdata_path`
Absolute path to the perfdata file for hosts. Default depends on platform:
* Linux: `/var/spool/icinga2/host-perfdata`
* Windows: `C:/ProgramData/icinga2/var/spool/icinga2/host-perfdata`

##### `service_perfdata_path`
Absolute path to the perfdata file for services. Default depends on platform:
* Linux: `/var/spool/icinga2/service-perfdata`
* Windows: `C:/ProgramData/icinga2/var/spool/icinga2/service-perfdata`

###### `host_temp_path`
Path to the temporary host file. Defaults depends on platform:
* Linux: `/var/spool/icinga2/tmp/host-perfdata`
* Windows: `C:/ProgramData/icinga2/var/spool/icinga2/tmp/host-perfdata`

##### `service_temp_path`
Path to the temporary service file. Defaults depends on platform:
* Linux: `/var/spool/icinga2/tmp/host-perfdata`
* Windows: `C:/ProgramData/icinga2/var/spool/icinga2/tmp/host-perfdata`

##### `host_format_template`
Host Format template for the performance data file. Defaults to a template that's suitable for use with PNP4Nagios.

##### `service_format_template`
Service Format template for the performance data file. Defaults to a template that's suitable for use with PNP4Nagios.

##### `rotation_interval`
Rotation interval for the files specified in `{host,service}_perfdata_path`. Can be written in minutes or seconds,
i.e. `1m` or `15s`. Defaults to `30s`

#### Class: `icinga2::feature::statusdata`
Enables or disables the `statusdata` feature.

**Parameters of `icinga2::feature::statusdata`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `statusdata` should be enabled. Defaults to `present`.

##### `status_path`
Absolute path to the status.dat file. Default depends on platform:
* Linux: `/var/cache/icinga2/status.dat`
* Windows: `C:/ProgramData/icinga2/var/cache/icinga2/status.dat`

##### `object_path`
Absolute path to the object.cache file. Default depends on platform:
* Linux: `/var/cache/icinga2/object.cache`
* Windows: `C:/ProgramData/icinga2/var/cache/icinga2/object.cache`

##### `update_interval`
Interval in seconds to update both status files. You can also specify it in minutes with the letter m or in seconds
with s. Defaults to `30s`

#### Class: `icinga2::feature::syslog`
Enables or disables the `syslog` feature.

**Parameters of `icinga2::feature::syslog`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `syslog` should be enabled. Defaults to `present`.

##### `severity`
Set severity level for logging to syslog. Available options are:

* `information`
* `notice`
* `warning`
* `debug`

Defaults to `warning`

#### Class: `icinga2::feature::debuglog`
Enables or disables the `debuglog` feature.

**Parameters of `icinga2::feature::debuglog`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `debuglog` should be enabled. Defaults to `present`.

##### `path`
Absolute path to the log file. Default depends on platform:
* Linux: `/var/log/icinga2/debug.log`
* Windows: `C:/ProgramData/icinga2/var/log/icinga2/debug.log`

#### Class: `icinga2::feature::gelf`
Enables or disables the `gelf` feature.

**Parameters of `icinga2::feature::gelf`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `gelf` should be enabled. Defaults to `present`.

##### `host`
GELF receiver host address. Defaults to `127.0.0.1`

##### `port`
GELF receiver port. Defaults to `12201`

##### `source`
Source name for this instance. Defaults to `icinga2`

##### `enable_send_perfdata`
Enable performance data for *CHECK RESULT* events. Defaults to `false`.

#### Class: `icinga2::feature::influxdb`
Enables or disables the `influxdb` feature.

**Parameters of `icinga2::feature::influxdb`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `influxdb` should be enabled. Defaults to `present`.

##### `host`
InfluxDB host address. Defaults to `127.0.0.1`

##### `port`
InfluxDB HTTP port. Defaults to `8086`

##### `database`
InfluxDB database name. Defaults to `icinga2`

##### `username`
InfluxDB user name. Defaults to `undef`

##### `password`
InfluxDB user password. Defaults to `undef`

##### `enable_ssl`
Either enable or disable SSL. Other SSL parameters are only affected if this is set to `true`. Defaults to `false`.

##### `pki`
SSL settings will be set depending on this parameter.

* `puppet` Use puppet certificates. This will copy the ca.pem, certificate and key generated by Puppet.
* `custom` Set custom paths for certificate, key and CA
* `false` Disable SSL (default)

##### `ssl_ca_cert`
CA certificate to validate the remote host. Only valid if ssl is set to `custom`. Defaults to `undef`

##### `ssl_cert`
Host certificate to present to the remote host for mutual verification. Only valid if ssl is set to 'custom'.
Defaults to `undef`

##### `ssl_key`
Host key to accompany the ssl_cert. Only valid if ssl is set to `custom`. Defaults to `undef`

##### `host_measurement`
The value of this is used for the measurement setting in host_template. Defaults to  `$host.check_command$`

##### `host_tags`
Tags defined in this hash will be set in the host_template.

``` puppet
class { '::icinga2::feature::influxdb':
  host_measurement => '$host.check_command$',
  host_tags        => { hostname => '$host.name$' },
}
```

##### `service_measurement`
The value of this is used for the measurement setting in host_template. Defaults to  `$service.check_command$`

##### `service_tags`
Tags defined in this hash will be set in the service_template.

``` puppet
class { '::icinga2::feature::influxdb':
  service_measurement => '$service.check_command$',
  service_tags        => { hostname => '$host.name$', service => '$service.name$' },
}
```

##### `enable_send_thresholds`
Whether to send warn, crit, min & max tagged data. Defaults to `false`

##### `enable_send_metadata`
Whether to send check metadata e.g. states, execution time, latency etc. Defaults to `false`

##### `flush_interval`
How long to buffer data points before transferring to InfluxDB. Defaults to `10s`

##### `flush_threshold`
How many data points to buffer before forcing a transfer to InfluxDB. Defaults to `1024`


#### Class: `icinga2::feature::api`
Enables or disables the `api` feature.

**Parameters of `icinga2::feature::api`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `api` should be enabled. Defaults to `present`.

##### `pki`
Provides multiple sources for the certificate and key.

* `puppet` Copies the key, cert and CA cert from the Puppet ssl directory to the Icinga pki directory.
  * Linux: `/etc/icinga2/pki`
  * Windows: `C:/ProgramData/icinga2/etc/icinga2/pki`
* `icinga2` Uses the icinga2 CLI to generate a Certificate and Key The ticket is generated on the Puppet master by using
the configured 'ticket_salt' in a custom function.
* `none` Does nothing and you either have to manage the files yourself as file resources or use the `ssl_key`, `ssl_cert`,
`ssl_ca` parameters.
* `ca` (**deprecated**) Includes the `::icinga2::pki::ca` class to generate a fresh CA and generates an SSL certificate and key signed by
this new CA.

Defaults to `puppet`

##### `ssl_key_path`
Location of the private key. Default depends on your platform:

* Linux `/etc/icinga2/pki/NodeName.key`
* Windows `C:/ProgramData/icinga2/etc/icinga2/pki/NodeName.key`

The Value of `NodeName` comes from the corresponding constant.

##### `ssl_cert_path`
Location of the certificate. Default depends on your platform:

* Linux `/etc/icinga2/pki/NodeName.crt`
* Windows `C:/ProgramData/icinga2/etc/icinga2/pki/NodeName.crt`

The Value of `NodeName` comes from the corresponding constant.

##### `ssl_csr_path`
Location of the certificate signing request. Default depends on your platform:

* Linux: `/etc/icinga2/pki/NodeName.csr`
* Windows `C:/ProgramData/icinga2/etc/icinga2/pki/NodeName.csr`

The Value of `NodeName` comes from the corresponding constant.

##### `ssl_cacert_path`
Location of the CA certificate. Default depends on your platform:

* Linux: `/etc/icinga2/pki/ca.crt`
* Windows `C:/ProgramData/icinga2/etc/icinga2/pki/ca.crt`

##### `accept_config`
Accept zone configuration. Defaults to `false`

##### `accept_commands`
Accept remote commands. Defaults to `false`

##### `ca_host`
This host will be connected to request the certificate. Set this if you use the `icinga2` pki.

##### `ca_port`
Port of the 'ca_host'. Defaults to `5665`

##### `ticket_salt`
Salt to use for ticket generation. The salt is stored to api.conf if `none` or `ca` is chosen for `pki`.
Defaults to constant `TicketSalt`.

##### `endpoints`
Hash to configure endpoint objects. Defaults to `{ 'NodeName' => {} }`. `NodeName` is a Icinga 2 constant.

##### `zones`
Hash to configure zone objects. Defaults to `{ 'ZoneName' => {'endpoints' => ['NodeName']} }`. `ZoneName` and `NodeName`
are Icinga 2 constants.

##### `ssl_protocolmin`
Minimal TLS version to require. Default undef (e.g. `TLSv1.2`)

##### `ssl_cipher_list`
List of allowed TLS ciphers, to fine tune encryption. Default undef (e.g. `HIGH:MEDIUM:!aNULL:!MD5:!RC4`)

##### `bind_host`
The IP address the api listener will be bound to. (e.g. 0.0.0.0)

##### `bind_port`
The port the api listener will be bound to. (e.g. 5665)

#### Class: `icinga2::feature::idopgsql`
Enables or disables the `ido-pgsql` feature.

**Parameters of `icinga2::feature::idopgsql`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `ido-pgsql` should be enabled. Defaults to `present`.

##### `host`
PostgreSQL database host address. Defaults to `127.0.0.1`

##### `port`
PostgreSQL database port. Defaults to `3306`

##### `user`
PostgreSQL database user with read/write permission to the icinga database. Defaults to `icinga`

##### `password`
PostgreSQL database user's password. Defaults to `icinga`

##### `database`
PostgreSQL database name. Defaults to `icinga`

##### `table_prefix`
PostgreSQL database table prefix. Defaults to `icinga_`

##### `import_schema`
Whether to import the PostgreSQL schema or not. Defaults to `false`

#### Class: `icinga2::feature::idomysql`
Enables or disables the `gelf` feature.

**Parameters of `icinga2::feature::idomysql`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature `ido-mysql` should be enabled. Defaults to `present`.

##### `host`
MySQL database host address. Defaults to `127.0.0.1`

##### `port`
MySQL database port. Defaults to `3306`

##### `socket_path`
MySQL socket path.

##### `user`
MySQL database user with read/write permission to the icinga database. Defaults to `icinga`

##### `password`
MySQL database user's password. Defaults to `icinga`

##### `database`
MySQL database name. Defaults to `icinga`

##### `ssl`
SSL settings will be set depending on this parameter:
* `puppet` Use puppet certificates
* `custom` Set custom paths for certificate, key and CA
* `false` Disable SSL (default)

##### `ssl_key`
MySQL SSL client key file path. Only valid if ssl is set to `custom`.

##### `ssl_cert`
MySQL SSL certificate file path. Only valid if ssl is set to `custom`.

##### `ssl_ca`
MySQL SSL certificate authority certificate file path. Only valid if ssl is set to `custom`.

##### `ssl_capath`
MySQL SSL trusted SSL CA certificates in PEM format directory path. Only valid if ssl is enabled.

##### `ssl_cipher`
MySQL SSL list of allowed ciphers. Only valid if ssl is enabled.

##### `table_prefix`
MySQL database table prefix. Defaults to `icinga_`

##### `instance_name`
Unique identifier for the local Icinga 2 instance. Defaults to `default`

##### `instance_description`
Description for the Icinga 2 instance.

##### `enable_ha`
Enable the high availability functionality. Only valid in a cluster setup. Defaults to `true`

##### `failover_timeout`
Set the fail-over timeout in a HA cluster. Must not be lower than 60s. Defaults to `60s`

##### `cleanup`
Hash with items for historical table cleanup.

##### `categories`
Array of information types that should be written to the database.

##### `import_schema`
Whether to import the MySQL schema or not. Defaults to `false`

#### Class: `icinga2::pki::ca`
This class provides multiple ways to create the CA used by Icinga 2. By default it will create a CA by using the
Icinga 2 CLI. If you want to use your own CA you will either have to transfer it by using a file resource or you can
set the content of your certificate and key in this class.

**Parameters of `icinga2::pki::ca`:**

##### `ca_cert`
Content of the CA certificate. If this is unset, a certificate will be generated with the Icinga 2 CLI.

##### `ca_key`
Content of the CA key. If this is unset, a key will be generated with the Icinga 2 CLI.

##### `ssl_key_path`
Location of the private key. Default depends on your platform:

* Linux `/etc/icinga2/pki/NodeName.key`
* Windows `C:/ProgramData/icinga2/etc/icinga2/pki/NodeName.key`

The Value of `NodeName` comes from the corresponding constant.

##### `ssl_cert_path`
Location of the certificate. Default depends on your platform:

* Linux `/etc/icinga2/pki/NodeName.crt`
* Windows `C:/ProgramData/icinga2/etc/icinga2/pki/NodeName.crt`

The Value of `NodeName` comes from the corresponding constant.

##### `ssl_csr_path`
Location of the certificate signing request. Default depends on your platform:

* Linux: `/etc/icinga2/pki/NodeName.csr`
* Windows `C:/ProgramData/icinga2/etc/icinga2/pki/NodeName.csr`

The Value of `NodeName` comes from the corresponding constant.

##### `ssl_cacert_path`
Location of the CA certificate. Default depends on your platform:

* Linux: `/etc/icinga2/pki/ca.crt`
* Windows `C:/ProgramData/icinga2/etc/icinga2/pki/ca.crt`

### Private Classes

#### Class: `icinga2::repo`
Installs the [packages.icinga.com] repository. Depending on your operating system [puppetlabs/apt] or
[puppetlabs/chocolatey] are required.

#### Class: `icinga2::install`
Handles the installation of the Icinga 2 package.

#### Class: `icinga2::config`
Installs basic configuration files required to run Icinga 2.

#### Class: `icinga2::service`
Starts/stops and enables/disables the service.

### Public defined types

#### Defined type: `icinga2::object::endpoint`

##### `ensure`
Set to present enables the endpoint object, absent disables it. Defaults to present.

##### `endpoint_name`
Set the Icinga 2 name of the endpoint object. Defaults to title of the define resource.

##### `host`
Optional. The IP address of the remote Icinga 2 instance.

##### `port`
The service name/port of the remote Icinga 2 instance. Defaults to 5665.

##### `log_duration`
Duration for keeping replay logs on connection loss. Defaults to `1d` (86400 seconds). Attribute is specified in seconds.
If `log_duration` is set to `0`, replaying logs is disabled. You could also specify the value in human readable format
like `10m` for 10 minutes or `1h` for one hour.

##### `target`
Destination config file to store in this object. File will be declared at the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `10`.

#### Defined type: `icinga2::object::zone`

##### `ensure`
Set to present enables the zone object, absent disables it. Defaults to `present`

##### `zone_name`
Set the name of the zone object. Defaults to the title of the define resource.

##### `endpoints`
List of endpoints that belong to this zone.

##### `parent`
Parent zone to this zone.

##### `global`
If set to `true`, a global zone is defined and the parameter endpoints and parent are ignored. Defaults to `false`.

##### `target`
Destination config file to store in this object. File will be declared at the first time.

##### `order`
String to control the position in the target file, sorted alpha numeric.

#### Defined type: `icinga2::object::apiuser`

##### `ensure`
Set to present enables the apiuser object, absent disables it. Defaults to present.

##### `apiuser_name`
Set the name of the apiuser object. Defaults to title of the define resource.

##### `password`
Password string.

##### `client_cn`
Optional. Client Common Name (CN).

##### `permissions`
Array of permissions. Either as string or dictionary with the keys permission and filter. The latter must be specified
as function.

##### `target`
Destination config file to store in this object. File will be declared at the first time.

##### `order`
String to control the position in the target file, sorted alpha numeric. Defaults to `10`

###### Examples

```
permissions = [ "*" ]
```

```
permissions = [ "objects/query/Host", "objects/query/Service" ]
```

```
permissions = [
  {
    permission = "objects/query/Host"
    filter = {{ regex("^Linux", host.vars.os) }}
  },
  {
    permission = "objects/query/Service"
    filter = {{ regex("^Linux", service.vars.os) }}
  }
]
```

#### Defined type: `icinga2::object::checkcommand`

##### `ensure`
Set to present enables the checkcommand object, absent disables it. Defaults to present.

##### `checkcommand_name`
Title of the CheckCommand object.

##### `import`
Sorted List of templates to include. Defaults to an empty list.

##### `command`
The command. This can either be an array of individual command arguments. Alternatively a string can be specified in
which case the shell interpreter (usually /bin/sh) takes care of parsing the command. When using the `arguments`
attribute this must be an array. Can be specified as function for advanced implementations.

##### `env`
A dictionary of macros which should be exported as environment variables prior to executing the command.

##### `vars`
A dictionary containing custom attributes that are specific to this command.

##### `timeout`
The command timeout in seconds. Defaults to `60` seconds.

##### `arguments`
A dictionary of command arguments.

##### `target`
Destination config file to store in this object. File will be declared the
first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `10`

#### Defined type: `icinga2::object::host`

##### `ensure`
Set to present enables the host object, absent disables it. Defaults to present.

##### `host_name`
Hostname of the Host object.

##### `import`
Sorted List of templates to include. Defaults to an empty list.

##### `display_name`
A short description of the host (e.g. displayed by external interfaces instead of the name if set).

##### `address`
The host's address v4.

##### `address6`
The host's address v6.

##### `vars`
A dictionary containing custom attributes that are specific to this host.

##### `groups`
A list of host groups this host belongs to.

##### `check_command`
The name of the check command.

##### `max_check_attempts`
The number of times a host is re-checked before changing into a hard state. Defaults to `3`

##### `check_period`
The name of a time period which determines when this host should be checked. Not set by default.

##### `check_timeout`
Check command timeout in seconds. Overrides the CheckCommand's timeout attribute.

##### `check_interval`
The check interval (in seconds). This interval is used for checks when the host is in a HARD state. Defaults to `5` minutes.

##### `retry_interval`
The retry interval (in seconds). This interval is used for checks when the host is in a SOFT state. Defaults to `1` minute.

##### `enable_notifications`
Whether notifications are enabled. Defaults to `true`

##### `enable_active_checks`
Whether active checks are enabled. Defaults to `true`

##### `enable_passive_checks`
Whether passive checks are enabled. Defaults to `true`

##### `enable_event_handle`
Enables event handlers for this host. Defaults to `true`

##### `enable_flapping`
Whether flap detection is enabled. Defaults to `false`

##### `enable_perfdata`
Whether performance data processing is enabled. Defaults to `true`

##### `event_command`
The name of an event command that should be executed every time the host's state changes or the host is in a SOFT state.

##### `flapping_threshold`
The flapping threshold in percent when a host is considered to be flapping.

##### `volatile`
The volatile setting enables always HARD state types if NOT-OK state changes occur.

##### `zone`
The zone this object is a member of.

##### `command_endpoint`
The endpoint where commands are executed on.

##### `notes`
Notes for the host.

##### `notes_url`
Url for notes for the host (for example, in notification commands).

##### `action_url`
Url for actions for the host (for example, an external graphing tool).

##### `icon_image`
Icon image for the host. Used by external interfaces only.

##### `icon_image_alt`
Icon image description for the host. Used by external interface only.

##### `template`
Set to true creates a template instead of an object. Defaults to `false`

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `10`

#### Defined type: `icinga2::object::hostgroup`

##### `ensure`
Set to present enables the hostgroup object, absent disables it. Defaults to present.

##### `display_name`
A short description of the host group.

##### `groups`
An array of nested group names.

##### `assign`
Assign host group members using the group assign rules.

##### `target`
Destination config file to store in this object. File will be declared at the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `10`

#### Defined type: `icinga2::object::dependency`

##### `ensure`
Set to present enables the dependency object, absent disabled it. Defaults to `present`

##### `dependency_name`
Set the Icinga 2 name of the dependency object. Defaults to `title` of the define resource.

##### `parent_host_name`
The parent host.

##### `parent_service_name`
The parent service. If omitted, this dependency object is treated as host dependency.

##### `child_host_name`
The child host.

##### `child_service_name`
The child service. If omitted, this dependency object is treated as host dependency.

##### `disable_checks`
Whether to disable checks when this dependency fails. Defaults to `false`

##### `disable_notifications`
Whether to disable notifications when this dependency fails. Defaults to `true`

##### `ignore_soft_states`
Whether to ignore soft states for the reachability calculation. Defaults to `true`

##### `period`
Time period during which this dependency is enabled.

##### `states`
A list of state filters when this dependency should be OK. Defaults to [ OK, Warning ] for services and [ Up ] for hosts.

##### `apply`
Dispose an apply instead an object if set to 'true'. Value is taken as statement,
i.e. 'vhost => config in host.vars.vhosts'. Defaults to false.

##### `prefix`
Set dependency_name as prefix in front of 'apply for'. Only effects if apply is a string. Defaults to false.

##### `apply_target`
An object type on which to target the apply rule. Valid values are `Host` and `Service`. Defaults to `Host`.

##### `assign`
Assign user group members using the group assign rules.

##### `ignore`
Exclude users using the group ignore rules.

##### `template`
Set to true creates a template instead of an object. Defaults to `false`

##### `import`
Sorted List of templates to include. Defaults to an empty list.

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `35`

#### Defined type: `icinga2::object::timeperiod`

##### `ensure`
Set to present enables the timeperiod object, absent disabled it. Defaults to `present`

##### `timeperiod_name`
Set the Icinga 2 name of the timeperiod object. Defaults to `title` of the define resource.

##### `display_name`
A short description of the time period.

##### `import`
Sorted List of templates to include. Defaults to [ "legacy-timeperiod" ].

##### `ranges`
A dictionary containing information which days and durations apply to this timeperiod.

##### `prefer_includes`
Boolean whether to prefer timeperiods includes or excludes. Default to `true`

##### `excludes`
An array of timeperiods, which should exclude from your timerange.

##### `includes`
An array of timeperiods, which should include into your timerange

##### `template`
Set to true creates a template instead of an object. Defaults to `false`

##### `target`
Destination config file to store this object in. File will be declared on the first run.

##### `order`
String to control the position in the target file, sorted alpha numeric.

#### Defined type: `icinga2::object::usergroup`

##### `ensure`
Set to present enables the usergroup object, absent disables it. Defaults to `present`

##### `usergroup_name`
Set the Icinga 2 name of the usergroup object. Defaults to `title` of the define resource.

##### `user_name`
Set the Icinga 2 name of the user object. Defaults to title of the define resource.

##### `display_name`
A short description of the service group.

##### `groups`
An array of nested group names.

##### `assign`
Assign user group members using the group assign rules.

##### `ignore`
Exclude users using the group ignore rules.

##### `template`
Set to true creates a template instead of an object. Defaults to `false`

##### `import`
Sorted List of templates to include. Defaults to an empty list.

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `10`

#### Defined type: `icinga2::object::user`

##### `ensure`
Set to present enables the user object, absent disables it. Defaults to `present`

##### `display_name`
A short description of the user.

##### `email`
An email string for this user. Useful for notification commands.

##### `pager`
A pager string for this user. Useful for notification commands.

##### `vars`
A dictionary containing custom attributes that are specific to this user.

##### `groups`
An array of group names.

##### `enable_notifications`
Whether notifications are enabled for this user.

##### `period`
The name of a time period which determines when a notification for this user should be triggered. Not set by default.

##### `types`
A set of type filters when this notification should be triggered. By default everything is matched.

##### `states`
A set of state filters when this notification should be triggered. By default everything is matched.

##### `template`
Set to true creates a template instead of an object. Defaults to `false`

##### `import`
Sorted List of templates to include. Defaults to an empty list.

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `30`

#### Defined type: `icinga2::object::notificationcommand`

##### `ensure`
Set to present enables the notificationcommand object, absent disabled it. Defaults to present.

##### `notificationcommand_name`
Set the Icinga 2 name of the notificationcommand object. Defaults to `title` of the define resource.

##### `execute`
The "execute" script method takes care of executing the notification. The default template "plugin-notification-command"
which is imported into all CheckCommand objects takes care of this setting.

##### `command`
The command. This can either be an array of individual command arguments. Alternatively a string can be specified in
which case the shell interpreter (usually /bin/sh) takes care of parsing the command.

##### `env`
A dictionary of macros which should be exported as environment variables prior to executing the command.

##### `vars`
A dictionary containing custom attributes that are specific to this command.

##### `timeout`
The command timeout in seconds. Defaults to `60` seconds.

##### `arguments`
A dictionary of command arguments.

##### `template`
Set to true creates a template instead of an object. Defaults to `false`

##### `import`
Sorted List of templates to include. Defaults to an empty list.

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `10`

#### Defined type: `icinga2::object::notification`

##### `ensure`
Set to present enables the notification object, absent disables it. Defaults to `present`

##### `notification_name`
Set the Icinga 2 name of the notification object. Defaults to `title` of the define resource.

##### `host_name`
The name of the host this notification belongs to.

##### `service_name`
The short name of the service this notification belongs to. If omitted, this notification object is treated as host
notification.

##### `vars`
A dictionary containing custom attributes that are specific to this notification object.

##### `users`
A list of user names who should be notified.

##### `user_groups`
A list of user group names who should be notified.

##### `times`
A dictionary containing begin and end attributes for the notification.

##### `command`
The name of the notification command which should be executed when the notification is triggered.

##### `interval`
The notification interval (in seconds). This interval is used for active notifications. Defaults to `30` minutes. If set
to 0, re-notifications are disabled.

##### `period`
The name of a time period which determines when this notification should be triggered. Not set by default.

##### `zone`
The zone this object is a member of.

##### `types`
A list of type filters when this notification should be triggered. By default everything is matched.

##### `states`
A list of state filters when this notification should be triggered. By default everything is matched.

##### `apply`
Dispose an apply instead an object if set to 'true'. Value is taken as statement,
i.e. 'vhost => config in host.vars.vhosts'. Defaults to false.

##### `prefix`
Set notification_name as prefix in front of 'apply for'. Only effects if apply is a string. Defaults to false.

##### `apply_target`
An object type on which to target the apply rule. Valid values are `Host` and `Service`. Defaults to `Host`.

##### `template`
Set to true creates a template instead of an object. Defaults to `false`

##### `import`
Sorted List of templates to include. Defaults to an empty list.

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `10`

#### Defined type: `icinga2::object::service`

##### `ensure`
Set to present enables the service object, absent disables it. Defaults to `present`

##### `service_name`
Set the Icinga 2 name of the service object. Defaults to `title` of the define resource.

##### `display_name`
A short description of the service.

##### `host_name`
The host this service belongs to. There must be a Host object with that name.

##### `name`
The service name. Must be unique on a per-host basis (Similar to the service_description attribute in Icinga 1.x).

##### `groups`
The service groups this service belongs to.

##### `vars`
A dictionary containing custom attributes that are specific to this service.

##### `check_command`
The name of the check command.

##### `max_check_attempts`
The number of times a service is re-checked before changing into a hard state. Defaults to `3`

##### `check_period`
The name of a time period which determines when this service should be checked. Not set by default.

##### `check_timeout`
Check command timeout in seconds. Overrides the CheckCommand's timeout attribute.

##### `check_interval`
The check interval (in seconds). This interval is used for checks when the service is in a HARD state.
Defaults to `5` minutes.

##### `retry_interval`
The retry interval (in seconds). This interval is used for checks when the service is in a SOFT state.
Defaults to `1 minute.

##### `enable_notifications`
Whether notifications are enabled. Defaults to `true`

##### `enable_active_checks`
Whether active checks are enabled. Defaults to `true`

##### `enable_passive_checks`
Whether passive checks are enabled. Defaults to `true`

##### `enable_event_handler`
Enables event handlers for this host. Defaults to `true`

##### `enable_flapping`
Whether flap detection is enabled. Defaults to `false`

##### `enable_perfdata`
Whether performance data processing is enabled. Defaults to `true`

##### `event_command`
The name of an event command that should be executed every time the service's state changes or the service is in a SOFT
state.

##### `flapping_threshold`
The flapping threshold in percent when a service is considered to be flapping.

##### `volatile`
The volatile setting enables always HARD state types if NOT-OK state changes occur.

##### `zone`
The zone this object is a member of.

##### `command_endpoint`
The endpoint where commands are executed on.

##### `notes`
Notes for the service.

##### `notes_url`
Url for notes for the service (for example, in notification commands).

##### `action_url`
Url for actions for the service (for example, an external graphing tool).

##### `icon_image`
Icon image for the service. Used by external interfaces only.

##### `icon_image_alt`
Icon image description for the service. Used by external interface only.

##### `apply`
Dispose an apply instead an object if set to 'true'. Value is taken as statement,
i.e. 'vhost => config in host.vars.vhosts'. Defaults to false.

##### `prefix`
Set service_name as prefix in front of 'apply for'. Only effects if apply is a string. Defaults to false.

##### `assign`
Assign user group members using the group assign rules.

##### `ignore`
Exclude users using the group ignore rules.

##### `template`
Set to true creates a template instead of an object. Defaults to `false`

##### `import`
Sorted List of templates to include. Defaults to an empty list.

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `10`

#### Defined type: `icinga2::object::servicegroup`

##### `ensure`
Set to present enables the servicegroup object, absent disables it. Defaults to `present`

##### `servicegroup_name`
Set the Icinga 2 name of the servicegroup object. Defaults to `title` of the define resource.

##### `display_name`
A short description of the service group.

##### `groups`
An array of nested group names.

##### `assign`
Assign user group members using the group assign rules.

##### `ignore`
Exclude users using the group ignore rules.

##### `template`
Set to true creates a template instead of an object. Defaults to `false`

##### `import`
Sorted List of templates to include. Defaults to an empty list.

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `30`

#### Defined type: `icinga2::object::downtime`

##### `ensure`
Set to present enables the downtime object, absent disables it. Defaults to `present`

##### `host_name`
The name of the host this comment belongs to.

##### `service_name`
The short name of the service this comment belongs to. If omitted, this comment object is treated as host comment.

##### `author`
The author's name.

##### `comment`
The comment text.

##### `start_time`
The start time as unix timestamp.

##### `end_time`
The end time as unix timestamp.

##### `duration`
The duration as number.

##### `entry_time`
The unix timestamp when this downtime was added.

##### `fixed`
Whether the downtime is fixed (`true`) or flexible (`false`). Defaults to flexible.

##### `triggers`
List of downtimes which should be triggered by this downtime.

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `30`

#### Defined type: `icinga2::object::scheduleddowntime`

##### `ensure`
Set to present enables the scheduleddowntime object, absent disables it. Defaults to `present`

##### `scheduleddowntime_name`
Set the Icinga 2 name of the scheduleddowntime object. Defaults to `title` of the define resource.

##### `host_name`
The name of the host this comment belongs to.

##### `service_name`
The short name of the service this comment belongs to. If omitted, this comment object is treated as host comment.

##### `author`
The author's name.

##### `comment`
The comment text.

##### `fixed`
Whether this is a fixed downtime. Defaults to `true`

##### `duration`
The duration as number.

##### `ranges`
A dictionary containing information which days and durations apply to this timeperiod.

##### `apply`
Dispose an apply instead an object if set to 'true'. Value is taken as statement,
i.e. 'vhost => config in host.vars.vhosts'. Defaults to false.

##### `prefix`
Set scheduleddowntime_name as prefix in front of 'apply for'. Only effects if apply is a string. Defaults to false.

##### `apply_target`
An object type on which to target the apply rule. Valid values are `Host` and `Service`. Defaults to `Host`.

##### `assign`
Assign user group members using the group assign rules.

##### `ignore`
Exclude users using the group ignore rules.

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `30`

#### Defined type: `icinga2::object::eventcommand`

##### `ensure`
Set to present enables the eventcommand object, absent disables it. Defaults to `present`

##### `eventcommand_name`
Set the Icinga 2 name of the eventcommand object. Defaults to `title` of the define resource.

##### `execute`
The "execute" script method takes care of executing the event handler. In virtually all cases you should import the
"plugin-event-command" template to take care of this setting.

##### `command`
The command. This can either be an array of individual command arguments. Alternatively a string can be specified in
which case the shell interpreter (usually /bin/sh) takes care of parsing the command.

##### `env`
A dictionary of macros which should be exported as environment variables prior to executing the command.

##### `vars`
A dictionary containing custom attributes that are specific to this command.

##### `timeout`
The command timeout in seconds. Defaults to 60 seconds.

##### `arguments`
A dictionary of command arguments.

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `import`
Sorted List of templates to include. Defaults to an empty list.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `30`

#### Defined type: `icinga2::object::checkresultreader`

##### `ensure`
Set to present enables the checkresultreader object, absent disables it. Defaults to `present`

##### `checkresultreader_name`
Set the Icinga 2 name of the checkresultreader object. Defaults to `title` of the define resource.

##### `spool_dir`
The directory which contains the check result files. Defaults to `LocalStateDir + "/lib/icinga2/spool/checkresults/"`

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. Defaults to `30`

#### Defined type: `icinga2::object::compatlogger`

##### `ensure`
Set to present enables the compatlogger object, absent disables it. Defaults to `present`

##### `compatlogger_name`
Set the Icinga 2 name of the compatlogger object. Defaults to `title` of the define resource.

##### `spool_dir`
The directory which contains the check result files. Defaults to `LocalStateDir + "/lib/icinga2/spool/checkresults/"`

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric. `Defaults to 30`

#### Defined type: `icinga2::config::fragment`

##### `content`
Content to insert in file specified in target.

##### `target`
Destination config file to store in this fragment. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted in alpha numeric order.


### Private defined types

#### Defined type: `icinga2::feature`
This defined type is used by all feature defined types as basis. It can generally enable or disable features.

**Parameters of `icinga2::feature`:**

##### `ensure`
Either `present` or `absent`. Defines if the feature should be enabled. Defaults to `present`.

##### `feature`
Name of the feature. This name is used for the corresponding configuration file.

#### Defined type: `icinga2::object`
This defined type is used by all object defined types as bases. In can generally create Icinga 2 objects.

##### `ensure`
Set to present enables the object, absent disabled it. Defaults to present.

##### `object_name`
Set the icinga2 name of the object. Defaults to title of the define resource.

##### `template`
Set to true will define a template otherwise an object. Defaults to false.

##### `apply`
Dispose an apply instead an object if set to 'true'. Value is taken as statement,
i.e. 'vhost => config in host.vars.vhosts'. Defaults to false.

##### `apply_target`
An object type on which to target the apply rule. Valid values are `Host` and `Service`. Defaults to `Host`.

##### `import`
A sorted list of templates to import in this object. Defaults to an empty array.

##### `attrs`
Hash for the attributes of this object. Keys are the attributes and values are there values. Defaults to an empty Hash.

##### `object_type`
Icinga 2 object type for this object.

##### `target`
Destination config file to store in this object. File will be declared the first time.

##### `order`
String to set the position in the target file, sorted alpha numeric.


## Development
A roadmap of this project is located at https://github.com/Icinga/puppet-icinga2/milestones. Please consider
this roadmap when you start contributing to the project.

### Contributing
When contributing several steps such as pull requests and proper testing implementations are required.
Find a detailed step by step guide in [CONTRIBUTING.md].

### Testing
Testing is essential in our workflow to ensure a good quality. We use RSpec as well as Serverspec to test all components
of this module. For a detailed description see [TESTING.md].

## Release Notes
When releasing new versions we refer to [SemVer 1.0.0] for version numbers. All steps required when creating a new
release are described in [RELEASE.md]

See also [CHANGELOG.md]

## Authors
[AUTHORS] is generated on each release.

[Overview]: #overview
[Module description]: #module-description
[Setup]: #setup
[What Icinga 2 affects]: #what-icinga2-affects
[Usage]: #usage
[Reference]: #reference
[Public Classes]: #public-classes
[Private Classes]: #private-classes
[Public Defined Types]: #public-defined-types
[Private Defined Types]: #private-defined-types
[Limitations]: #limitations
[Development]: #development

[distributed monitoring]: http://docs.icinga.com/icinga2/latest/doc/module/icinga2/chapter/distributed-monitoring
[examples]: examples
[puppetlabs/stdlib]: https://github.com/puppetlabs/puppetlabs-stdlib
[puppetlabs/concat]: https://github.com/puppetlabs/puppetlabs-concat
[puppetlabs/apt]: https://github.com/puppetlabs/puppetlabs-apt
[puppetlabs/chocolatey]: https://github.com/puppetlabs/puppetlabs-chocolatey
[puppet/zypprepo]: https://forge.puppet.com/puppet/zypprepo
[puppetlabs/mysql]: https://github.com/puppetlabs/puppetlabs-mysql
[puppetlabs/puppetlabs-postgresql]: https://github.com/puppetlabs/puppetlabs-postgresql
[puppet-icinga2]: https://github.com/icinga/puppet-icinga2
[packages.icinga.com]: https://packages.icinga.com
[Chocolatey]: https://chocolatey.org
[SemVer 1.0.0]: http://semver.org/spec/v1.0.0.html

[CONTRIBUTING.md]: CONTRIBUTING.md
[TESTING.md]: TESTING.md
[RELEASE.md]: RELEASE.md
[CHANGELOG.md]: CHANGELOG.md
[AUTHORS]: AUTHORS
