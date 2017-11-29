[![Build Status](https://travis-ci.org/Icinga/puppet-icingaweb2.png?branch=master)](https://travis-ci.org/Icinga/puppet-icingaweb2)

# Icinga Web 2 Puppet Module

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with Icinga Web 2](#setup)
    * [What Icinga Web 2 affects](##what-icinga-web-2-affects)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Public Classes](#public-classes)
    * [Private Classes](#private-classes)
    * [Public defined types](#public-defined-types)
    * [Private defined types](#private-defined-types)
6. [Development - Guide for contributing to the module](#development)

## Overview
[Icinga Web 2] is the associated web interface for the open source
monitoring tool [Icinga 2]. This module helps with installing and managing
configuration of Icinga Web 2 and its modules on multiple operating systems.

## Description

This module installs and configures Icinga Web 2 on your Linux host by using the official packages from
[packages.icinga.com]. Dependend packages are installed as they are defined in the Icinga Web 2 package.

This module can manage all configurations files of Icinga Web 2 and import an initial database schema. It can install and
manage all official [modules](https://www.icinga.com/products/icinga-web-2-modules/) as well as modules developed by the
community.

## Setup

### What the Icinga 2 Puppet module supports

* Installation of Icinga Web 2 via packages
* Configuration
* MySQL / PostgreSQL database schema import
* Install and manage official Icinga Web 2 modules
* Install community modules

### Dependencies

This module depends on

* [puppetlabs/stdlib] >= 4.16.0
* [puppetlabs/vcsrepo] >= 1.3.0
* [puppetlabs/concat] >= 2.0.1

Depending on your setup following modules may also be required:

* [puppetlabs/apt] >= 2.0.0
* [puppet/zypprepo] >= 2.0.0

### Limitations

This module has been tested on:

* Debian 7, 8
* CentOS/RHEL 6, 7
* Ubuntu 14.04, 16.04
* SLES 12

Other operating systems or versions may work but have not been tested.

## Usage

### Install Icinga Web 2

The default class `icingaweb2` installs a basic installation of Icinga Web 2 by using the systems package manager. It
is recommended to use the official Icinga repository for the installation.

Use the `manage_repo` parameter to configure the official [packages.icinga.com] repository.

``` puppet
class { '::icingaweb2':
  manage_repo => true,
}
```

**Info:** If you are using the [Icinga 2](https://github.com/icinga/puppet-icinga2) Puppet module on the same server,
make sure to disable the repository management for one of the modules!

If you want to manage the version of Icinga Web 2, you have to disable the package management of this module and handle
packages in your own Puppet code.

``` puppet
package { 'icingaweb2':
  ensure => latest,
}

class { '::icingaweb2':
  manage_package => false,
}
```

Be careful with this option: Setting `manage_package` to false also means that this module will not install any
dependent packages of modules.

Use the [monitoring](#monitoring) class to connect the web interface to Icinga 2.

This module does not provide functionality to install and configure any web server, see the following examples how to
install Icinga Web 2 with differen web servers:

* [Apache2](https://github.com/Icinga/puppet-icingaweb2/blob/master/examples/apache2.pp)
* [Nginx](https://github.com/Icinga/puppet-icingaweb2/blob/master/examples/nginx.pp)

### Manage Resources
Icinga Web 2 resources are managed with the `icingaweb2::config::resource` defined type. Supported resource types
are `db` and `ldap`. Resources are used for the internal authentication mechanism and by modules. Depending on the type
of resource you are managing, different parameters may be required.

Create a `db` resource:

``` puppet
icingaweb2::config::resource{'my-sql':
  type        => 'db',
  db_type     => 'mysql',
  host        => 'localhost',
  port        => '3306',
  db_name     => 'icingaweb2',
  db_username => 'root',
  db_password => 'supersecret',
}
```

Create a `ldap` resource:

``` puppet
icingaweb2::config::resource{'my-ldap':
  type         => 'ldap',
  host         => 'localhost',
  port         => 389,
  ldap_root_dn => 'dc=users,dc=icinga,dc=com',
  ldap_bind_dn => 'cn=root,dc=users,dc=icinga,dc=com',
  ldap_bind_pw => 'supersecret',
}
```

### Manage Authentication Methods
Authentication methods are created with the `icingaweb2::config:authmethod` defined type. Various authentication methods
are supported: `db`, `ldap`, `msldap` and `external`. Auth methods can be chained with the `order` parameter.

Create a MySQL authmethod:

``` puppet
icingaweb2::config::authmethod{'my-sql':
  backend  => 'db',
  resource => 'my-sql',
  order    => '01',
}
```
Create a LDAP authmethod:

``` puppet
icingaweb2::config::authmethod {'ldap-auth':
  backend                  => 'ldap',
  resource                 => 'my-ldap',
  ldap_user_class          => 'myObjectClass',
  ldap_filter              => '(icingaaccess=true))',
  ldap_user_name_attribute => 'uid',
  order                    => '02',
}
```

#### DB Schema and Default User
You can choose to import the database schema for MySQL or PostgreSQL. If you set `import_schema` to `true` the module
import the corresponding schema for your `db_type`. Additionally a resource, an authentication method and a role will be
generated.

The module does not support the creation of databases, we encourage you to use either the [puppetlabs/mysql] or the
[puppetlabs/puppetlabs-postgresql] module.

:bulb: Default credentials are: **User:** `icinga` **Password**: `icinga`

##### MySQL
Use MySQL as backend for user authentication in Icinga Web 2:

``` puppet
include ::mysql::server

mysql::db { 'icingaweb2':
  user     => 'icingaweb2',
  password => 'icingaweb2',
  host     => 'localhost',
  grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER', 'REFERENCES'],
}

class {'icingaweb2':
  manage_repo   => true,
  import_schema => true,
  db_type       => 'mysql',
  db_host       => 'localhost',
  db_port       => 3306,
  db_username   => 'icingaweb2',
  db_password   => 'icingaweb2',
  require       => Mysql::Db['icingaweb2'],
}
```

##### PostgreSQL
Use PostgreSQL as backend for user authentication in Icinga Web 2:

``` puppet
include ::postgresql::server

postgresql::server::db { 'icingaweb2':
  user     => 'icingaweb2',
  password => postgresql_password('icingaweb2', 'icingaweb2'),
}

class {'icingaweb2':
  manage_repo   => true,
  import_schema => true,
  db_type       => 'pgsql',
  db_host       => 'localhost',
  db_port       => '5432',
  db_username   => 'icingaweb2',
  db_password   => 'icingaweb2',
  require       => Postgresql::Server::Db['icingaweb2'],
}
```

#### Manage Roles
Roles are a set of permissions applied to users and groups. With filters you can limit the access to certain objects
only. Each module can add its own permissions, so it's hard to create a list of all available permissions. The following
permissions are included when the `monitoring` module is enabled:

| Description | Value |
|-------------|-------|
| Allow everything | `*` |
| Allow to share navigation items | `application/share/navigation` |
| Allow to adjust in the preferences whether to show stacktraces | `application/stacktraces` |
| Allow to view the application log | `application/log` |
| Grant admin permissions, e.g. manage announcements | `admin` |
| Allow config access | `config/*` |
| Allow access to module doc | `module/doc` |
| Allow access to module monitoring | `module/monitoring` |
| Allow all commands | `monitoring/command/*` |
| Allow scheduling host and service checks | `monitoring/command/schedule-check` |
| Allow acknowledging host and service problems | `monitoring/command/acknowledge-problem` |
| Allow removing problem acknowledgements | `monitoring/command/remove-acknowledgement` |
| Allow adding and deleting host and service comments | `monitoring/command/comment/*` |
| Allow commenting on hosts and services | `monitoring/command/comment/add` |
| Allow deleting host and service comments | `monitoring/command/comment/delete` |
| Allow scheduling and deleting host and service downtimes | `monitoring/command/downtime/*` |
| Allow scheduling host and service downtimes | `monitoring/command/downtime/schedule` |
| Allow deleting host and service downtimes | `monitoring/command/downtime/delete` |
| Allow processing host and service check results | `monitoring/command/process-check-result` |
| Allow processing commands for toggling features on an instance-wide basis | `monitoring/command/feature/instance` |
| Allow processing commands for toggling features on host and service objects | `monitoring/command/feature/object/*`) |
| Allow processing commands for toggling active checks on host and service objects | `monitoring/command/feature/object/active-checks` |
| Allow processing commands for toggling passive checks on host and service objects | `monitoring/command/feature/object/passive-checks` |
| Allow processing commands for toggling notifications on host and service objects | `monitoring/command/feature/object/notifications` |
| Allow processing commands for toggling event handlers on host and service objects | `monitoring/command/feature/object/event-handler` |
| Allow processing commands for toggling flap detection on host and service objects | `monitoring/command/feature/object/flap-detection` |
| Allow sending custom notifications for hosts and services | `monitoring/command/send-custom-notification` |
| Allow access to module setup | `module/setup` |
| Allow access to module test | `module/test` |
| Allow access to module translation | `module/translation` |

With the monitoring module, possible filters are:
* `application/share/users`
* `application/share/groups`
* `monitoring/filter/objects`
* `monitoring/blacklist/properties`

Create role that allows a user to see only hosts beginning with `linux-*`:

``` puppet
icingaweb2::config::role{'linux-user':
  users       => 'bob, pete',
  permissions => '*',
  filters     => {
    'monitoring/filter/objects' => 'host_name=linux-*',
  }
}
```

#### Manage Group Backends
Group backends store information about available groups and their members. Valid backends are `db`, `ldap` or `msldap`.
Groups backends can be combined with authentication methods. For example, users can be stored in a database, but group
definitions in LDAP. If a user is member of multiple groups, he inherits permissions of all his groups.

Create an LDAP group backend:

``` puppet
icingaweb2::config::groupbackend {'ldap-backend':
  backend                     => 'ldap',
  resource                    => 'my-ldap',
  ldap_group_class            => 'groupofnames',
  ldap_group_name_attribute   => 'cn',
  ldap_group_member_attribute => 'member',
  ldap_base_dn                => 'ou=groups,dc=icinga,dc=com'
}
```

If you have imported the database schema (parameter `import_schema`), you can use this database as group backend:

``` puppet
icingaweb2::config::groupbackend {'mysql-backend':
  backend  => 'db',
  resource => 'mysql-icingaweb2',
}
```

### Install and Manage Modules

#### Monitoring
This module is mandatory for almost every setup. It connects your Icinga Web interface to the Icinga 2 core. Current and
history information are queried through the IDO database. Actions such as `Check Now`, `Set Downtime` or `Acknowledge`
are send to the Icinga 2 API.

Requirements: 

* IDO feature in Icinga 2 (MySQL or PostgreSQL)
* `ApiUser` object in Icinga 2 with proper permissions

Example:
``` puppet
class {'icingaweb2::module::monitoring':
  ido_host        => 'localhost',
  ido_db_name     => 'icinga2',
  ido_db_username => 'icinga2',
  ido_db_password => 'supersecret',
  commandtransports => {
    icinga2 => {
      transport => 'api',
      username  => 'root',
      password  => 'icinga',
    }
  }
}
```

#### Director
The Director is used to manage Icinga 2 configuration through the web interface Icinga Web 2. The module requires its
database. The module is installed by cloning the git repository, therefore you need to set `git_revision` to either a
git branch or tag, eg. `master` or `v1.3.2`. 

The Director has some dependencies that you have to fulfill manually currently:
* Icinga 2 (>= 2.6.0)
* Icinga Web 2 (>= 2.4.1)
* A MySQL or PostgreSQL database
* PHP (>= 5.4)
* php-curl

Example:
``` puppet
class {'icingaweb2::module::director':
  git_revision  => 'v1.3.2',
  db_host       => 'localhost',
  db_name       => 'director',
  db_username   => 'director',
  db_password   => 'director',
  import_schema => true,
  kickstart     => true,
  endpoint      => 'puppet-icingaweb2.localdomain',
  api_username  => 'root',
  api_password  => 'icinga',
  require       => Mysql::Db['director']
}
```

To run the kickstart mechanism, it's required to set `import_schema` to `true`.

#### Doc
The doc module provides an interface to the Icinga 2 and Icinga Web 2 documentation.

Example:
``` puppet
include ::icingaweb2::module::doc
```

To disable:
``` puppet
class {'::icingaweb2::module::doc':
  ensure => absent
}
```

#### Puppetdb
You can configure director to query one or more PuppetDB servers.

Example: set up puppetdb module and configure two SSL keys
``` puppet
$certificates = {'pupdb1' => {
                   :ssl_key => '-----BEGIN RSA PRIVATE KEY----- abc...',
                   :ssl_cacert => '-----BEGIN RSA PRIVATE KEY----- def...', },
                 'pupdb2' => {
                   :ssl_key => '-----BEGIN RSA PRIVATE KEY----- zyx...',
                   :ssl_cacert => '-----BEGIN RSA PRIVATE KEY----- wvur...', },
                }
class {'::icingaweb2::module::puppetdb':
  git_revision => 'master',
  ssl          => 'none',
  certificates => $certificates,
}
```

Example: set up puppetdb module and configure puppet SSL key
``` puppet
class {'::icingaweb2::module::puppetdb':
  git_revision => 'master',
  ssl          => 'puppet',
}
```

Example: set up puppetdb module and configure one SSL key *and* puppet SSL key
``` puppet
class {'::icingaweb2::module::puppetdb':
  git_revision => 'master',
  ssl          => 'none',
  certificates => {
    puppetdb1 => {
      ssl_key    => '-----BEGIN RSA PRIVATE KEY----- abc...',
      ssl_cacert => '-----BEGIN RSA PRIVATE KEY----- def...',
    }
  }
}
```

#### Business Process
The Business Process module allows you to visualize and monitor business processes based on hosts and services monitored
by Icinga 2. The module is installed by cloning the git repository, therefore you need to set `git_revision` to either a
git branch or tag, eg. `master` or `v2.1.0`. 

This module has the following dependecies:
* Icinga Web 2 (>= 2.4.1)
* PHP (>= 5.3 or 7.x)

Example:
``` puppet
class { 'icingaweb2::module::businessprocess':
  git_revision => 'v2.1.0'
}
```

#### Cube
The Cube module is like a extended filtering tool. It visualizes host statistics (count and health state) grouped by
various custom variables in multiple dimensions. The module is installed by cloning the git repository, therefore you
need to set `git_revision` to either a git branch or tag, eg. `master` or `v1.0.0`. 

Example:
``` puppet
class { 'icingaweb2::module::cube':
  git_revision => 'v1.0.0'
}
```

#### GenericTTS
The GenericTTS module matches ticket pattern and replaces them with a link to your ticketsystem. The module is installed
by cloning the git repository, therefore you need to set `git_revision` to either a git branch or tag, eg. `master`
or `v2.0.0`.
 
Example:
``` puppet
class { 'icingaweb2::module::generictts':
  git_revision  => 'v2.0.0',
  ticketsystems => {
    'my-ticket-system' => {
      pattern => '/#([0-9]{4,6})/',
      url     => 'https://my.ticket.system/tickets/id=$1',
    }
}
```

## Reference

- [**Public classes**](#public-classes)
    - [Class: icingaweb2](#class-icingaweb2)
    - [Class: icingaweb2::module::monitoring](#class-icingaweb2modulemonitoring)
    - [Class: icingaweb2::module::director](#class-icingaweb2moduledirector)
    - [Class: icingaweb2::module::doc](#class-icingaweb2moduledoc)
    - [Class: icingaweb2::module::businessprocess](#class-icingaweb2modulebusinessprocess)
    - [Class: icingaweb2::module::cube](#class-icingaweb2modulecube)
    - [Class: icingaweb2::module::generictts](#class-icingaweb2modulegenerictts)
    - [Class: icingaweb2::module::puppetdb](#class-icingaweb2modulepuppetdb)
- [**Private classes**](#private-classes)
    - [Class: icingaweb2::config](#class-icingaweb2config)
    - [Class: icingaweb2::install](#class-icingaweb2install)
    - [Class: icingaweb2::params](#class-icingaweb2params)
    - [Class: icingaweb2::repo](#class-icingaweb2repo)
- [**Public defined types**](#public-defined-types)
    - [Defined type: icingaweb2::inisection](#defined-type-icingaweb2inisection)
    - [Defined type: icingaweb2::config::resource](#defined-type-icingaweb2configresource)
    - [Defined type: icingaweb2::config::authmethod](#defined-type-icingaweb2configauthmethod)
    - [Defined type: icingaweb2::config::role](#defined-type-icingaweb2configrole)
    - [Defined type: icingaweb2::config::groupbackend](#defined-type-icingaweb2configgroupbackend)
    - [Defined type: icingaweb2::module](#defined-type-icingaweb2module)
- [**Private defined types**](#private-defined-types)
    - [Defined type: icingaweb2::module::generictts::ticketsystem](#defined-type-icingaweb2modulegenericttsticketsystem)
    - [Defined type: icingaweb2::module::monitoring::commandtransport](#defined-type-modulemonitoringcommandtransport)
    - [Defined type: icingaweb2::module::puppetdb::certificate](#defined-type-icingaweb2modulepuppetdbcertificate)

### Public Classes

#### Class: `icingaweb2`
The default class of this module. It handles the basic installation and configuration of Icinga Web 2.

**Parameters of `icingaweb2`:**

##### `logging`
Whether Icinga Web 2 should log to `file` or to `syslog`. Setting `none` disables logging. Defaults to `file`

##### `logging_file`
If 'logging' is set to `file`, this is the target log file. Defaults to `/var/log/icingaweb2/icingaweb2.log`.

##### `logging_level`
Logging verbosity. Possible values are `ERROR`, `WARNING`, `INFO` and `DEBUG`. Defaults to `INFO`

##### `show_stacktraces`
Whether to display stacktraces in the web interface or not. Defaults to `false`

##### `module_path`
Path to module sources. Multiple paths must be separated by colon. Defaults to `/usr/share/icingaweb2/modules`

##### `theme`
The default theme setting. Users may override this settings. Defaults to `icinga`.

##### `theme_disabled`
Whether users can change themes or not. Defaults to `false`.

##### `manage_repo`
When set to true this module will install the packages.icinga.com repository. With this official repo you can get the
latest version of Icinga Web. When set to false the operating systems default will be used. Defaults to `false`

**NOTE**: will be ignored if manage_package is set to `false`

##### `manage_package`
If set to false packages aren't managed. Defaults to `true`

##### `extra_pacakges`
An array of packages to install additionally.

##### `import_schema``
Import database scheme. Make sure you have an existing database if you use this option. Defaults to `false`

##### `db_type`
Database type, can be either `mysql` or `pgsql`. This parameter is only used if `import_schema` is `true` or
`config_backend` is `db`. Defaults to `mysql`

##### `db_host`
Database hostname. This parameter is only used if `import_schema` is `true` or
`config_backend` is `db`. Defaults to `localhost`

##### `db_port`
Port of database host. This parameter is only used if `import_schema` is `true` or
`config_backend` is `db`. Defaults to `3306`

##### `db_name`
Database name. This parameter is only used if `import_schema` is `true` or
`config_backend` is `db`. Defaults to `icingaweb2`

##### `db_username`
Username for database access. This parameter is only used if `import_schema` is `true` or
`config_backend` is `db`.

##### `db_password`
Password for database access. This parameter is only used if `import_schema` is `true` or
`config_backend` is `db`.

##### `config_backend`
The global Icinga Web 2 preferences can either be stored in a database or in ini files. This parameter can either
be set to `db` or `ini`. Defaults to `ini`

##### `conf_user`
By default this module expects Apache2 on the server. You can change the owner of the config files with this
parameter. Default is dependent on the platform

#### Class: `icingaweb2::module::monitoring`
Manage the monitoring module. This module is mandatory for probably every setup.

**Parameters of `icingaweb2::module::monitoring`:**

##### `ensure`
Enable or disable module. Defaults to `present`

##### `protected_customvars`
Custom variables in Icinga 2 may contain sensible information. Set patterns for custom variables that should be hidden
in the web interface. Defaults to `*pw*,*pass*,community`

##### `ido_type`
Type of your IDO database. Either `mysql` or `pgsql`. Defaults to `mysql`

##### `ido_host`
Hostname of the IDO database.

##### `ido_port`
Port of the IDO database. Defaults to `3306`

##### `ido_db_name`
Name of the IDO database.

##### `ido_db_username`
Username for IDO DB connection.

##### `ido_db_password`
Password for IDO DB connection.

##### `commandtransports`
A hash of command transports.

Example:
``` puppet
  commandtransports => {
    icinga2 => {
      transport => 'api',
      username  => 'root',
      password  => 'icinga',
    }
  }
```

#### Class: `icingaweb2::module::director`
Install and configure the director module.

**Parameters of `icingaweb2::module::director`:**

##### `ensure`
Enable or disable module. Defaults to `present`

##### `git_repository`
Set a git repository URL. Defaults to github.

##### `git_revision`
Set either a branch or a tag name, eg. `master` or `v1.3.2`.

##### `db_type`
Type of your database. Either `mysql` or `pgsql`. Defaults to `mysql`

##### `db_host`
Hostname of the database.

##### `db_port`
Port of the database. Defaults to `3306`

##### `db_name`
Name of the database.

##### `db_username`
Username for DB connection.

##### `db_password`
Password for DB connection.

##### `import_schema`
Import database schema. Defaults to `false`

##### `kickstart`
Run kickstart command after database migration. This requires `import_schema` to be `true`. Defaults to `false`

##### `endpoint`
Endpoint object name of Icinga 2 API. This setting is only valid if `kickstart` is `true`.

##### `api_host`
Icinga 2 API hostname. This setting is only valid if `kickstart` is `true`. Defaults to `localhost`

##### `api_port`
Icinga 2 API port. This setting is only valid if `kickstart` is `true`. Defaults to `5665`

##### `api_username`
Icinga 2 API username. This setting is only valid if `kickstart` is `true`.

##### `api_password`
Icinga 2 API password. This setting is only valid if `kickstart` is `true`.

#### Class: `icingaweb2::module::doc`
Install and configure the doc module.

**Parameters of `icingaweb2::module::doc`:**

##### `ensure`
Enable or disable module. Defaults to `present`

#### Class: `icingaweb2::module::businessprocess`
Install and enable the businessprocess module.

**Parameters of `icingaweb2::module::businessprocess`:**

##### `ensure`
Enable or disable module. Defaults to `present`

##### `git_repository`
Set a git repository URL. Defaults to github.

##### `git_revision`
Set either a branch or a tag name, eg. `master` or `v2.1.0`.

#### Class: `icingaweb2::module::cube`
Install and configure the cube module.

**Parameters of `icingaweb2::module::cube`:**
The cube module is installed by cloning the git repository. Set either a branch or a tag name, eg. `master`
or `v1.0.0`.

##### `ensure`
Enable or disable module. Defaults to `present`

##### `git_repository`
Set a git repository URL. Defaults to github.

##### `git_revision`
Set either a branch or a tag name, eg. `master` or `v1.0.0`.

#### Class: `icingaweb2::module::generictts`
Install and enable the generictts module.

**Parameters of `icingaweb2::module::generictts`:**

##### `ensure`
Enable or disable module. Defaults to `present`

##### `git_repository`
Set a git repository URL. Defaults to github.

##### `git_revision`
Set either a branch or a tag name, eg. `master` or `v2.0.0`.

##### `ticketsystems`
A hash of ticketsystems. The hash expects a `patten` and a `url` for each ticketsystem. The regex pattern is to match
the ticket ID, eg. `/#([0-9]{4,6})/`. Place the ticket ID in the URL, eg. `https://my.ticket.system/tickets/id=$1`

Example:
``` puppet 
ticketsystems => {
  system1 => {
    pattern => '/#([0-9]{4,6})/',
    url     => 'https://my.ticket.system/tickets/id=$1'
  }
}
```

##### `ensure`
Enable or disable module. Defaults to `present`

#### Class: `icingaweb2::module::puppetdb`
Install and configure the puppetdb module.

**Parameters of `icingaweb2::module::puppetdb`:**

##### `ensure`
Enable or disable module. Defaults to `present`

##### `git_repository`
Set a git repository URL. Defaults to github.

##### `git_revision`
Set either a branch or a tag name, eg. `master` or `v1.3.2`.

##### `ssl`
How to set up ssl certificates. To copy certificates from the local puppet installation, use `puppet`. Defaults to
`none`

##### `certificates`
Hash with SSL certificates to configure.  See `icingaweb2::module::puppetdb::certificate`.
>>>>>>> Implement icingaweb2::module::puppetdb class and icingaweb2::module::puppetdb::certificate type

### Private Classes

#### Class: `icingaweb2::config`
Installs basic configuration files required to run Icinga Web 2.

#### Class: `icingaweb2::install`
Handles the installation of the Icinga Web 2 package.

#### Class: `icingaweb2::params`
Stores all default parameters for the Icinga Web 2 installation.

#### Class: `icingaweb2::repo`
Installs the [packages.icinga.com] repository. Depending on your operating system [puppetlabs/apt] or
[puppet/zypprepo] are required.

### Public Defined Types

#### Defined type: `icingaweb2::inisection`
Manage settings in INI configuration files.

**Parameters of `icingaweb2::inisection`:**

##### `target`
Absolute path to the configuration file.

##### `section_name`
Name of the target section. Settings are set under `[$section_name]`

##### `settings`
A hash of settings and their settings. Single settings may be set to absent.

##### `order`
Ordering of the INI section within a file. Defaults to `01`

#### Defined type: `icingaweb2::config::resource`
Manage settings in INI configuration files.

**Parameters of `icingaweb2::config::resource`:**

##### `resource_name`
Name of the resources. Resources are referenced by their name in other configuration sections.

##### `type`
Supported resource types are `db` and `ldap`.

##### `host`
Connect to the database or ldap server on the given host. For using unix domain sockets, specify `localhost` for MySQL
and the path to the unix domain socket directory for PostgreSQL. When using the 'ldap' type you can also provide
multiple hosts separated by a space.

##### `port`
Port number to use.

##### `db_type`
Supported DB types are `mysql` and `pgsql`. Only valid when `type` is `db`.

##### `db_name`
The database to use. Only valid if `type` is `db`.

##### `db_username`
The username to use when connecting to the server. Only valid if `type` is `db`.

##### `db_password`
The password to use when connecting to the server. Only valid if `type` is `db`.

##### `db_charset`
The character set to use for the database connection. Only valid if `type` is `db`.

##### `ldap_root_dn`
Root object of the tree, e.g. `ou=people,dc=icinga,dc=com`. Only valid if `type` is `ldap`.

##### `ldap_bind_dn`
The user to use when connecting to the server. Only valid if `type` is `ldap`.

##### `ldap_bind_pw`
The password to use when connecting to the server. Only valid if `type` is `ldap`.

##### `ldap_encryption`
Type of encryption to use: `none` (default), `starttls`, `ldaps`. Only valid if `type` is `ldap`.

#### Defined type: `icingaweb2::config::authmethod`
Manage Icinga Web 2 authentication methods. Auth methods may be chained by setting proper ordering. Some backends
require additional resources.

**Parameters of `icingaweb2::config::authmethod`:**

##### `backend`
Select between 'external', 'ldap', 'msldap' or 'db'. Each backend may require other settings.

##### `resource`
The name of the resource defined in resources.ini.

##### `ldap_user_class`
LDAP user class. Only valid if `backend` is `ldap`.

##### `ldap_user_name_attribute`
LDAP attribute which contains the username. Only valid if `backend` is `ldap`.

##### `ldap_filter`
LDAP search filter. Only valid if `backend` is `ldap`.

##### `ldap_base_dn`
LDAP base DN. Only valid if `backend` is `ldap`.

##### `order`
Multiple authentication methods can be chained. The order of entries in the authentication configuration determines
the order of the authentication methods. Defaults to `01`

#### Defined type: `icingaweb2::config::role`
Roles define a set of permissions that may be applied to users or groups.

**Parameters of `icingaweb2::config::role`:**

##### `role_name`
Name of the role.

##### `users`
Comma separated list of users this role applies to.

##### `groups`
Comma separated list of groups this role applies to.

##### `permissions`
Comma separated lsit of permissions. Each module may add it's own permissions. Examples are

* Allow everything: `*`
* Allow config access: `config/*`
* Allow access do module monitoring: `module/monitoring`
* Allow scheduling checks: `monitoring/command/schedule-checks`
* Grant admin permissions: `admin`

##### `filters`
Hash of filters. Modules may add new filter keys, some sample keys are:

* `application/share/users`
* `application/share/groups`
* `monitoring/filter/objects`
* `monitoring/blacklist/properties`

A string value is expected for each used key. For example:
* monitoring/filter/objects = `host_name!=*win*`

#### Defined type: `icingaweb2::config::groupbackend`
Groups of users can be stored either in a database, LDAP or ActiveDirectory. This defined type configures backends that
store groups.

**Parameters of `icingaweb2::config::groupbackend`:**

##### `group_name`
Name of the resources. Resources are referenced by their name in other configuration sections.

##### `backend`
Type of backend. Valide values are: `db`, `ldap` and `msldap`. Each backend supports different settings, see the
parameters for detailed information.

##### `resource`
The resource used to connect to the backend. The resource contains connection information.

##### `ldap_user_backend`
A group backend can be connected with an authentication method. This parameter references the auth method. Only
valid with backend `ldap` or `msldap`.

##### `ldap_group_class`
Class used to identify group objects. Only valid with backend `ldap`.

##### `ldap_group_filter`
Use a LDAP filter to receive only certain groups. Only valid with backend `ldap` or `msldap`.

##### `ldap_group_name_attribute`
The group name attribute. Only valid with backend `ldap`.

##### `ldap_group_member_attribute`
The group member attribute. Only valid with backend `ldap`.

##### `ldap_base_dn`
Base DN that is searched for groups. Only valid with backend `ldap` with `msldap`.

##### `ldap_nested_group_search`
Search for groups in groups. Only valid with backend `msldap`.

#### Defined type: `icingaweb2::module`
Download, enable and configure Icinga Web 2 modules. This is a public defined type and is meant to be used to install
modules developed by the community as well.

**Parameters of `icingaweb2::module`:**

##### `ensure`
Enable or disable module. Defaults to `present`

##### `module`
Name of the module.

##### `module_dir`
Target directory of the module.

##### `install_method`
Install methods are `git`, `package` and `none` is supported as installation method. Defaults to `git`

##### `git_repository`
Git repository of the module. This setting is only valid in combination with the installation method `git`.

##### `git_revision`
Tag or branch of the git repository. This setting is only valid in combination with the installation method `git`.

#### `package_name`
Package name of the module. This setting is only valid in combination with the installation method `package`.

##### `settings`
A hash with the module settings. Multiple configuration files with ini sections can be configured with this hash. The
`module_name` should be used as target directory for the configuration files.

Example:

``` puppet 
 $conf_dir        = $::icingaweb2::params::conf_dir
 $module_conf_dir = "${conf_dir}/modules/mymodule"

 $settings = {
   'section1' => {
     'target'   => "${module_conf_dir}/config1.ini",
     'settings' => {
       'setting1' => 'value1',
       'setting2' => 'value2',
     }
   },
   'section2' => {
     'target'   => "${module_conf_dir}/config2.ini",
     'settings' => {
       'setting3' => 'value3',
       'setting4' => 'value4',
     }
   }
 }
```

### Private Defined Types

#### Defined type: `icingaweb2::module::generictts::ticketsystem`
Manage ticketsystem configuration for the generictts module.

**Parameters of `icingaweb2::module::generictts::ticketsystem`:**

##### `ticketsystem`
The name of the ticketsystem.

##### `pattern`
A regex pattern to match ticket numbers, eg. `/#([0-9]{4,6})/`

##### `url`
The URL to your ticketsystem. Place the ticket ID in the URL, eg. `https://my.ticket.system/tickets/id=$1`

#### Defined type: `icingaweb2::module::monitoring::commandtransport`
Manage commandtransports for the monitoring module.

**Parameters of `icingaweb2::module::monitoring::commandtransport`:**

##### `commandtransport`
The name of the commandtransport.

##### `transport`
The transport type you wish to use. Either `api` or `local`. Defaults to `api`

##### `host`
Hostname/ip for the transport. Only needed for api transport. Defaults to `localhost`

##### `port`
Port for the transport. Only needed for api transport. Defaults to `5665`

##### `username`
Username for the transport. Only needed for api transport.

##### `password`
Password for the transport. Only needed for api transport.

##### `path`
Path for the transport. Only needed for local transport. Defaults to `/var/run/icinga2/cmd/icinga2.cmd`

#### Defined type: `icingaweb2::module::puppetdb::certificate`

Add extra certificates to the puppetdb module

**Parameters of `icingaweb2::module::puppetdb::certificate`:**

##### `ensure`
Enable or disable certificate. Defaults to `present`

##### `ssl_key`
Contents of the combined SSL key.

##### `ssl_cacert`
CA certificate

## Development
A roadmap of this project is located at https://github.com/Icinga/puppet-icingaweb2/milestones. Please consider
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


[Icinga 2]: https://www.icinga.com/products/icinga-2/
[Icinga Web 2]: https://www.icinga.com/products/icinga-web-2/

[puppetlabs/apt]: https://github.com/puppetlabs/puppetlabs-apt
[puppet/zypprepo]: https://forge.puppet.com/puppet/zypprepo
[puppetlabs/stdlib]: https://github.com/puppetlabs/puppetlabs-stdlib
[puppetlabs/concat]: https://github.com/puppetlabs/puppetlabs-concat
[puppetlabs/vcsrepo]: https://forge.puppet.com/puppetlabs/vcsrepo
[puppetlabs/mysql]: https://github.com/puppetlabs/puppetlabs-mysql
[puppetlabs/puppetlabs-postgresql]: https://github.com/puppetlabs/puppetlabs-postgresql
[packages.icinga.com]: https://packages.icinga.com

[CHANGELOG.md]: CHANGELOG.md
[AUTHORS]: AUTHORS
[RELEASE.md]: RELEASE.md
[TESTING.md]: TESTING.md
[CONTRIBUTING.md]: CONTRIBUTING.md
