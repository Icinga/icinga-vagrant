# kibana4

[![Puppet Forge](http://img.shields.io/puppetforge/v/lesaux/kibana4.svg)](https://forge.puppetlabs.com/lesaux/kibana4)
[![Build Status](http://img.shields.io/travis/lesaux/puppet-kibana4.svg)](http://travis-ci.org/lesaux/puppet-kibana4)


#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with kibana4](#setup)
    * [What kibana4 affects](#what-kibana4-affects)
    * [Beginning with kibana4](#beginning-with-kibana4)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Parameters](#parameters)
6. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
7. [Limitations - OS compatibility, etc.](#limitations)

## Overview

Install and configure Kibana4. Should work on any linux OS.

## Module Description

This module assumes you have a working Elasticsearch installation and indices (usually an 'ELK' stack).  Kibana4 only works with recent versions of Elasticsearch (1.4.4 and later).  I recommend using the 'elasticsearch' output with `protocol => 'http'` in Logstash (supported since 1.4.0) as the default `protocol => 'node'` uses ES version 1.1.1 and will prevent Kibana4 from connecting.

## Setup

### What kibana4 affects

* Manage the elastic.co Kibana repositories
* Install the Kibana package
* Modifies configuration file if needed.
* Java installation is not managed by this module.

### Beginning with kibana4

```puppet
include kibana4
```

## Usage

The elastic.co packages create a kibana user and group (999:999) and they provide an init file `/etc/init.d/kibana`.  This is now the preferred installation method for kibana4.

```puppet
include kibana4
```

## Parameters

Check all parameters in the `manifests/init.pp` file.

### Installation Parameters

#### `version`

Version of Kibana4 that gets installed.  Defaults to the latest version available in the `package_repo_version` you select

#### `install_method`

This parameter is deprecated. Only package installation from official `elastic.co` repositories is supported.

#### `package_repo_version`

Apt or yum repository version. Defaults to '4.5'.

#### `package_repo_proxy`

Whether or not to use a proxy for downloading the kibana4 package. Default is 'undef, so no proxy will be used. This is only support with yum repositories.

#### `service_ensure`

Specifies the service state. Valid values are stopped (false) and running (true).  Defaults to 'running'.

#### `service_enable`

Should the service be enabled on boot. Valid values are 'true', 'false', and 'manual'.  Defaults to 'true'.

#### `service_name`

Name of the Kibana4 service. Defaults to 'kibana'.

#### `plugins`

Simple plugin support has been added, but updating existing plugins is not yet supported.  A hash of plugins and their installation parameters is expected:

```puppet
class { 'kibana4':
  ...
  plugins => {
    'elasticsearch/marvel' => {
       kibana4_plugin_dir => '/opt/kibana/installedPlugins', # optional - this is the default
       plugin_dest_dir    => 'marvel',                       # mandatory - plugin will be installed in ${kibana4_plugin_dir}/${plugin_dest_dir}
       url                => 'http://your_custom_url',       # necessary if using arbitrary URL
       ensure             => present,                        # mandatory - either 'present' or 'absent'
    },
    'elastic/sense' => {
       ensure          => present,
       plugin_dest_dir => 'sense',
    },
  }
}
```

### Configuration Parameters

* See the [Kibana4 documentation](https://www.elastic.co/guide/en/kibana/current/kibana-server-properties.html) for a full list of kibana server properties.
* Note: If you do not specify a hash of configuration parameters, then the default `kibana.yml` provided by the archive or package will be left intact.
* Note: The config hash is different in version 4.1 than it is in version 4.3.

#### `config`

A hash of key/value server properties. Note that specifying a value for `pid.file` seems to break startup scripts as of version 4.5.

An extensive config could look like:

```puppet
  ...
  config => {
    'server.port'                  => 5601,
    'server.host'                  => '0.0.0.0',
    'elasticsearch.url'            => 'http://localhost:9200',
    'elasticsearch.preserveHost'   => true,
    'elasticsearch.ssl.cert'       => '/path/to/your/cert',
    'elasticsearch.ssl.key'        => '/path/to/your/key',
    'elasticsearch.password'       => 'password',
    'elasticsearch.username'       => 'username',
    'elasticsearch.pingTimeout'    => 1500,
    'elasticsearch.startupTimeout' => 5000,
    'kibana.index'                 => '.kibana',
    'kibana.defaultAppId'          => 'discover',
    'logging.silent'               => false,
    'logging.quiet'                => false,
    'logging.verbose'              => false,
    'logging.events'               => "{ log: ['info', 'warning', 'error', 'fatal'], response: '*', error: '*' }",
    'elasticsearch.requestTimeout' => 500000,
    'elasticsearch.shardTimeout'   => 0,
    'elasticsearch.ssl.verify'     => true,
    'elasticsearch.ssl.ca'         => '[/path/to/a/CA,path/to/anotherCA/]',
    'server.ssl.key'               => '/path/to/your/ssl/key',
    'server.ssl.cert'              => '/path/to/your/ssl/cert',
    'pid.file'                     => '/var/run/kibana.pid',
    'logging.dest'                 => '/var/log/kibana/kibana.log',
  },
```

## Testing

### Rspec

You can install gem dependencies with
```
$ bundle install
```
and run tests with
```
$ bundle exec rake spec
```

### Beaker-rspec

You can run beaker-spec tests which will start two vagrant boxes, one to do basic test of the `archive` installation method, and the other to test the `package` installation method. Each vagrant box also runs elasticsearch.

At this time these tests are fairly basic. We use a basic manifest in each case and ensure that the puppet return code is 2 (the run succeeded, and some resources were changed) on the first run, and ensure that the return code is 0 (the run succeeded with no changes or failures; the system was already in the desired state) on the second run.

Available node sets are centos-66-x64, centos-70-x64, ubuntu-1204-x64, ubuntu-1404-x64, debian-78-x64.

Run with:
```
$ BEAKER_set=centos-66-x64 bundle exec rspec spec/acceptance
```
