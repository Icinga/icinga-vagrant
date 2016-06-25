# puppet-logstash

A Puppet module for managing and configuring [Logstash](http://logstash.net/).

[![Build Status](https://travis-ci.org/elastic/puppet-logstash.png?branch=master)](https://travis-ci.org/elastic/puppet-logstash)

## Versions

This overview shows you which Puppet module and Logstash version work together.

    ------------------------------------
    | Puppet module | Logstash         |
    ------------------------------------
    | 0.0.1 - 0.1.0 | 1.1.9            |
    ------------------------------------
    | 0.2.0         | 1.1.10           |
    ------------------------------------
    | 0.3.0 - 0.3.4 | 1.1.12 - 1.1.13  |
    ------------------------------------
    | 0.4.0 - 0.4.2 | 1.2.x - 1.3.x    |
    ------------------------------------
    | 0.5.0 - 0.5.1 | 1.4.1 - 1.4.2    |
    ------------------------------------
    | 0.6.x         | 1.5.0 - 2.x      |
    ------------------------------------

## Requirements

* Puppet 3.2.0 or better.
* The [stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) Puppet library.
* The [electrical/file_concat](https://forge.puppetlabs.com/electrical/file_concat) Puppet library.

Optional:
* The [apt](https://forge.puppetlabs.com/puppetlabs/apt) Puppet library when using repo management on Debian/Ubuntu.
* The [zypprepo](https://forge.puppetlabs.com/darin/zypprepo) Puppet library when using repo management on SLES/SuSE

## Quick Start

This minimum viable configuration ensures that the service is running and that it will be started at boot time.

``` puppet
class { 'logstash':
  manage_repo  => true,
  java_install => true,
}

# It is essential to provide a valid Logstash configuration file for the daemon to start.
logstash::configfile { 'my_ls_config':
  content => template('path/to/config.file'),
}
```

## Package and service options
### Choosing a Logstash minor version
``` puppet
class { 'logstash':
  manage_repo  => true,
  repo_version => '1.4',
}
```

### Using an explicit package source
Rather than use your distribution's repository system, you can specify an
explicit package to fetch and install.

#### From an HTTP/HTTPS/FTP URL
``` puppet
class { 'logstash':
  package_url => 'http://download.elasticsearch.org/logstash/logstash/packages/centos/logstash-1.3.3-1_centos.noarch.rpm',
}
```

#### From a 'puppet://' URL
``` puppet
class { 'logstash':
  package_url => 'puppet:///modules/my_module/logstash-1.3.3-1_centos.noarch.rpm',
}
```

#### From a local file on the agent
``` puppet
class { 'logstash':
  package_url => 'file:///tmp/logstash-1.3.3-1_centos.noarch.rpm',
}
```

### Allow automatic point-release upgrades
``` puppet
class { 'logstash':
  manage_repo  => true,
  repo_version => '1.5',
  autoupgrade  => true,
}
```

### Do not run as a daemon
``` puppet
class { 'logstash':
  status => 'disabled',
}
```

### Disable automatic restarts
Under normal circumstances a modification to the Logstash configuration will trigger a restart of the service. This behaviour can be disabled:
``` puppet
class { 'logstash':
  restart_on_change => false,
}
```

### Disable and remove Logstash
``` puppet
class { 'logstash':
  ensure => 'absent',
}
```

## Logstash config files
The Logstash configuration can be supplied as a single static file or dynamically built from multiple smaller files.

The basic usage is identical in either case: simply declare a `file` attribute as you would the [`content`](http://docs.puppetlabs.com/references/latest/type.html#file-attribute-content) attribute of the `file` type, meaning either direct content, template or a file resource:

``` puppet
logstash::configfile { 'configname':
  content => template('path/to/config.file'),
}
```
or
``` puppet
logstash::configfile { 'configname':
  source => 'puppet:///path/to/config.file',
}
```

If you want to use hiera to specify your configs, include the following create_resources call in your node manifest or in manifests/site.pp:

``` puppet
$logstash_configs = hiera('logstash_configs', {})
create_resources('logstash::configfile', $logstash_configs)
```
...and then include the following config within the corresponding hiera file:
``` puppet
"logstash_configs": {
  "config-name": {
    "template": "logstash/config.file.erb",
  }
}
```
Please note you'll have to create your logstash.conf.erb file and place it in the logstash module templates directory prior to using this method


To dynamically build a configuration, simply declare the `order` in which each section should appear - the lower the number the earlier it will appear in the resulting file (this should be a [familiar idiom](https://en.wikipedia.org/wiki/BASIC) for most).
``` puppet
logstash::configfile { 'input_redis':
  template => 'logstash/input_redis.erb',
  order    => 10,
}

logstash::configfile { 'filter_apache':
  source => 'puppet:///path/to/filter_apache',
  order  => 20,
}

logstash::configfile { 'output_es':
  template => 'logstash/output_es_cluster.erb',
  order   => 30,
}
```

### Inline Logstash config
For simple cases, it's possible to provide your Logstash config as an
inline string:

``` puppet
logstash::configfile { 'basic_ls_config':
  content => 'input { tcp { port => 2000 } } output { null {} }',
}
```

## Patterns
Many plugins (notably [Grok](http://logstash.net/docs/latest/filters/grok)) use *patterns*. While many are [included](https://github.com/logstash/logstash/tree/master/patterns) in Logstash already, additional site-specific patterns can be managed as well; where possible, you are encouraged to contribute new patterns back to the community.

**N.B.** As of Logstash 1.2 the path to the additional patterns needs to be configured explicitly in the Grok configuration.

``` puppet
logstash::patternfile { 'extra_patterns':
  source => 'puppet:///path/to/extra_pattern',
}
```

By default the resulting filename of the pattern will match that of the source. This can be over-ridden:
``` puppet
logstash::patternfile { 'extra_patterns_firewall':
  source   => 'puppet:///path/to/extra_patterns_firewall_v1',
  filename => 'extra_patterns_firewall',
}
```

**IMPORTANT NOTE**: Using logstash::patternfile places new patterns in the correct directory, however, it does NOT cause the path to be included automatically for filters (example: grok filter). You will still need to include this path (by default, /etc/logstash/patterns/) explicitly in your configurations.

Example: If using 'grok' in one of your configurations, you must include the pattern path in each filter like this:

```
# Note: this example is Logstash configuration, not a Puppet resource.
# Logstash and Puppet look very similar!
grok {
  patterns_dir => "/etc/logstash/patterns/"
  ...
}
```

## Plugin management

### Installing by name (from RubyGems.org)
``` puppet
logstash::plugin { 'logstash-input-beats': }
```

### Installing from a local Gem
``` puppet
logstash::plugin { 'logstash-input-custom':
  source => '/tmp/logstash-input-custom-0.1.0.gem',
}
```

### Installing from a 'puppet://' URL
``` puppet
logstash::plugin { 'logstash-filter-custom':
  source => 'puppet:///modules/my_ls_module/logstash-filter-custom-0.1.0.gem',
}
```

## Java Install
Most sites will manage Java seperately; however, this module can attempt to install Java as well.
``` puppet
class { 'logstash':
  java_install => true,
}
```

### Specifying a particular Java package (version) to be installed:
``` puppet
class { 'logstash':
  java_install => true,
  java_package => 'packagename'
}
```

## Repository management
Many sites will manage repositories seperately; however, this module can manage the repository for you.

``` puppet
class { 'logstash':
  manage_repo  => true,
  repo_version => '1.4',
}
```

Note: When using this on Debian/Ubuntu you will need to add the [Puppetlabs/apt](http://forge.puppetlabs.com/puppetlabs/apt) module to your modules.
If no repo_version is provided, default is set by `logstash::params::repo_version`.

## Init Defaults
The *defaults* file (`/etc/default/logstash` or `/etc/sysconfig/logstash`) for the Logstash service can be populated as necessary. This can either be a static file resource or a simple key value-style  [hash](http://docs.puppetlabs.com/puppet/latest/reference/lang_datatypes.html#hashes) object, the latter being particularly well-suited to pulling out of a data source such as Hiera.

### File source
``` puppet
class { 'logstash':
  init_defaults_file => 'puppet:///path/to/defaults',
}
```

### Hash representation
```puppet
$config_hash = {
  'LS_USER'  => 'logstash',
  'LS_GROUP' => 'logstash',
}

class { 'logstash':
  init_defaults => $config_hash,
}
```

## Support
Need help? Join us in [#logstash](https://webchat.freenode.net?channels=%23logstash) on Freenode IRC or on the https://discuss.elastic.co/c/logstash discussion forum.
