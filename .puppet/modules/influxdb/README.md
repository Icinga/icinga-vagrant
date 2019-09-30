# InfluxDB

#### Table of Contents

1.  [Overview](#overview)
2.  [Module Description - What the module does and why it is useful](#module-description)
3.  [Installation](#installation)
4.  [Setup - The basics of getting started with influxdb](#setup)
5.  [Usage - Configuration options and additional functionality](#usage)
6.  [Reference - An under-the-hood peek at what the module is doing and how](#reference)
7.  [Limitations - OS compatibility, etc.](#limitations)
8.  [Development - Guide for contributing to the module](#development)
9.  [License](#License)

## Overview

This module manages InfluxDB installation.

[![Build Status](https://travis-ci.org/n1tr0g/golja-influxdb.png)](https://travis-ci.org/n1tr0g/golja-influxdb) [![Puppet Forge](http://img.shields.io/puppetforge/v/golja/influxdb.svg)](https://forge.puppetlabs.com/golja/influxdb)

## Module Description

The InfluxDB module manages both the installation and configuration of InfluxDB.
I am planning to extend it to allow management of InfluxDB resources,
such as databases, users, and privileges.

## Deprecation Warning

Notes for version 5.0.0+:

This module was a refactor of the 4.x version to handle influxdb >= 1.x.
Due to the changes in influxdb 1.x, this module should now support
future change more easily due to thew way the configuration files are
now managed.

Highlights
==========

* The module layout out has changed significantly from previous versions.
* A new fact was added `influxdb_version`.
* The influxdb.conf.erb file was refactored.
* Added and fixed a lot of rspec puppet tests.
* Fixed all the beaker tests, they work now.
* This module now supports influxdb >= 1.x < 2.x
* Major change to the original class parameters now hashes vs individual items.


Notes for version 4.0.0+:

influxdb 1.0.0 contains [breaking changes](https://github.com/influxdata/influxdb/blob/master/CHANGELOG.md#v100-2016-09-08)
which require changing the `data_logging_enabled` config attribute to `trace_logging_enabled`.
The other configuration changes are managed by the `influxdb.conf.erb` template already.

Notes for versions older than 3.1.1:

This release is a major refactoring of the module which means that the API
changed in backwards incompatible ways. If your project depends on the old API
and you need to use influxdb prior to 0.10.X, please pin your module
dependencies to 0.1.2 (0.8.X) or 2.2.2 (0.9.X) version to ensure your environments
don't break.

*NOTE*: Until influxdb 1.0.0 is releases the API of this module may change,
however I will try my best to avoid it.

## Installation

`puppet module install golja/influxdb`

## Setup

### What InfluxDB affects

*   InfluxDB packages
*   InfluxDB configuration files
*   InfluxDB service

### Beginning with InfluxDB

If you just want a server installed with the default options you can
run include `'::influxdb'`.

## Usage

All interaction for the server is done via `influxdb::server`.

Install influxdb

```puppet
class {'influxdb':}
```

```puppet

# These are defaults, but demonstrates how you can change sections of data
$global_config => {
  'bind-address'       => ':8088',
  'reporting-disabled' => false,
}

class {'influxdb':
  global_config  => $global_config,
  manage_repos   => true,
  manage_service => true,
  version        => '1.2.0',
}
```

Enable Graphite plugin with one database

```puppet

# Most of these will be defaults, unless otherwise noted.
$graphite_config = {
  'default' => {
    'enabled'           => true, # not default
    'database'          => "graphite",
    'retention-policy'  => '',
    'bind-address'      => ':2003',
    'protocol'          => 'tcp',
    'consistency-level' => 'one',
    'batch-size'        => 5000,
    'batch-pending'     => 10,
    'batch-timeout'     => '1s',
    'udp-read-buffer'   => 0,
    'separator'         => '.',
    'tags'              => [ "region=us-east", "zone=1c"],
    'templates'         => [ "*.app env.service.resource.measurement" ],
  }
}

class { 'influxdb':
  manage_repos    => true,
  graphite_config => $graphite_config,
}
```

Enable Collectd plugin

```puppet

# most of these are defaults, unless otherwise noted
$collectd_config = {
  'default' => {
    'enabled'          => true, # not default
    'bind-address'     => ':25826',
    'database'         => 'collectd',
    'retention-policy' => '',
    'typesdb'          => '/usr/share/collectd/types.db',
    'batch-size'       => 5000,
    'batch-pending'    => 10,
    'batch-timeout'    => '10s',
    'read-buffer'      => 0,
  }
}

class {'influxdb':
  manage_repos    => true,
  collectd_config => $collectd_config,
}
```

Enable UDP listener

```puppet


# most of these are defaults unless otherwise noted.
$udp_config = {
  'default' => {
    'enabled'          => true, # not default
    'bind-address'     => ':8089',
    'database'         => 'udp',
    'retention-policy' => '',
    'batch-size'       => 5000,
    'batch-pending'    => 10,
    'batch-timeout'    => '1s',
    'read-buffer'      => 0,
  }
}

class {'influxdb':
  manage_repos => true,
  udp_config   => $udp_config
}
```

Enable opentsdb

```puppet

# most of these are defaults unless otherwise noted
$opentsdb_config = {
  'default' => {
    'enabled'           => true, # not default
    'bind-address'      => ':4242',
    'database'          => 'opentsdb',
    'retention-policy'  => '',
    'consistency-level' => 'one',
    'tls-enabled'       => false,
    'certificate'       => '/etc/ssl/influxdb.pem',
    'log-point-errors'  => true,
    'batch-size'        => 1000,
    'batch-pending'     => 5,
    'batch-timeout'     => '1s'
  }
}


class {'influxdb':
  manage_repos    => true,
  opentsdb_config => $opentsdb_config,
}
```

## Reference

### Classes

#### Public classes

*   `influxdb`: Installs and configures InfluxDB.

#### Private classes

*   `influxdb::install`: Installs packages.
*   `influxdb::config`: Configures InfluxDB.
*   `influxdb::repo`: Manages install repo.
*   `influxdb::service`: Manages service.

### Parameters

#### influxdb

##### `ensure`

Allows you to install or remove InfluxDB. Can be 'present' or 'absent'.

##### `version`

Version of InfluxDB.
Default: installed

*NOTE*: installed (will install the latest version if the package repo if not already installed).
        It is highly recommended that you manage this param with a specific version.

##### `config_file`

Path to the config file.
Default: /etc/influxdb/influxdb.conf

##### `conf_template`

The path to the template file that puppet uses to generate the influxdb.conf
Default: influxdb/influxdb.conf.erb

##### `startup_conf_template`

The path to the template file that puppet uses to generate the start config.
Default: influxdb/influxdb_default.erb

##### `service_enabled`

Boolean to decide if the service should be enabled.
Default: true

##### `service_ensure`

String to decide if the service should be running|stopped.
Default: running

##### `manage_service`

Boolean to decide if the service should be managed with puppet or not.
Default: true

##### `manage_repos`

Boolean to decide if the package repos should be managed by puppet.
Default: false

##### `manage_install`

Boolean to decide if puppet should manage the install of packages.
Default: true

##### `influxdb_stderr_log`

Where influx will log stderr messages
Default: /var/log/influxdb/influxd.log


##### `influxdb_stdout_log`

Where influx will log stdout messages
Default: /var/log/influxdb/influxd.log


##### `influxd_opts`

String of startup config options that need to be present.
Default: undef


##### `global_config`

A hash of global configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs.

[Influx Global Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#global-options)

[params.pp](manifests/params.pp#L21)


##### `meta_config`

A hash of meta configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx Meta Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#meta)

[params.pp](manifests/params.pp#26)


##### `data_config`

A hash of data configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx Data Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#data)

[params.pp](manifests/params.pp#32)

##### `logging_config`

A hash of logging configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.5.x of the influx docs

[Influx Logging Options](https://docs.influxdata.com/influxdb/v1.5/administration/config/#logging-settings-logging)

[params.pp](manifests/params.pp#43)

##### `coordinator_config`

A hash of coordinator configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx Coordinator Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#coordinator)

[params.pp](manifests/params.pp#45)


##### `retention_config`

A hash of retention configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx Retention Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#retention)

[params.pp](manifests/params.pp#55)


##### `shard_precreation_config`

A hash of shard_precreation configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx Shard Precreation Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#shard-precreation)

[params.pp](manifests/params.pp#60)


##### `monitor_config`

A hash of monitor configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx Monitor Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#monitor)

[params.pp](manifests/params.pp#66)


##### `admin_config`

A hash of admin configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx Admin Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#admin)

[params.pp](manifests/params.pp#74)


##### `http_config`

A hash of http configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx HTTP Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#http)

[params.pp](manifests/params.pp#81)


##### `subscriber_config`

A hash of subscriber configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx Subscriber Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#subscriber)

[params.pp](manifests/params.pp#99)


##### `graphite_config`

A hash of graphite configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx Graphite Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#graphite)

[params.pp](manifests/params.pp#108)


##### `collectd_config`

A hash of collectd configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx Collectd Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#collectd)

[params.pp](manifests/params.pp#126)


##### `opentsdb_config`

A hash of opentsdb configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx Opentsdb Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#opentsdb)

[params.pp](manifests/params.pp#140)


##### `udp_config`

A hash of udp configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx Udp Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#udp)

[params.pp](manifests/params.pp#156)


##### `continuous_queries_config`

A hash of continuous queries configuration options for `influxdb.conf`

*NOTE*: The default for this hash is what is in 1.2.0 of the influx docs

[Influx Continuous Queries Options](https://docs.influxdata.com/influxdb/v1.2/administration/config/#continuous-queries)

[params.pp](manifests/params.pp#169)


##### `hinted_handoff_config`

This is depcreated as of influxdb >= 1.0
Default: {}

## Limitations

This module has been tested on:

*   Ubuntu 12.04
*   Ubuntu 14.04
*   CentOS 6/7

## Development

In order to better facilitate beaker testing, the Gemfile was modified to
support environment variables.  You must set this enviroment variable
before running `bundle exec *`.  The Gemfile will automatically set this
for you but you can also override it.
```
export BEAKER_VERSION=3.10.0 # assumes ruby >= 2.2.5
```

Please see CONTRIBUTING.md

### Todo

*   Add native types for managing users and databases
*   Add more rspec tests
*   Add beaker/rspec tests

## License

See LICENSE file
