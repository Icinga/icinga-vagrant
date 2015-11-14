#graphite

####Table of Contents

1. [Overview - What is the graphite module?](#overview)
2. [Module Description - What does this module do?](#module-description)
3. [Setup - The basics of getting started with graphite](#setup)
    * [Beginning with graphite - Installation](#beginning-with-graphite)
    * [Configure MySQL and Memcached](#configure-mysql-and-memcached)
    * [Configure Graphite with Grafana](#configure-graphite-with-grafana)
    * [Configuration with Apache 2.4 and CORS](#configuration-with-apache-24-and-cors)
    * [Configuration with Additional LDAP Options](#configuration-with-additional-ldap-options)
    * [Configuration with multiple cache, relay and/or aggregator instances](#configuration-with-multiple-cache-relay-andor-aggregator-instances)

4. [Usage - The class and available configurations](#usage)
5. [Requirements](#requirements)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Contributing to the graphite module](#contributing)

##Overview

This module installs and makes basic configs for graphite, with carbon and whisper.

##Module Description

[Graphite](http://graphite.readthedocs.org/en/latest/overview.html), and its components Carbon and Whisper, is an enterprise-scale monitoring tool. This module sets up a simple graphite server with all its components. Furthermore it can be used to set up more complex graphite environments with metric aggregation, clustering and so on.

##Setup

**What graphite affects:**

* packages/services/configuration files for Graphite
* on default sets up webserver (can be disabled if manage by other module)

###Beginning with Graphite

To install Graphite with default parameters

```puppet
    class { 'graphite': }
```

The defaults are determined by your operating system e.g. Debian systems have one set of defaults, and RedHat systems have another). This defaults should work well on testing environments with graphite as a standalone service on the machine. For production use it is recommend to use a database like MySQL and cache data in memcached (not installed with this module) and configure it here. Furthermore you should check things like `gr_storage_schemas`.

###Configure MySQL and Memcached

```puppet
  class { 'graphite':
    gr_max_updates_per_second => 100,
    gr_timezone               => 'Europe/Berlin',
    secret_key                => 'CHANGE_IT!',
    gr_storage_schemas        => [
      {
        name       => 'carbon',
        pattern    => '^carbon\.',
        retentions => '1m:90d'
      },
      {
        name       => 'special_server',
        pattern    => '^longtermserver_',
        retentions => '10s:7d,1m:365d,10m:5y'
      },
      {
        name       => 'default',
        pattern    => '.*',
        retentions => '60:43200,900:350400'
      }
    ],
    gr_django_db_engine       => 'django.db.backends.mysql',
    gr_django_db_name         => 'graphite',
    gr_django_db_user         => 'graphite',
    gr_django_db_password     => 'MYsEcReT!',
    gr_django_db_host         => 'mysql.my.domain',
    gr_django_db_port         => '3306',
    gr_memcache_hosts         => ['127.0.0.1:11211']
  }
```

###Configure Graphite with Grafana

This setup will use the [puppetlabs-apache](https://forge.puppetlabs.com/puppetlabs/apache) and [dwerder-grafana](https://forge.puppetlabs.com/dwerder/grafana) modules to setup a graphite system with grafana frontend. You will also need an elasticsearch as it is required for grafana.

```puppet
include '::apache'

apache::vhost { graphite.my.domain:
  port    => '80',
  docroot => '/opt/graphite/webapp',
  wsgi_application_group      => '%{GLOBAL}',
  wsgi_daemon_process         => 'graphite',
  wsgi_daemon_process_options => {
    processes          => '5',
    threads            => '5',
    display-name       => '%{GROUP}',
    inactivity-timeout => '120',
  },
  wsgi_import_script          => '/opt/graphite/conf/graphite.wsgi',
  wsgi_import_script_options  => {
    process-group     => 'graphite',
    application-group => '%{GLOBAL}'
  },
  wsgi_process_group          => 'graphite',
  wsgi_script_aliases         => {
    '/' => '/opt/graphite/conf/graphite.wsgi'
  },
  headers => [
    'set Access-Control-Allow-Origin "*"',
    'set Access-Control-Allow-Methods "GET, OPTIONS, POST"',
    'set Access-Control-Allow-Headers "origin, authorization, accept"',
  ],
  directories => [{
    path => '/media/',
    order => 'deny,allow',
    allow => 'from all'}
  ]
}->
class { 'graphite':
  gr_web_server           => 'none',
  gr_disable_webapp_cache => true,
}

apache::vhost { 'grafana.my.domain':
  servername      => 'grafana.my.domain',
  port            => 80,
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
class {'grafana':
  graphite_host      => 'graphite.my.domain',
  elasticsearch_host => 'elasticsearach.my.domain',
  elasticsearch_port => 9200,
}
```

###Configuration with Apache 2.4 and CORS

If you use a system which ships Apache 2.4, then you will need a slightly different vhost config.
Here is an example with Apache 2.4 and [CORS](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing) enabled.
If you do not know what CORS, then do not use it. Its disabled by default. You will need CORS for Webguis like Grafana.

```puppet
  class { 'graphite':
    gr_apache_24               => true,
    gr_web_cors_allow_from_all => true,
    secret_key                 => 'CHANGE_IT!'
  }
```

###Configuration with Additional LDAP Options

If additional LDAP parameters are needed for your Graphite installation, you can specify them using the `gr_ldap_options`
parameter. For example, this is useful if you're using SSL and need to configure LDAP to use your SSL cert and key files.

This Puppet configuration...

```puppet
  class { 'graphite':
    gr_ldap_options => {
      'ldap.OPT_X_TLS_REQUIRE_CERT' => 'ldap.OPT_X_TLS_ALLOW',
      'ldap.OPT_X_TLS_CACERTDIR'    => '"/etc/ssl/ca"',
      'ldap.OPT_X_TLS_CERTFILE'     => '"/etc/ssl/mycert.crt"',
      'ldap.OPT_X_TLS_KEYFILE'      => '"/etc/ssl/mykey.pem"',
    },
  }
```

... adds these lines to the local_settings.py configuration file for Graphite web.

```python
import ldap
ldap.set_option(ldap.OPT_X_TLS_CACERTDIR, "/etc/ssl/ca")
ldap.set_option(ldap.OPT_X_TLS_CERTFILE, "/etc/ssl/mycert.crt")
ldap.set_option(ldap.OPT_X_TLS_KEYFILE, "/etc/ssl/mykey.pem")
ldap.set_option(ldap.OPT_X_TLS_REQUIRE_CERT, ldap.OPT_X_TLS_ALLOW)
```

See http://www.python-ldap.org/ for more details about these options.

###Configuration with multiple cache, relay and/or aggregator instances

You could create more than one instance for cache, relay or aggregator using the `gr_cache_instances`,
`gr_relay_instances` and `gr_aggregator_instances` parameters. These paremeters must be hashes, and the keys are the name of the instances (cache:b, cache:c, relay:b, relay:c, etc.). Every hash must have an array of parameters which will be written as is in the config file. The defaults settings for the additional instances will be the
ones set for the principal instance.

```puppet
   class {'graphite':
      gr_line_receiver_port => 2003,
      gr_pickle_receiver_port => 2004, 
      gr_cache_query_port => 7002,
      
      gr_cache_instances => {
         'cache:b' => {
            'LINE_RECEIVER_PORT' => 2103,
            'PICKLE_RECEIVER_PORT' => 2104,
            'CACHE_QUERY_PORT' => 7102,
         },
         'cache:c' => {
            'LINE_RECEIVER_PORT' => 2203,
            'PICKLE_RECEIVER_PORT' => 2204,
            'CACHE_QUERY_PORT' => 7202,
         }
      }
   }
```

So in this case you would have 3 cache instances, the first one is `cache` (you can refer to it as `cache:a` too), `cache:b` and `cache:c`. cache:a will listen on ports 2003, 2004 and 7002 for line, pickle and query respectively. But, cache:b will do it on ports 2103, 2104, and 7102, and cache:c on 2203, 2204 and 7202. All other parameters from cache:a will be inherited by cache:b and c.

###Installing with something other than pip and specifying package names and versions
If you need to install via something other pip, an internal apt repo with fpm converted packages for instance, you can set `gr_pip_install` to false.
If you're doing this you'll most likely have to override the default package names and versions as well. 
```puppet
  class { '::graphite':
    gr_pip_install        => false,
    gr_django_tagging_pkg => 'python-django-tagging',
    gr_django_tagging_ver => 'present',
    gr_twisted_pkg        => 'python-twisted',
    gr_twisted_ver        => 'present',
    gr_txamqp_pkg         => 'python-txamqp',
    gr_txamqp_ver         => 'present',
    gr_graphite_pkg       => 'python-graphite-web',
    gr_graphite_ver       => 'present',
    gr_carbon_pkg         => 'python-carbon',
    gr_carbon_ver         => 'present',
    gr_whisper_pkg        => 'python-whisper',
    gr_whisper_ver        => 'present',
  }
```

Additionally, the Django package is normally installed from a system package, but can be changed to install from pip instead.
```puppet
  class { '::graphite':
    gr_django_pkg      => 'django',
    gr_django_ver      => '1.5',
    gr_django_provider => 'pip',
  }
```

##Usage

####Class: `graphite`

This is the primary class. And the only one which should be used.

**Parameters within `graphite`:**

#####`gr_group`

Default is empty. The group of the user (see gr_user) who runs graphite.

#####`gr_user`

Default is empty. The user who runs graphite. If this is empty carbon runs as the user that invokes it.

#####`gr_enable_carbon_cache`

Default is true. Enable carbon cache.

#####`gr_max_cache_size`

Default is 'inf'. Limits the size of the cache to avoid swapping or becoming CPU bound. Use the value "inf" (infinity) for an unlimited cache size.

#####`gr_max_updates_per_second`

Default is 500. Limits the number of whisper update_many() calls per second, which effectively means the number of write requests sent to the disk.

#####`gr_max_updates_per_second_on_shutdown`

Default is 'undef' (no limit change on shutdown). Change the limits of gr_max_updates_per_second in case of an stop/shutdown event to speed up/slow down the shutdown process.

#####`gr_max_creates_per_minute`

Default is 50. Softly limits the number of whisper files that get created each minute.

#####`gr_carbon_metric_prefix`

The prefix to be applied to internal performance metrics. Defaults to 'carbon'.

#####`gr_carbon_metric_interval`

Default is 60. Set the interval between sending internal performance metrics; affects all carbon daemons.

#####`gr_line_receiver_interface`

Default is '0.0.0.0' (string). Interface the line receiver listens.

#####`gr_line_receiver_port`

Default is 2003. Port of line receiver.

#####`gr_enable_udp_listener`

Default is 'False' (string). Set this to True to enable the UDP listener.

#####`gr_udp_receiver_interface`

Default is '0.0.0.0' (string). Its clear, isnt it?

#####`gr_udp_receiver_port`

Default is 2003. Self explaining.

#####`gr_pickle_receiver_interface`

Default is '0.0.0.0' (string). Pickle is a special receiver who handle tuples of data.

#####`gr_pickle_receiver_port`

Default is 2004. Self explaining

#####`gr_log_listener_connections`

Default is 'True' (string). Logs successful connections

#####`gr_use_insecure_unpickler`

Default is 'False' (string). Set this to 'True' to revert to the old-fashioned insecure unpickler.

#####`gr_use_whitelist`

Default is 'False' (string). Set this to 'True' to enable whitelists and blacklists.

#####`gr_whitelist`

List of patterns to be included in whitelist.conf. Default is [ '.*' ].

#####`gr_blacklist`

List of patterns to be included in blacklist.conf. Default is [ ].

#####`gr_cache_query_interface`

Default is '0.0.0.0'. Interface to send cache queries to.

#####`gr_cache_query_port`

Default is 7002. Self explaining.

#####`gr_timezone`

Default is 'GMT' (string). Timezone for graphite to be used.

#####`gr_local_data_dir`

Default is '/opt/graphite/storage/whisper'. Set location of whisper files.

#####`gr_storage_schemas`

Default is
```
[
  {
    name       => 'carbon',
    pattern    => '^carbon\.',
    retentions => '1m:90d'
  },
  {
    name       => 'default',
    pattern    => '.*',
    retentions => '1s:30m,1m:1d,5m:2y'
  }
]
```
The storage schemas, which describes how long matching graphs are to be stored in detail.

#####`gr_storage_aggregation_rules`

Default is the Hashmap:
```
{
  '00_min'         => { pattern => '\.min$',   factor => '0.1', method => 'min' },
  '01_max'         => { pattern => '\.max$',   factor => '0.1', method => 'max' },
  '02_sum'         => { pattern => '\.count$', factor => '0.1', method => 'sum' },
  '99_default_avg' => { pattern => '.*',       factor => '0.5', method => 'average'}
}
```
The storage aggregation rules.

#####`gr_web_server`

Default is 'apache'. The web server to use. Valid values are 'apache', 'nginx', 'wsgionly' or 'none'. 'nginx' is only supported on Debian-like systems. And 'none' means that you will manage the webserver yourself.

#####`gr_web_servername`

Default is `$::fqdn` (string). Virtualhostname of Graphite webgui.

#####`gr_web_cors_allow_from_all`

Default is false (boolean). Include CORS Headers for all hosts (*) in web server config.
This is needed for tools like Grafana.

#####`gr_use_ssl`

If true, alter web server config to enable SSL. Default is false (boolean).

#####`gr_ssl_cert`

Path to SSL cert file. Default is undef.

#####`gr_ssl_key`

Path to SSL key file. Default is undef.

#####`gr_ssl_dir`

Path to SSL dir containing keys and certs. Default is undef.

#####`gr_web_group`

Default is undef. Group name to chgrp the files that will served by webserver.  Use only with gr_web_server => 'wsgionly' or 'none'.

#####`gr_web_user`

Default is undef. Username to chown the files that will served by webserver.  Use only with gr_web_server => 'wsgionly' or 'none'.

#####`gr_apache_port`

Default is 80. The HTTP port apache will use.

#####`gr_apache_port_https`

Default is 443. The HTTPS port apache will use.

#####`gr_apache_conf_template`

Template to use for Apache vhost config. Default is 'graphite/etc/apache2/sites-available/graphite.conf.erb'.

#####`gr_apache_conf_prefix`

Default is '' (String). Prefix of the Apache config file. Useful if you want to change the order of the virtual hosts to be loaded.
For example: '000-'

#####`gr_apache_24`

Boolean to enable configuration parts for Apache 2.4 instead of 2.2
Default is false/true (autodected. see params.pp)

#####`gr_apache_noproxy`

Optional setting to disable proxying of requests. When set, will supply a value to 'NoProxy'.
```
{
  gr_apache_noproxy   => "0.0.0.0/0"
}
```
Will insert:
```
  NoProxy 0.0.0.0/0
```
In the /etc/apache2/conf.d/graphite.conf file.

#####`gr_django_1_4_or_less`

Default is false (boolean). Django settings style.

#####`gr_django_db_engine`

Default is 'django.db.backends.sqlite3' (string). Can be set to

- django.db.backends.postgresql  <- Removed in Django 1.4
- django.db.backends.postgresql_psycopg2
- django.db.backends.mysql
- django.db.backends.sqlite3
- django.db.backends.oracle

#####`gr_django_db_name`

Default is '/opt/graphite/storage/graphite.db' (string). Name of database to be used by django.

#####`gr_django_db_user`

Default is '' (string). Name of database user.

#####`gr_django_db_password`

Default is '' (string). Password of database user.

#####`gr_django_db_host`

Default is '' (string). Hostname/IP of database server.

#####`gr_django_db_port`

Default is '' (string). Port of database.

#####`gr_enable_carbon_relay`

Default is false. Enable carbon relay.

#####`gr_relay_line_interface`

Default is '0.0.0.0' (string)

#####`gr_relay_line_port`

Default is 2013 (integer)

#####`gr_relay_pickle_interface`

Default is '0.0.0.0' (string)

#####`gr_relay_pickle_port`

Default is 2014 (integer)

#####`gr_relay_log_listener_connections`

Default is 'True' (string). Logs successful connections

#####`gr_relay_method`

Default is 'rules'

#####`gr_relay_replication_factor`

Default is 1 (integer). Add redundancy by replicating every datapoint to more than one machine.

#####`gr_relay_destinations`

Default  is [ '127.0.0.1:2004' ] (array). Array of backend carbons for relay.

#####`gr_relay_max_queue_size`

Default is 10000 (integer)

#####`gr_relay_use_flow_control`

Default is 'True' (string).

#####`gr_relay_rules`

Relay rule set.
Default is
```
{
   all       => { pattern      => '.*',
                  destinations => [ '127.0.0.1:2004' ] },
   'default' => { 'default'    => true,
                  destinations => [ '127.0.0.1:2004:a' ] },
}
```

#####`gr_enable_carbon_aggregator`

Default is false (boolean) Enable the carbon aggregator daemon.

#####`gr_aggregator_line_interface`

Default is '0.0.0.0' (string). Address for line interface to listen on.

#####`gr_aggregator_line_port`

Default is 2023. TCP port for line interface to listen on.

#####`gr_aggregator_enable_udp_listener`

Default is 'False' (string). Set this to True to enable the UDP listener.

#####`gr_aggregator_udp_receiver_interface`

Default is '0.0.0.0' (string). Its clear, isnt it?

#####`gr_aggregator_udp_receiver_port`

Default is 2023. Self explaining.

#####`gr_aggregator_pickle_interface`

Default is '0.0.0.0' (string). IP address for pickle interface.

#####`gr_aggregator_pickle_port`

Default is 2024. Pickle port.

#####`gr_aggregator_log_listener_connections`

Default is 'True' (string). Logs successful connections

#####`gr_aggregator_forward_all`

Default is 'True' (string). Forward all metrics to the destination(s) defined in  `gr_aggregator_destinations`.

#####`gr_aggregator_destinations`

Default is [ '127.0.0.1:2004' ] (array). Array of backend carbons.

#####`gr_aggregator_max_queue_size`

Default is 10000. Maximum queue size.

#####`gr_aggregator_use_flow_control`

Default is 'True' (string). Enable flow control Can be True or False.

#####`gr_aggregator_max_intervals`

Default is 5. Maximum number intervals to keep around.

#####`gr_aggregator_rules`

Default is
```
{
  'carbon-class-mem'  => 'carbon.all.<class>.memUsage (60) = sum carbon.<class>.*.memUsage',
  'carbon-all-mem'    => 'carbon.all.memUsage (60) = sum carbon.*.*.memUsage',
}
```
Hashmap of carbon aggregation rules.

#####`gr_memcache_hosts`

Default is undef (array). List of memcache hosts to use. eg ['127.0.0.1:11211','10.10.10.1:11211']

#####`secret_key`

Default is 'UNSAFE_DEFAULT' (string). CHANGE IT! Secret used as salt for things like hashes, cookies, sessions etc. Has to be the same on all nodes of a graphite cluster.

#####`gr_cluster_servers`

Default is undef (array). Array of webbapp hosts. eg.: ['10.0.2.2:80', '10.0.2.3:80']

#####`gr_carbonlink_hosts`

Default is undef (array). Array of carbonlink hosts. eg.: ['10.0.2.2:80', '10.0.2.3:80']

#####`gr_cluster_fetch_timeout`

Default is 6. Timeout to fetch series data.

#####`gr_cluster_find_timeout`

Default is 2.5 . Timeout for metric find requests.   

#####`gr_cluster_retry_delay`

Default is 10.  Time before retrying a failed remote webapp.

#####`gr_cluster_cache_duration`

Default is 300. Time to cache remote metric find results.

#####`nginx_htpasswd`

Default is undef (string). The user and salted SHA-1 (SSHA) password for Nginx authentication. If set, Nginx will be configured to use HTTP Basic authentication with the given user & password. e.g.: 'testuser:$jsfak3.c3Fd0i1k2kel/3sdf3'

#####`nginx_proxy_read_timeout`

Default is 10. Value to use for nginx's proxy_read_timeout setting

#####`manage_ca_certificate`

Default is true (boolean). Used to determine if the module should install ca-certificate on Debian machines during the initial installation.

#####`gr_use_ldap`

Default is false (boolean). Turn ldap authentication on/off.

#####`gr_ldap_uri`

Default is '' (string). Set ldap uri.

#####`gr_ldap_search_base`

Default is '' (string). Set the ldap search base.

#####`gr_ldap_base_user`

Default is '' (string).Set ldap base user.

#####`gr_ldap_base_pass`

Default is '' (string). Set ldap password.

#####`gr_ldap_user_query`

Default is '(username=%s)' (string). Set ldap user query.

#####`gr_ldap_options`

Hash of additional LDAP options to be enabled. For example, `{ 'ldap.OPT_X_TLS_REQUIRE_CERT' => 'ldap.OPT_X_TLS_ALLOW' }`. Default is `{ }`.

#####`gr_use_remote_user_auth`

Default is 'False' (string). Allow use of REMOTE_USER env variable within Django/Graphite.

#####`gr_remote_user_header_name`

Default is undef. Allows the use of a custom HTTP header, instead of the REMOTE_USER env variable (mainly for nginx use) to tell Graphite a user is authenticated. Useful when using an external auth handler with X-Accel-Redirect etc.
Example value - HTTP_X_REMOTE_USER
The specific use case for this is OpenID right now, but could be expanded to anything.
One example is something like http://antoineroygobeil.com/blog/2014/2/6/nginx-ruby-auth/
combined with the option `gr_web_server` = 'wsgionly' and http://forge.puppetlabs.com/jfryman/nginx
with some custom vhosts.
The sample external auth app is available from [here](https://github.com/antoinerg/nginx_auth_backend)

#####`gunicorn_arg_timeout`

Default is 30.  value to pass to gunicorns --timeout arg.

#####`gunicorn_bind`

Default is 'unix:/var/run/graphite.sock'.  value to pass to gunicorns --bind arg.

#####`gunicorn_workers`
  
Default is 2. value to pass to gunicorn's --worker arg.

#####`gr_cache_instances`    

Default is empty array. Allow multiple additional cache instances. (beside the default one)
Example value:
```
{
    'cache:b' => {
        'LINE_RECEIVER_PORT' => 2103,
        'PICKLE_RECEIVER_PORT' => 2104,
        'CACHE_QUERY_PORT' => 7102,
    },
    'cache:c' => {
        'LINE_RECEIVER_PORT' => 2203,
        'PICKLE_RECEIVER_PORT' => 2204,
        'CACHE_QUERY_PORT' => 7202,
    }
}
```
#####`gr_relay_instances`

Default is empty array. Allow multiple additional relay instances. (beside the default one)

Example: see gr_cache_instances

#####`gr_aggregator_instances`

Default is empty array. Allow multiple additional aggregator instances. (beside the default one)

Example: see gr_cache_instances

#####`gr_whisper_autoflush`

Default is 'False'. Set autoflush for whisper

#####`gr_whisper_lock_writes`

Default is false. Set lock writes for whisper

#####`gr_whisper_fallocate_create`

Default is false. Set fallocate_create for whisper

#####`gr_log_cache_performance`

Default is 'False' (string). Logs timings for remote calls to carbon-cache

#####`gr_log_rendering_performance`

Default is 'False' (string). Triggers the creation of rendering.log which logs timings for calls to the The Render URL API

#####`gr_log_metric_access`

Default is 'False' (string). Trigges the creation of metricaccess.log which logs access to Whisper and RRD data files

#####`gr_django_tagging_pkg`

Default is 'django-tagging' (string) The name of the django-tagging package that should be installed

#####`gr_django_tagging_ver`

Default is '0.3.1' (string) The version of the django-tagging package that should be installed

#####`gr_twisted_pkg`

Default is 'Twisted' (string) The name of the twisted package that should be installed

#####`gr_twisted_ver`

Default is '11.1.0' (string) The version of the twisted package that should be installed

#####`gr_txamqp_pkg`

Default is 'txAMQP' (string) The name of the txamqp package that should be installed

#####`gr_txamqp_ver`

Default is '0.4' (string) The version of the txamqp package that should be installed

#####`gr_graphite_pkg`

Default is 'graphite-web' (string) The name of the graphite package that should be installed

#####`gr_graphite_ver`

Default is '0.9.12' (string) The version of the graphite package that should be installed

#####`gr_carbon_pkg`

Default is 'carbon' (string) The name of the carbon package that should be installed

#####`gr_carbon_ver`

Default is '0.9.12' (string) The version of the carbon package that should be installed

#####`gr_whisper_pkg`

Default is 'whisper' (string) The name of the whisper package that should be installed

#####`gr_whisper_ver`

Default is '0.9.12' (string) The version of the whisper package that should be installed

#####`gr_django_pkg`

Default is a platform-specific name of the django package that should be installed (string).

#####`gr_django_ver`

Default is 'installed' (string) The version of the django package that should be installed.

#####`gr_django_provider`

Default is `undef` (string) The provider of the django package that should be installed.

#####`gr_pip_install`

Default is true (Bool). Should packages be installed via pip

#####`gr_disable_webapp_cache`

Default is false (Bool). Should the caching of the webapp be disabled. This helps with some
display issues in grafana.

##Requirements

###Modules needed:

stdlib by puppetlabs

###Software versions needed:

facter > 1.6.2
puppet > 2.6.2

On Redhat distributions you need the EPEL or RPMforge repository, because Graphite needs packages, which are not part of the default repos.

##Limitations

This module is tested on CentOS 6.5 and Debian 7 (Wheezy) and should also run without problems on

* RHEL/CentOS/Scientific 6+
* Debian 6+
* Ubunutu 10.04 and newer

Most settings of Graphite can be set by parameters. So their can be special configurations for you. In this case you should edit
the file `templates/opt/graphite/webapp/graphite/local_settings.py.erb`.

The nginx configs are only supported on Debian based systems at the moment.

##Contributing

Echocat modules are open projects. So if you want to make this module even better, you can contribute to this module on [Github](https://github.com/echocat/puppet-graphite).
