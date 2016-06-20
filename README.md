#grafana

[![Puppet Forge](http://img.shields.io/puppetforge/v/bfraser/grafana.svg)](https://forge.puppetlabs.com/bfraser/grafana)
[![Build Status](http://img.shields.io/travis/bfraser/puppet-grafana.svg)](http://travis-ci.org/bfraser/puppet-grafana)

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [Beginning with Grafana](#beginning-with-grafana)
4. [Usage](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
5. [Limitations](#limitations)
6. [Copyright and License](#copyright-and-license)

##Overview

This module installs Grafana, a dashboard and graph editor for Graphite, InfluxDB and OpenTSDB.

##Module Description

Version 2.x of this module is designed to work with version 2.x of Grafana. If you would like to continue to use Grafana 1.x, please use version 1.x of this module.

##Setup

This module will:

* Install Grafana using your preferred method: package (default), Docker container, or tar archive
* Allow you to override the version of Grafana to be installed, and / or the package source
* Perform basic configuration of Grafana

###Beginning with Grafana

To install Grafana with the default parameters:

```puppet
    class { 'grafana': }
```

This assumes that you want to install Grafana using the 'package' method. To establish customized parameters:

```puppet
    class { 'grafana':
      install_method  => 'docker',
    }
```

##Usage

###Classes and Defined Types

####Class: `grafana`

The Grafana module's primary class, `grafana`, guides the basic setup of Grafana on your system.

```puppet
    class { 'grafana': }
```
**Parameters within `grafana`:**

#####`archive_source`

The download location of a tarball to use with the 'archive' install method. Defaults to the URL of the latest version of Grafana available at the time of module release.

#####`cfg_location`

Configures the location to which the Grafana configuration is written. The default location is '/etc/grafana/grafana.ini'.

#####`cfg`

Manages the Grafana configuration file. Grafana comes with its own default settings in a different configuration file (/opt/grafana/current/conf/defaults.ini), therefore this module does not supply any defaults.

This parameter only accepts a hash as its value. Keys with hashes as values will generate sections, any other values are just plain values. The example below will result in...

```puppet
    class { 'grafana':
      cfg => {
        app_mode => 'production',
        server   => {
          http_port     => 8080,
        },
        database => {
          type          => 'sqlite3',
          host          => '127.0.0.1:3306',
          name          => 'grafana',
          user          => 'root',
          password      => '',
        },
        users    => {
          allow_sign_up => false,
        },
      },
    }
```

...the following Grafana configuration:

```ini
# This file is managed by Puppet, any changes will be overwritten

app_mode = production

[server]
http_port = 8080

[database]
type = sqlite3
host = 127.0.0.1:3306
name = grafana
user = root
password =

[users]
allow_sign_up = false
```

Some minor notes:

 - If you want empty values, just use an empty string.
 - Keys that contains dots (like auth.google) need to be quoted.
 - The order of the keys in this hash is the same as they will be written to the configuration file. So settings that do not fall under a section will have to come before any sections in the hash.

####`ldap_cfg`

#####TOML note
This option **requires** the [toml](https://github.com/toml-lang/toml) gem. Either install the gem using puppet's native gem provider, [puppetserver_gem](https://forge.puppetlabs.com/puppetlabs/puppetserver_gem), [pe_gem](https://forge.puppetlabs.com/puppetlabs/pe_gem), [pe_puppetserver_gem](https://forge.puppetlabs.com/puppetlabs/pe_puppetserver_gem), or manually using one of the following:
```
  # apply or puppet-master
  gem install toml
  # PE apply
  /opt/puppet/bin/gem install toml
  # AIO or PE puppetserver
  /opt/puppet/bin/puppetserver gem install toml
```

#####cfg note
This option by itself is not sufficient to enable LDAP configuration as it must be enabled in the main configuration file. Enable it in cfg with:

```
'auth.ldap' => {
  enabled     => 'true',
  config_file => '/etc/grafana/ldap.toml',
},
```

####Integer note
Puppet may convert integers into strings while parsing the hash and converting into toml. This can be worked around by appending 0 to an integer.

Example:
```
port => 636+0,
```

Manages the Grafana LDAP configuration file. This hash is directly translated into the corresponding TOML file, allowing for full flexibility in generating the configuration.

See the [LDAP documentation](http://docs.grafana.org/v2.1/installation/ldap/) for more information.

####Example LDAP config

```
ldap_cfg => {
  servers => [
    { host            => 'ldapserver1.domain1.com',
      port            => 636+0,
      use_ssl         => true,
      search_filter   => '(sAMAccountName=%s)',
      search_base_dns => [ 'dc=domain1,dc=com' ],
      bind_dn         => 'user@domain1.com',
      bind_password   => 'passwordhere',
    },
  ],
  'servers.attributes' => {
    name      => 'givenName',
    surname   => 'sn',
    username  => 'sAMAccountName',
    member_of => 'memberOf',
    email     => 'email',
  }
},
```


#####`container_cfg`

Boolean to control whether a configuration file should be generated when using the 'docker' install method. If 'true', use the 'cfg' and 'cfg_location' parameters to control creation of the file. Defaults to false.

#####`container_params`

A hash of parameters to use when creating the Docker container. For use with the 'docker' install method. Refer to documentation of the 'docker::run' resource in the [garethr-docker](https://github.com/garethr/garethr-docker) module for details of available parameters. Defaults to:

```puppet
container_params => {
  'image' => 'grafana/grafana:latest',
  'ports' => '3000:3000'
}
```

#####`data_dir`

The directory Grafana will use for storing its data. Defaults to '/var/lib/grafana'.

#####`install_dir`

The installation directory to be used with the 'archive' install method. Defaults to '/usr/share/grafana'.

#####`install_method`

Controls which method to use for installing Grafana. Valid options are: 'archive', 'docker', 'repo' and 'package'. The default is 'package'. If you wish to use the 'docker' installation method, you will need to include the 'docker' class in your node's manifest / profile. If you wish to use the 'repo' installation method, you can control whether the official Grafana repositories will be used. See `manage_package_repo` below for details.

#####`manage_package_repo`

Boolean. When using the 'repo' installation method, controls whether the official Grafana repositories are enabled on your host. If true, the official Grafana repositories will be enabled. If false, the module assumes you are managing your own package repository and will not set one up for you. Defaults to true.

#####`package_name`

The name of the package managed with the 'package' install method. Defaults to 'grafana'.

#####`package_source`

The download location of a package to be used with the 'package' install method. Defaults to the URL of the latest version of Grafana available at the time of module release.

#####`rpm_iteration`

Used when installing Grafana from package ('package' or 'repo' install methods) on Red Hat based systems. Defaults to '1'. It should not be necessary to change this in most cases.

#####`service_name`

The name of the service managed with the 'archive' and 'package' install methods. Defaults to 'grafana-server'.

#####`version`

The version of Grafana to install and manage. Defaults to the latest version of Grafana available at the time of module release.

##Advanced usage:

The archive install method will create the user and a "command line" service by default.
There are no extra parameters to manage user/service for archive. However, both check to see if they are defined before defining. This way you can create your own user and service with your own specifications. (sort of overriding)
The service can be a bit tricky, in this example below, the class sensu_install::grafana::service creates a startup script and a service{'grafana-server':}

Example:
```puppet
    user { 'grafana':
      ensure   => present,
      uid      => '1234',
    }
    ->
    class { 'grafana':
      install_method  => 'archive',
    }

    include sensu_install::grafana::service

    # run your service after install/config but before grafana::service
    Class[::grafana::install]
    ->
    Class[sensu_install::grafana::service]
    ->
    Class[::grafana::service]

```

####Custom Types and Providers

The module includes two custom types: `grafana_dashboard` and `grafana_datasource`

#####`grafana_dashboard`

In order to use the dashboard resource, add the following to your manifest:

```puppet
grafana_dashboard { 'example_dashboard':
  grafana_url       => 'http://localhost:3000',
  grafana_user      => 'admin',
  grafana_password  => '5ecretPassw0rd',
  content           => template('path/to/exported/file.json'),
}
```

`content` must be valid JSON, and is parsed before imported.
`grafana_user` and `grafana_password` are optional, and required when authentication is enabled in Grafana.

#####`grafana_datasource`

In order to use the datasource resource, add the following to your manifest:

```puppet
grafana_datasource { 'influxdb':
  grafana_url       => 'http://localhost:3000',
  grafana_user      => 'admin',
  grafana_password  => '5ecretPassw0rd',
  type              => 'influxdb',
  url               => 'http://localhost:8086',
  user              => 'admin',
  password          => '1nFlux5ecret',
  database          => 'graphite',
  access_mode       => 'proxy',
  is_default        => true,
  json_data         => template('path/to/additional/config.json'),
}
```

Available types are: influxdb, elasticsearch, graphite, kairosdb, opentsdb, prometheus

Access mode determines how Grafana connects to the datasource, either `direct` from the browser, or `proxy` to send requests via grafana.

Authentication is optional, as is `database`; additional `json_data` can be provided to allow custom configuration options.


##Limitations

This module has been tested on Ubuntu 14.04, using each of the 'archive', docker' and 'package' installation methods. Other configurations should work with minimal, if any, additional effort.

##Copyright and License

Copyright (C) 2015 Bill Fraser

Bill can be contacted at: fraser@pythian.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
