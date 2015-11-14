#grafana

####Table of Contents

1. [Overview - What is the grafana module?](#overview)
2. [Module Description - What does this module do?](#module-description)
3. [Setup - The basics of getting started with grafana](#setup)
    * [Beginning with grafana - Installation](#beginning-with-grafana)
    * [Configure Graphite and Elasticsearch](#configure-graphite-and-elasticsearch)
    * [Configure InlfuxDB](#configure-inlfuxdb)
4. [Usage - The class and available configurations](#usage)
7. [Requirements](#requirements)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Contributing to the grafana module](#contributing)

##Overview

This module installs and configures for grafana.

##Module Description

[Grafana](http://http://grafana.org/) is an open source, metrics dashboard and graph editor for Graphite, InfluxDB and OpenTSDB.

This module is intended to be used in combination with [puppet-graphite](https://forge.puppetlabs.com/dwerder/graphite). At the
moment you will need modules like apache or nginx to configure the webservices which will serve the grafana scripts.

Github Master: [![Build Status](https://secure.travis-ci.org/echocat/puppet-grafana.png?branch=master)](https://travis-ci.org/echocat/puppet-grafana)

##Setup

**What grafana affects:**

* dowloads/installs/configures files for Grafana

###Beginning with Grafana

Install Grafana with default parameters. In this case grafana will be
installed at /opt/grafana and it will listen on localhost:80 for a graphite
server. You will also need the apache module (or nginx, etc.)

Here we configure Apache 2.2 with Grafana on port 8080.
```puppet

  class { 'apache': default_vhost => false }

  apache::vhost { 'my.grafana.domain':
    servername      => 'my.grafana.domain',
    port            => 8080,
    docroot         => '/opt/grafana',
    error_log_file  => 'grafana_error.log',
    access_log_file => 'grafana_access.log',
    directories     => [
      {
        path            => '/opt/grafana',
        options         => [ 'None' ],
        allow           => 'from All',
        allow_override  => [ 'None' ],
        order           => 'Allow,Deny',
      }
    ]
  }->
  class { 'grafana': }
```

###Configure Graphite and Elasticsearch

```puppet
  class {'grafana':
    graphite_host      => 'graphite.my.domain',
    elasticsearch_host => 'elasticsearch.my.domain',
  }
```

###Configure InlfuxDB

When we use InfluxDB we have to set the _user_ and _password_ to access the influxdb_dbpath.
And we need the user and password for the database /db/grafana, which has to exist on the influxdb.

```puppet
  class {'grafana':
    influxdb_host   => 'influxdb.my.domain',
    influxdb_dbpath => '/db/dbname',
    influxdb_user   => 'grafana',
    influxdb_pass   => 'grafana',
    influxdb_grafana_user   => 'grafana',
    influxdb_grafana_pass   => 'grafana',
  }
```

##Usage

####Class: `grafana`

This is the primary class. And the only one which should be used.

**Parameters within `graphite`:**

#####`version`

Version of grafan to be installed.
Default is '1.9.1'

#####`install_dir`

Install directory of grafana.
Default is '/opt'

#####`graphite_scheme`

Scheme of graphite service.
Default is 'http'

#####`graphite_host`

Hostname of graphite server.
Default is 'localhost'

#####`graphite_port`

Port of graphite service.
Default is 80

#####`elasticsearch_scheme`

Scheme of elasticsearch service.
Default is 'http'

#####`elasticsearch_host`

Hostname of elasticsearch. You will need an elasticsearch
for saving dashboards
Default is '' (empty)

#####`elasticsearch_port`

Port of elasticsearch service.
Default is 9200

#####`elasticsearch_index`

Name of elasticsearch index.
Default is 'grafana-dash;

#####`opentsdb_scheme`

Scheme of OpenTSDB service.
Default is 'http'

#####`opentsdb_host`

Hostname of OpenTSDB.
Default is '' (empty)

#####`opentsdb_port`

Port of OpenTSDB service.
Default is 4242

#####`influxdb_scheme`

Scheme of influxdb.
Default is 'http'

#####`influxdb_host`

Hostname of influxdb.
Default is '' (empty)

#####`influxdb_port`

Port of influxdb.
Default is 8086

#####`influxdb_dbpath`

DB path of influxdb.
Default is '/db/grafana'

#####`influxdb_user`

Name of db user.
Default is 'grafana'

#####`influxdb_pass`

Password of db user.
Default is 'grafana'

#####`timezone_offset`

If you experiance problems with zoom, it is probably caused by timezone diff between
your browser and the graphite-web application. timezoneOffset setting can be used to have Grafana
translate absolute time ranges to the graphite-web timezone.
Example:
  If TIME_ZONE in graphite-web config file local_settings.py is set to America/New_York, then set
  timezoneOffset to "-0500" (for UTC - 5 hours)
Example:
  If TIME_ZONE is set to UTC, set this to "0000"
Default is '0000'

#####`playlist_timespan`

Playlist timespan.
Default is '1m'

#####`max_results`

Specify the limit for dashboard search results.
Default is 20

#####`default_route`

Default dashboard to route to.
Default is '/dashboard/file/default.json'

##Requirements

###Modules needed:

stdlib by puppetlabs

###Modules recommend:

[puppet-graphite](https://github.com/echocat/puppet-graphite) for graphite installation.

##Limitations

This module is tested on CentOS 6.5 and should also run without problems on

* RHEL/CentOS/Scientific 6+
* Debian 6+
* Ubunutu 10.04 and newer

This module provides only the Grafana installation and config. The webservice to serve Grafana has to be realized with modules like apache.

##Contributing

Echocat modules are open projects. So if you want to make this module even better, you can contribute to this module on [Github](https://github.com/echocat/puppet-grafana).
