# elastic/logstash

A Puppet module for managing and configuring [Logstash](http://logstash.net/).

[![Build Status](https://travis-ci.org/elastic/puppet-logstash.png?branch=master)](https://travis-ci.org/elastic/puppet-logstash)

## Logstash Versions

This module, "elastic/logstash" supports only Logstash 5.x. For earlier
Logstash versions, support is provided by the legacy module,
"elasticsearch/logstash".

## Requirements

* Puppet 3.8.6 or better.
* The [stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) Puppet library.

Optional:
* The [apt](https://forge.puppetlabs.com/puppetlabs/apt) (>= 2.0.0) Puppet
  library when using repo management on Debian/Ubuntu.
* The [zypprepo](https://forge.puppetlabs.com/darin/zypprepo) Puppet library
  when using repo management on SLES/SuSE

## Quick Start

This minimum viable configuration ensures that Logstash is installed, enabled, and running:

``` puppet
include logstash

# You must provide a valid pipeline configuration for the service to start.
logstash::configfile { 'my_ls_config':
  content => template('path/to/config.file'),
}
```

## Package and service options
### Choosing a Logstash minor version
``` puppet
class { 'logstash':
  version => '5.0.2',
}
```

### Manual repository management
You may want to manage repositories manually. You can disable
automatic repository management like this:

``` puppet
class { 'logstash':
  manage_repo => false,
}
```

### Using an explicit package source
Rather than use your distribution's repository system, you can specify an
explicit package to fetch and install.

#### From an HTTP/HTTPS/FTP URL
``` puppet
class { 'logstash':
  package_url => 'https://artifacts.elastic.co/downloads/logstash/logstash-5.1.1.rpm',
}
```

#### From a 'puppet://' URL
``` puppet
class { 'logstash':
  package_url => 'puppet:///modules/my_module/logstash-5.1.1.rpm',
}
```

#### From a local file on the agent
``` puppet
class { 'logstash':
  package_url => 'file:///tmp/logstash-5.1.1.rpm',
}
```

### Allow automatic point-release upgrades
``` puppet
class { 'logstash':
  auto_upgrade => true,
}
```

### Do not run as a service
``` puppet
class { 'logstash':
  status => 'disabled',
}
```

### Disable automatic restarts
Under normal circumstances, changing a configuration will trigger a restart of
the service. This behaviour can be disabled:
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

### Settings

Logstash uses several files to define settings for the service and associated
Java runtime. The settings files can be configured with class parameters.

#### `logstash.yml`
``` puppet
class { 'logstash':
  settings => {
    'pipeline.batch.size'  => 25,
    'pipeline.batch.delay' => 5,
  },
}
```

#### `jvm.options`
``` puppet
class { 'logstash':
  jvm_options => [
    '-Xms1g',
    '-Xmx1g',
  ]
}
```

#### `startup.options`

``` puppet
class { 'logstash':
  startup_options => {
    'LS_NICE' => '10',
  }
}
```

### Pipeline Configuration
Pipeline configuration files can be declared with the `logstash::configfile`
type.

``` puppet
logstash::configfile { 'inputs':
  content => template('path/to/input.conf.erb'),
}
```
or
``` puppet
logstash::configfile { 'filters':
  source => 'puppet:///path/to/filter.conf',
}
```

For simple cases, it's possible to provide your Logstash config as an
inline string:

``` puppet
logstash::configfile { 'basic_ls_config':
  content => 'input { heartbeat {} } output { null {} }',
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

### Patterns
Many plugins (notably [Grok](http://logstash.net/docs/latest/filters/grok)) use *patterns*. While many are included in Logstash already, additional site-specific patterns can be managed as well.

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

## Support
Need help? Join us in [#logstash](https://webchat.freenode.net?channels=%23logstash) on Freenode IRC or on the https://discuss.elastic.co/c/logstash discussion forum.
