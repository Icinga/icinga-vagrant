# puppet-prometheus

[![Build Status](https://travis-ci.org/voxpupuli/puppet-prometheus.svg?branch=master)](https://travis-ci.org/voxpupuli/puppet-prometheus)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/prometheus.svg)](https://forge.puppetlabs.com/puppet/prometheus)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/prometheus.svg)](https://forge.puppetlabs.com/puppet/prometheus)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/prometheus.svg)](https://forge.puppetlabs.com/puppet/prometheus)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/prometheus.svg)](https://forge.puppetlabs.com/puppet/prometheus)
[![Apache-2 License](https://img.shields.io/github/license/voxpupuli/puppet-prometheus.svg)](LICENSE)

## Table of Contents

* [Compatibility](#compatibility)
* [Background](#background)
* [Usage](#usage)
* [Example](#example)
* [Known Issues](#known-issues)
* [Development](#development)
* [Authors](#authors)

----

## Compatibility

| Prometheus Version  | Recommended Puppet Module Version   |
| ----------------    | ----------------------------------- |
| >= 0.16.2           | latest                              |

node_exporter >= 0.15.0
consul_exporter >= 0.3.0

This module supports below Prometheus architectures:
- x86_64/amd64
- i386
- armv71 (Tested on raspberry pi 3)

## Background

This module automates the install and configuration of Prometheus monitoring tool: [Prometheus web site](https://prometheus.io/docs/introduction/overview/)

### What This Module Affects

* Installs the prometheus daemon, alertmanager or exporters(via url or package)
  * The package method was implemented, but currently there isn't any package for prometheus
* Optionally installs a user to run it under (per exporter)
* Installs a configuration file for prometheus daemon (/etc/prometheus/prometheus.yaml) or for alertmanager (/etc/prometheus/alert.rules)
* Manages the services via upstart, sysv, or systemd
* Optionally creates alert rules
* The following exporters are currently implemented: node_exporter, statsd_exporter, process_exporter, haproxy_exporter, mysqld_exporter, blackbox_exporter, consul_exporter, redis_exporter, varnish_exporter, graphite_exporter, postgres_exporter, collectd_exporter

## Usage

**Notice about breaking changes**

Version 5.0.0 and older of this module allowed you to deploy the prometheus server by doing a simple `include prometheus`.
We introduced a [new class layout](https://github.com/voxpupuli/puppet-prometheus/pull/194) in
version 6. By default, including the `prometheus` class won't deploy the server now.
You need to include the `prometheus::server` class for this (which has the same
parameters that `prometheus` had). An alternative approach is to set the
`manage_prometheus_server` parameter to true in the `prometheus` class. Background information about this change is described in the related [pull request](https://github.com/voxpupuli/puppet-prometheus/pull/187) and the [issue](https://github.com/voxpupuli/puppet-prometheus/issues/184).

For more information regarding class parameters please take a look at the class docstrings.

### Prometheus Server (versions < 1.0.0)

```puppet
class { 'prometheus::server':
  global_config  => {
    'scrape_interval'     => '15s',
    'evaluation_interval' => '15s',
    'external_labels'     => {'monitor' => 'master'},
  },
  rule_files     => ['/etc/prometheus/alert.rules'],
  scrape_configs => [
    {
      'job_name'        => 'prometheus',
      'scrape_interval' => '10s',
      'scrape_timeout'  => '10s',
      'target_groups'   => [
        {
          'targets' => ['localhost:9090'],
          'labels'  => {'alias' => 'Prometheus'}
        },
      ],
    },
  ],
}
```

### Prometheus Server (versions >= 1.0.0 < 2.0.0)

```puppet
class { 'prometheus::server':
  version        => '1.0.0',
  scrape_configs => [
    {
      'job_name'        => 'prometheus',
      'scrape_interval' => '30s',
      'scrape_timeout'  => '30s',
      'static_configs'  => [
        {
          'targets' => ['localhost:9090'],
          'labels'  => {
            'alias' => 'Prometheus',
          },
        },
      ],
    },
  ],
  alerts         => [
    {
      'name'         => 'InstanceDown',
      'condition'    => 'up == 0',
      'timeduration' => '5m',
      'labels'       => [
        {
          'name'    => 'severity',
          'content' => 'page',
        },
      ],
      'annotations'  => [
        {
          'name'    => 'summary',
          'content' => 'Instance {{ $labels.instance }} down',
        },
        {
          'name'    => 'description',
          'content' => '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.',
        },
      ],
    },
  ],
  extra_options  => '-alertmanager.url http://localhost:9093 -web.console.templates=/opt/prometheus-1.0.0.linux-amd64/consoles -web.console.libraries=/opt/prometheus-1.0.0.linux-amd64/console_libraries',
  localstorage   => '/prometheus/prometheus',
}
```

### Prometheus Server (versions >= 2.0.0)

```puppet
class { 'prometheus::server':
  version        => '2.4.3',
  alerts         => {
    'groups' => [
      {
        'name'  => 'alert.rules',
        'rules' => [
          {
            'alert'       => 'InstanceDown',
            'expr'        => 'up == 0',
            'for'         => '5m',
            'labels'      => {
              'severity' => 'page',
            },
            'annotations' => {
              'summary'     => 'Instance {{ $labels.instance }} down',
              'description' => '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.'
            }
          },
        ],
      },
    ],
  },
  scrape_configs => [
    {
      'job_name'        => 'prometheus',
      'scrape_interval' => '10s',
      'scrape_timeout'  => '10s',
      'static_configs'  => [
        {
          'targets' => [ 'localhost:9090' ],
          'labels'  => {
            'alias' => 'Prometheus',
          }
        }
      ],
    },
  ],
}
```

When using prometheus >= 2.0, use [the new yaml format](https://prometheus.io/docs/prometheus/2.0/migration/#recording-rules-and-alerts) for rules and alerts.

Which in Puppet means the alerts looks like this:

```puppet
alerts => {
  'groups' => [
    {
      'name' => 'alert.rules',
      'rules' => [
        {
          'alert'  => 'InstanceDown',
          'expr'   => 'up == 0',
          'for'    => '5m',
          'labels' => {
            'severity' => 'page',
          },
          'annotations' => {
            'summary'     => 'Instance {{ $labels.instance }} down',
            'description' => '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.',
          }
        }
      ],
    },
  ],
},
```

And that results in this YAML configuration.

```yaml
---
alerts:
  groups:
    - name: 'alert.rules'
      rules:
        - alert: 'InstanceDown'
          expr: 'up == 0'
          for: '5m'
          labels:
            severity: 'page'
          annotations:
            summary: 'Instance {{ $labels.instance }} down'
            description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.'
```

### Monitored Nodes

```puppet
include prometheus::node_exporter
```

or:

```puppet
class { 'prometheus::node_exporter':
  version            => '0.12.0',
  collectors_disable => ['loadavg', 'mdadm'],
  extra_options      => '--collector.ntp.server ntp1.orange.intra',
}
```


## Example

Real Prometheus >=2.0.0 setup example including alertmanager and slack_configs.

```puppet
class { 'prometheus':
  manage_prometheus_server => true,
  version                  => '2.0.0',
  alerts                   => {
    'groups' => [
      {
        'name'  => 'alert.rules',
        'rules' => [
          {
            'alert'       => 'InstanceDown',
            'expr'        => 'up == 0',
            'for'         => '5m',
            'labels'      => {'severity' => 'page'},
            'annotations' => {
              'summary'     => 'Instance {{ $labels.instance }} down',
              'description' => '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.'
            },
          },
        ],
      },
    ],
  },
  scrape_configs           => [
    {
      'job_name'        => 'prometheus',
      'scrape_interval' => '10s',
      'scrape_timeout'  => '10s',
      'static_configs'  => [
        {
          'targets' => ['localhost:9090'],
          'labels'  => {'alias' => 'Prometheus'}
        }
      ],
    },
    {
      'job_name'        => 'node',
      'scrape_interval' => '5s',
      'scrape_timeout'  => '5s',
      'static_configs'  => [
        {
          'targets' => ['nodexporter.domain.com:9100'],
          'labels'  => {'alias' => 'Node'}
        },
      ],
    },
  ],
  alertmanagers_config     => [
    {
      'static_configs' => [{'targets' => ['localhost:9093']}],
    },
  ],
}

class { 'prometheus::alertmanager':
  version   => '0.13.0',
  route     => {
    'group_by'        => ['alertname', 'cluster', 'service'],
    'group_wait'      => '30s',
    'group_interval'  => '5m',
    'repeat_interval' => '3h',
    'receiver'        => 'slack',
  },
  receivers => [
    {
      'name'          => 'slack',
      'slack_configs' => [
        {
          'api_url'       => 'https://hooks.slack.com/services/ABCDEFG123456',
          'channel'       => '#channel',
          'send_resolved' => true,
          'username'      => 'username'
        },
      ],
    },
  ],
}
```

And if you want to use Hiera to declare the values instead, you can simply include the `prometheus` class and set your Hiera data as shown below:

**Puppet Code**
```puppet
include prometheus
```

**Hiera Data (in yaml)**
```yaml
---
prometheus::manage_prometheus_server: true

prometheus::version: '2.0.0'

prometheus::alerts:
  groups:
    - name: 'alert.rules'
      rules:
        - alert: 'InstanceDown'
          expr: 'up == 0'
          for: '5m'
          labels:
            severity: 'page'
          annotations:
            summary: 'Instance {{ $labels.instance }} down'
            description: '{{ $labels.instance }} of job {{ $labels.job }} has been
              down for more than 5 minutes.'

prometheus::scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: '10s'
    scrape_timeout: '10s'
    static_configs:
      - targets:
          - 'localhost:9090'
        labels:
          alias: 'Prometheus'
  - job_name: 'node'
    scrape_interval: '10s'
    scrape_timeout: '10s'
    static_configs:
      - targets:
          - 'nodexporter.domain.com:9100'
        labels:
          alias: 'Node'

prometheus::alertmanagers_config:
  - static_configs:
      - targets:
          - 'localhost:9093'

prometheus::alertmanager::version: '0.13.0'

prometheus::alertmanager::route:
  group_by:
    - 'alertname'
    - 'cluster'
    - 'service'
  group_wait: '30s'
  group_interval: '5m'
  repeat_interval: '3h'
  receiver: 'slack'

prometheus::alertmanager::receivers:
  - name: 'slack'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/ABCDEFG123456'
        channel: "#channel"
        send_resolved: true
        username: 'username'
```

Test your commit with vagrant https://github.com/kalinux/vagrant-puppet-prometheus.git

## Known issues

In version 0.1.14 of this module the alertmanager was configured to run as the service `alert_manager`. This has been changed in version 0.2.00 to be `alertmanager`.

Do not use version 1.0.0 of Prometheus: https://groups.google.com/forum/#!topic/prometheus-developers/vuSIxxUDff8 ; it is not compatible with this module!

Even if the module has templates for several linux distributions, only RedHat family distributions were tested.

This module has unit tests for CentOS/RHEL, Debian, Ubuntu and Archlinux. Acceptance tests are executed for CentOS, Debian and Ubuntu. Other operating systems may work but are untested.


## Development

This project contains tests for [rspec-puppet](http://rspec-puppet.com/).

Quickstart to run all linter and unit tests:

```bash
bundle install --path .vendor/ --without system_tests --without development --without release
bundle exec rake test
```

## Authors

puppet-prometheus is maintained by [Vox Pupuli](https://voxpupuli.org), it was written by [brutus333](https://github.com/brutus333/).
