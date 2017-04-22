# Icinga Vagrant Boxes

#### Table of Contents

1. [About](#about)
2. [Support](#support)
3. [Requirements](#requirements)
4. [Providers](#providers)
5. [Run](#run)
6. [Boxes](#boxes)
7. [Misc](#misc)


## About

The Icinga Vagrant boxes allow you to run Icinga 2, Icinga Web 2 and integrations
(Graphite, InfluxDB, Grafana, Elastic Stack, Graylog) in various scenarios.

A simple `vagrant up` fully installs these VMs and you are ready to explore
the Icinga ecosystem. You can use these boxes for your own local demos, or
to learn how to install and configure Icinga.

* [Icinga 2 Standalone](README.md#icinga2x)
* [Icinga 2 Cluster](README.md#icinga2x-cluster)
* [Icinga 2 HA Cluster](README.md#icinga2x-ha-cluster)
* [Icinga 2 InfluxDB](README.md#icinga2x-influxdb)
* [Icinga 2 and Elastic](README.md#icinga2x-elastic)
* [Icinga 2 and Graylog](README.md#icinga2x-graylog)

### Icinga Web 2

![Icinga Web 2 Dashboard](doc/screenshot/icinga2x/vagrant_icinga2_icingaweb2_dashboard.png)
![Icinga Web 2 Detail View with PNP](doc/screenshot/icinga2x/vagrant_icinga2_icingaweb2_detail_pnp.png)
![Icinga Web 2 Business Process](doc/screenshot/icinga2x/vagrant_icinga2_icingaweb2_businessprocess.png)
![Icinga Web 2 Director](doc/screenshot/icinga2x/vagrant_icinga2_icingaweb2_director.png)

### Dashing

![Icinga 2 Dashing](doc/screenshot/icinga2x/vagrant_icinga2_dashing.png)

### Elastic & Icingabeat

![Icinga 2 Dashing](doc/screenshot/icinga2x-elastic/vagrant_icinga2_elastic_kibana_icingabeat.png)

### Grafana

![Icinga 2 Grafana with Graphite](doc/screenshot/icinga2x/vagrant_icinga2_grafana.png)

## Support

Please note that these boxes are built for demos and development tests only. Several
boxes will run snapshot builds and unstable code to test the latest and the greatest.

You can also use them to test Icinga packages prior to the next release.

In case you've found a problem or want to submit a patch, please open an issue
on GitHub and/or create a PR.


## Requirements

* [Vagrant](https://www.vagrantup.com) >= 1.8.x

One of these virtualization providers:

* [Virtualbox](https://www.virtualbox.org/) >= 5.x
* [Parallels Desktop Pro/Business](https://www.parallels.com/de/products/desktop/) >= 11
* [libvirt](https://libvirt.org/)

Each Vagrant box setup requires at least 2 Cores and 2 GB RAM.
The required resources are automatically configured during the
`vagrant up` run.

### Linux

#### VirtualBox

Example on Fedora (needs RPMFusion repository for VirtualBox):

```
dnf install vagrant
dnf install virtualbox
vagrant plugin install virtualbox
```

Fedora uses libvirt by default. More details on VirtualBox can be found [here](https://developer.fedoraproject.org/tools/vagrant/vagrant-virtualbox.html).

Example on Ubuntu:

```
apt-get install vagrant
apt-get install virtualbox
```

### Windows

In addition the listed requirements you'll need:

* [Git package](https://git-for-windows.github.io/) which also includes SSH
* [Ruby for Windows](https://rubyinstaller.org/) (add Ruby executables to PATH)

Install the Git package and set `autocrlf` to `false` (either in the setup
dialog or using the cmd shell):

```
git config --global core.autocrlf false
```

Then clone this repository:

```
git clone https://github.com/Icinga/icinga-vagrant
```

## Providers

Choose one of the providers below. VirtualBox can be used nearly everwhere. If
if you have a Parallels Pro license on macOS, or prefer to use libvirt, that's possible
too.

### Virtualbox Provider

If Virtualbox is installed, this will be enabled by default. The Vagrant boxes use the
official CentOS base boxes and require you to have the `vagrant-vbguest` plugin installed:

```
vagrant plugin install vagrant-vbguest
```

### Parallels Provider

You'll need to install the [vagrant-parallels](http://parallels.github.io/vagrant-parallels/docs/)
plugin first:

```
$ vagrant plugin install vagrant-parallels
```

The Parallels provider uses the [Parallels CentOS base box](https://github.com/Parallels/vagrant-parallels/wiki/Available-Vagrant-Boxes).

### Libvirt Provider

You should have `qemu` and `libvirt installed if you plan to run Vagrant
on your local system. Then install the `vagrant-libvirt` plugin:

```
$ vagrant plugin install vagrant-libvirt
```

The libvirt provider uses the official CentOS base boxes.


### Additional Plugins

#### Behind a proxy

If you are working behind a proxy, you can use the [proxyconf plugin](https://github.com/tmatilai/vagrant-proxyconf).

Install the plugin:

```
$ vagrant plugin install vagrant-proxyconf
```

Export the proxy variables into your environment:

```
$ export VAGRANT_HTTP_PROXY=http://proxy:8080
$ export VAGRANT_HTTPS_PROXY=http://proxy:8080
```

Vagrant exports the proxy settings into the VM and provisioning
will then work.

## Run

Change the directory to the box you want to start.

Example icinga2x:

```
$ cd icinga2x
```

You can only do `vagrant up` in a box directory. Verify that
by checking for the existance of the `Vagrantfile` file in the current
directory.

### Vagrant Commands

Start all VMs:

```
vagrant up
```

Depending on the provider you have chosen above, you might want to set
it explicitely:

```
$ vagrant up --provider=virtualbox
```

SSH into the box as local `vagrant` user (**Tip**: Use `sudo -i` to become `root`):

```
vagrant ssh
```

> **Note**
>
> Multi-VM boxes require the hostname for `vagrant ssh` like so: `vagrant ssh icinga2b`.
> That works in a similar fashion for other sub commands.

Stop all VMs:

```
vagrant halt
```

Update packages/reset configuration for all VMs:

```
vagrant provision
```

Destroy the VM (add `-f` to avoid the safety question)

```
vagrant destroy
```


### More Usability Hints

Documentation for software used inside these boxes.

Project			| URL
------------------------|------------------------------
Icinga 2		| https://docs.icinga.com
Icinga Web 2		| https://github.com/Icinga/icingaweb2/tree/master/doc
PNP			| https://docs.pnp4nagios.org
NagVis			| https://www.nagvis.org/doc
Graphite		| https://graphite.readthedocs.io
InfluxDB		| https://docs.influxdata.com/influxdb/
Grafana			| https://docs.grafana.org
Elastic			| https://www.elastic.co/guide/
Graylog			| http://docs.graylog.org

#### Vagrant update

On local config change (git pull for this repository).

```
$ pwd
$ git pull
$ git log
$ vagrant provision
```

## Boxes

### <a id="icinga2x"></a>Icinga 2 Standalone

* 1 VM
* [Icinga 2](https://www.icinga.com/products/icinga-2/)
* [Icinga Web 2](https://www.icinga.com/products/icinga-web-2/)
  * [Icinga Director](https://github.com/Icinga/icingaweb2-module-director), [PNP](https://github.com/Icinga/icingaweb2-module-pnp), [Business Process](https://github.com/Icinga/icingaweb2-module-businessprocess), [Generic TTS](https://github.com/Icinga/icingaweb2-module-generictts), [NagVis](https://github.com/Icinga/icingaweb2-module-nagvis) modules
* [PNP4Nagios](http://docs.pnp4nagios.org/)
* [NagVis](http://nagvis.org/)
* [Graphite](https://graphiteapp.org/)
* [Grafana](https://grafana.com/)
* [Dashing](https://github.com/Icinga/dashing-icinga2)

Run Vagrant:

```
$ cd icinga2x && vagrant up
```

#### Application Interfaces

  Application       | Url                               | Credentials
  ------------------|-----------------------------------|----------------
  Icinga Web 2      | http://192.168.33.5/icingaweb2    | icingaadmin/icinga
  Icinga 2 API      | https://192.168.33.5:5665/v1      | root/icinga
  PNP4Nagios        | http://192.168.33.5/pnp4nagios    | -
  Graphite Web	    | http://192.168.33.5:8003          | -
  Grafana           | http://192.168.33.5:8004          | admin/admin
  Dashing           | http://192.168.33.5:8005          | -

Note: In case Dashing is not running, restart it manually:

```
$ vagrant ssh -c "sudo systemctl start dashing-icinga2"
```


### <a id="icinga2x-cluster"></a>Icinga 2 Cluster

* 2 VMs as Icinga 2 Master/Checker Cluster
* [Icinga 2](https://www.icinga.com/products/icinga-2/)
* [Icinga Web 2](https://www.icinga.com/products/icinga-web-2/)

Run Vagrant:

```
$ cd icinga2x-cluster && vagrant up
```

#### Application Interfaces

  Application       | Url                                   | Credentials
  ------------------|---------------------------------------|----------------
  Icinga Web 2      | http://192.168.33.10/icingaweb2       | icingaadmin/icinga
  Icinga Web 2      | http://192.168.33.20/icingaweb2       | icingaadmin/icinga
  Icinga 2 API      | https://192.168.33.10:5665/v1         | root/icinga
  Icinga 2 API      | https://192.168.33.20:5665/v1         | root/icinga


### <a id="icinga2x-ha-cluster"></a>Icinga 2 HA Cluster

* 2 Master VMs, 1 Satellite VM
* [Icinga 2](https://www.icinga.com/products/icinga-2/)
* [Icinga Web 2](https://www.icinga.com/products/icinga-web-2/)

Run Vagrant:

```
$ cd icinga2x-ha-cluster && vagrant up
```

#### Application Interfaces

  Application       | Url                                   | Credentials
  ------------------|---------------------------------------|----------------
  Icinga Web 2      | http://192.168.33.101/icingaweb2      | icingaadmin/icinga
  Icinga Web 2      | http://192.168.33.102/icingaweb2      | icingaadmin/icinga
  Icinga Web 2      | http://192.168.33.103/icingaweb2      | icingaadmin/icinga
  Icinga 2 API      | https://192.168.33.101:5665/v1        | root/icinga
  Icinga 2 API      | https://192.168.33.102:5665/v1        | root/icinga
  Icinga 2 API      | https://192.168.33.103:5665/v1        | root/icinga


### <a id="icinga2x-influxdb"></a>Icinga 2 InfluxDB

* 1 VM
* [Icinga 2](https://www.icinga.com/products/icinga-2/)
* [Icinga Web 2](https://www.icinga.com/products/icinga-web-2/)
* [InfluxDB](https://docs.influxdata.com/influxdb/)
* [Grafana](https://grafana.com/)

Run Vagrant:

```
$ cd icinga2x-influxdb && vagrant up
```

#### Application Interfaces

  Application       | Url                               | Credentials
  ------------------|-----------------------------------|----------------
  Icinga Web 2      | http://192.168.33.8/icingaweb2    | icingaadmin/icinga
  Icinga 2 API      | https://192.168.33.8:5665/v1      | root/icinga
  Grafana           | http://192.168.33.8:8004          | admin/admin


### <a id="icinga2x-elastic"></a>Icinga 2 and Elastic Stack

* [Elastic Stack](https://www.elastic.co/products)
  * [Elasticsearch](https://www.elastic.co/products/elasticsearch)
  * [icingabeat](https://github.com/icinga/icingabeat), [filebeat](https://www.elastic.co/products/beats/filebeat)
  * [Kibana](https://www.elastic.co/products/kibana)
* [Icinga 2](https://www.icinga.com/products/icinga-2/)
* [Icinga Web 2](https://www.icinga.com/products/icinga-web-2/)

Run Vagrant:

```
$ cd icinga2x-elastic && vagrant up
```

Note: Logstash integration is missing (#31).

#### Application Interfaces

  Application       | Url                               | Credentials
  ------------------|-----------------------------------|----------------
  Icinga Web 2      | http://192.168.33.7/icingaweb2    | icingaadmin/icinga
  Icinga 2 API      | https://192.168.33.7:5665/v1      | root/icinga
  Kibana            | http://192.168.33.7:5601          | -

### <a id="icinga2x-graylog"></a>Icinga 2 and Graylog

* [Graylog](https://www.graylog.org)
* [Icinga 2](https://www.icinga.com/products/icinga-2/)
* [Icinga Web 2](https://www.icinga.com/products/icinga-web-2/)

Run Vagrant:

```
$ cd icinga2x-graylog && vagrant up
```

#### Application Interfaces

  Application       | Url                             | Credentials
  ------------------|---------------------------------|------------------------
  Icinga Web 2      | http://192.168.33.6/icingaweb2  | icingaadmin/icinga
  Icinga 2 API      | https://192.168.33.6:5665/v1    | root/icinga
  Graylog           | http://192.168.33.6:9000        | admin/admin



## Misc

### Puppet Module Overview

The Vagrant boxes use these imported puppet modules for provisioning. The modules are
pulled into this repository as git subtree.

General:

  Name     		| Path				| Url
  ----------------------|-------------------------------|-------------------------------
  puppetlabs-stdlib	| modules/stdlib		| https://github.com/puppetlabs/puppetlabs-stdlib.git
  puppetlabs-concat	| modules/concat		| https://github.com/puppetlabs/puppetlabs-concat.git
  puppetlabs-apache	| modules/apache		| https://github.com/puppetlabs/puppetlabs-apache.git
  puppetlabs-mysql	| modules/mysql			| https://github.com/puppetlabs/puppetlabs-mysql.git
  puppetlabs-postgresql	| modules/postgresql		| https://github.com/puppetlabs/puppetlabs-postgresql.git
  puppetlabs-vcsrepo	| modules/vcsrepo		| https://github.com/puppetlabs/puppetlabs-vcsrepo.git
  puppet-module-epel	| modules/epel			| https://github.com/stahnma/puppet-module-epel.git
  puppet-php		| modules/php			| https://github.com/thias/puppet-php.git
  puppet-selinux	| modules/selinux		| https://github.com/jfryman/puppet-selinux.git
  puppetlabs-java	| modules/java			| https://github.com/puppetlabs/puppetlabs-java.git
  puppet-yum		| modules/yum			| https://github.com/CERIT-SC/puppet-yum.git
  puppet-wget           | modules/wget                  | https://github.com/maestrodev/puppet-wget.git
  puppet-archive	| modules/archive		| https://github.com/voxpupuli/puppet-archive.git
  puppet-vim            | modules/vim                   | https://github.com/saz/puppet-vim.git
  puppet-lib-file\_contact | modules/file\_contact      | https://github.com/electrical/puppet-lib-file_concat.git
  puppet-sysctl		| modules/sysctl		| https://github.com/thias/puppet-sysctl.git
  puppet-datacat        | modules/datacat               | https://github.com/richardc/puppet-datacat.git

Specific projects:

  Name     		| Path				| Url
  ----------------------|-------------------------------|-------------------------------
  graylog2-puppet	| modules/graylog2		| https://github.com/Graylog2/graylog2-puppet.git
  puppet-elasticsearch	| modules/elasticsearch		| https://github.com/elasticsearch/puppet-elasticsearch.git
  puppet-logstash       | modules/logstash              | https://github.com/elastic/puppet-logstash.git
  puppet-kibana		| modules/kibana		| https://github.com/elastic/puppet-kibana.git
  puppet-kibana4        | modules/kibana4               | https://github.com/lesaux/puppet-kibana4.git
  puppet-kibana5	| modules/kibana5		| https://github.com/Nextdoor/puppet-kibana5
  puppet-filebeat       | modules/filebeat		| https://github.com/pcfens/puppet-filebeat.git
  puppetlabs-mongodb	| modules/mongodb		| https://github.com/puppetlabs/puppetlabs-mongodb.git
  golja-influxdb        | modules/influxdb              | https://github.com/n1tr0g/golja-influxdb.git including a [PR for 1.0.0 support](https://github.com/n1tr0g/golja-influxdb/pull/47)
  puppet-graphite	| modules/graphite		| Patched for systemd usage from https://github.com/echocat/puppet-graphite.git
  puppet-grafana	| modules/grafana		| https://github.com/bfraser/puppet-grafana.git


#### Puppet Module Git Subtree

**Notes for developers only.**

Add subtree:

    $ git subtree add --prefix modules/vim https://github.com/saz/puppet-vim master --squash

Update subtree:

    $ git subtree pull --prefix modules/postgresql https://github.com/puppetlabs/puppetlabs-postgresql.git master --squash
