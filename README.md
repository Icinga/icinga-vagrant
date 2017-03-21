# Icinga Vagrant Boxes

Icinga Vagrant boxes used for development, tests and demo cases.

* [Icinga 2 Standalone](README.md#icinga2x)
* [Icinga 2 Cluster](README.md#icinga2x-cluster)
* [Icinga 2 HA Cluster](README.md#icinga2x-ha-cluster)
* [Icinga 2 InfluxDB](README.md#icinga2x-influxdb)
* [Icinga 2 and Elastic](README.md#icinga2x-elastic)
* [Icinga 2 and Graylog](README.md#icinga2x-graylog)

## Screenshots

### Icinga Web 2

![Icinga Web 2 Dashboard](doc/screenshot/icinga2x/vagrant_icinga2_icingaweb2_dashboard.png)
![Icinga Web 2 Detail View with PNP](doc/screenshot/icinga2x/vagrant_icinga2_icingaweb2_detail_pnp.png)
![Icinga Web 2 Business Process](doc/screenshot/icinga2x/vagrant_icinga2_icingaweb2_businessprocess.png)
![Icinga Web 2 Director](doc/screenshot/icinga2x/vagrant_icinga2_icingaweb2_director.png)
![Icinga Web 2 Grafana](doc/screenshot/icinga2x/vagrant_icinga2_icingaweb2_grafana.png)

### Dashing

![Icinga 2 Dashing](doc/screenshot/icinga2x/vagrant_icinga2_dashing.png)

### Graphite

![Icinga 2 Grafana with Graphite](doc/screenshot/icinga2x/vagrant_icinga2_grafana.png)
![Icinga 2 Graphite Web](doc/screenshot/icinga2x/vagrant_icinga2_graphite.png)

### InfluxDB

![Icinga 2 Grafana with InfluxDB](doc/screenshot/icinga2x-influxdb/vagrant_icinga2_influxdb_grafana.png)


## Requirements

Each Vagrant box setup requires at least 2 Cores and 1 GB RAM.
The required resources are automatically configured during the
`vagrant up` run.

* [Vagrant](https://www.vagrantup.com) >= 1.6.5

Note: There's a [bug](https://github.com/mitchellh/vagrant/issues/8096)
in 1.8.5-1.9.1 preventing host only network interfaces
being configured properly. A workaround is in place but you're encouraged
to use the latest [1.9.2+](https://www.hashicorp.com/blog/vagrant-1-9-2-released/) release.

One of these virtualization providers:

* Virtualbox >= 4.2.16 from http://www.virtualbox.org
* Parallels Desktop Pro/Business >= 11 from http://www.parallels.com/products/desktop/

Example on Fedora:

```
dnf install vagrant
dnf install virtualbox
```

Example on Ubuntu:

```
apt-get install vagrant
apt-get install virtualbox
```

### Windows

In addition the listed requirements you'll need:

* SSH provided by the Git package from http://msysgit.github.io
* Ruby for Windows from http://rubyinstaller.org (add Ruby executables to PATH)

Install the Git package and set `autocrlf` to `false` (either in the setup
dialog or using the cmd shell):

    git config --global core.autocrlf false

Then clone this repository:

    git clone https://github.com/Icinga/icinga-vagrant

### Virtualbox Provider

If Virtualbox is installed, this will be enabled by default.

### Parallels Provider

You'll need to install the [vagrant-parallels](http://parallels.github.io/vagrant-parallels/docs/)
plugin first:

    $ vagrant plugin install vagrant-parallels

### Behind a proxy

If you are working behind a proxy, you can use the [proxyconf plugin](https://github.com/tmatilai/vagrant-proxyconf).

Install the plugin:

    $ vagrant plugin install vagrant-proxyconf

Export the proxy variables into your environment:

    $ export VAGRANT_HTTP_PROXY=http://proxy:8080
    $ export VAGRANT_HTTPS_PROXY=http://proxy:8080

Vagrant exports the proxy settings into the VM and provisioning
will then work.

## Support

Please note that these boxes are built for development and tests only. Productive
setups are not supported.

In case you've found a problem or want to submit a patch, please open an issue
on GitHub and/or create a PR.

## Before you start

Change the directory to the box you want to start.

Example icinga2x:

    $ cd icinga2x

You can only do `vagrant up` in a box directory. Verify that
by checking for the existance of the `Vagrantfile` file in the current
directory.

    $ pwd
    /home/michi/coding/icinga/icinga-vagrant/icinga2x
    $ ls -la Vagrantfile
    -rw-------. 1 michi michi 1,4K 28. Aug 12:11 Vagrantfile

### Vagrant Commands

* `vagrant up` starts all vms for this box setup
* `vagrant halt` stops all vms for this box setup
* `vagrant provision` updates packages/resets configuration for all vms
* `vagrant ssh` puts you into an ssh shell with login `vagrant` (**Tip**: Use `sudo -i` to become `root`)

> **Note**
>
> Multi-VM boxes require the hostname for `vagrant ssh` like so: `vagrant ssh icinga2b`.
> That works in a similar fashion for other sub commands.

If your box is broken, you can destroy it using `vagrant destroy`. Next `vagrant up`
run will use the already imported base box, re-running the provisioner to install
the packages and configuration.

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
Grafana			| http://docs.grafana.org
Elastic			| https://www.elastic.co/guide/
Graylog			| http://docs.graylog.org

#### Vagrant update

On local config change (git pull for this repository).

    $ pwd
    $ git pull
    $ git log
    $ vagrant provision


# Box Overview

## <a id="icinga2x"></a>Icinga 2 Standalone

* 1 VM
* Icinga 2 Core
  * Icinga 2 API
* Icinga Web 2
 * Icinga [Director](https://github.com/Icinga/icingaweb2-module-director)
 * [PNP](https://github.com/Icinga/icingaweb2-module-pnp) module
 * [Graphite](https://github.com/Icinga/icingaweb2-module-graphite) module
 * [Business Process](https://github.com/Icinga/icingaweb2-module-businessprocess) module
 * [Generic TTS](https://github.com/Icinga/icingaweb2-module-generictts) module
 * [NagVis](https://github.com/Icinga/icingaweb2-module-nagvis) module
* PNP4Nagios
* NagVis
* Graphite
* Grafana
* [Dashing](https://github.com/Icinga/dashing-icinga2)

Run Vagrant:

    $ cd icinga2x && vagrant up

### User Interfaces

  GUI               | Url                               | Credentials
  ------------------|-----------------------------------|----------------
  Icinga Web 2      | http://192.168.33.5/icingaweb2    | icingaadmin/icinga
  PNP4Nagios        | http://192.168.33.5/pnp4nagios    | -
  Graphite Web	    | http://192.168.33.5:8003          | -
  Grafana           | http://192.168.33.5:8004          | admin/admin
  Dashing           | http://192.168.33.5:8005          | -

Note: In case Dashing is not running, restart it manually:

    $ vagrant ssh -c "sudo /usr/local/bin/restart-dashing"

### Icinga 2 API

Access [https://192.168.33.5:5665/v1/objects/hosts](https://192.168.33.5:5665/v1/objects/hosts)
using the credentials `root/icinga`. More details in the [documentation](http://docs.icinga.com/icinga2/snapshot/doc/module/icinga2/chapter/icinga2-api#icinga2-api).

## <a id="icinga2x-cluster"></a>Icinga 2 Cluster

* 2 VMs as Icinga 2 Master/Checker Cluster
* Icinga 2 Core, DB IDO MySQL, Icinga Web 2

Run Vagrant:

    $ cd icinga2x-cluster && vagrant up


### User Interfaces

  GUI               | Url                                   | Credentials
  ------------------|---------------------------------------|----------------
  Icinga Web 2      | http://192.168.33.10/icingaweb2       | icingaadmin/icinga
  Icinga Web 2      | http://192.168.33.20/icingaweb2       | icingaadmin/icinga

### Icinga 2 API

Access [https://192.168.33.10:5665/v1/objects/hosts](https://192.168.33.10:5665/v1/objects/hosts)
and [https://192.168.33.20:5665/v1/objects/hosts](https://192.168.33.20:5665/v1/objects/hosts)
using the credentials `root/icinga`.

## <a id="icinga2x-ha-cluster"></a>Icinga 2 HA Cluster

* 2 Master VMs, 1 Satellite VM
* Icinga 2 Core, DB IDO MYSQL, Icinga Web 2

Run Vagrant:

    $ cd icinga2x-ha-cluster && vagrant up

### User Interfaces

Note: DB IDO HA is disabled.

  GUI               | Url                                   | Credentials
  ------------------|---------------------------------------|----------------
  Icinga Web 2      | http://192.168.33.101/icingaweb2       | icingaadmin/icinga
  Icinga Web 2      | http://192.168.33.102/icingaweb2       | icingaadmin/icinga
  Icinga Web 2      | http://192.168.33.103/icingaweb2       | icingaadmin/icinga

## <a id="icinga2x-influxdb"></a>Icinga 2 InfluxDB

* 1 VM
* Icinga 2 Core
  * Icinga 2 API
* Icinga Web 2
* InfluxDB
* Grafana

Run Vagrant:

    $ cd icinga2x-influxdb && vagrant up

### User Interfaces

  GUI               | Url                               | Credentials
  ------------------|-----------------------------------|----------------
  Icinga Web 2      | http://192.168.33.8/icingaweb2    | icingaadmin/icinga
  Grafana           | http://192.168.33.8:8004          | admin/admin

### Icinga 2 API

Access [https://192.168.33.8:5665/v1/objects/hosts](https://192.168.33.8:5665/v1/objects/hosts)
using the credentials `root/icinga`. More details in the [documentation](http://docs.icinga.com/icinga2/snapshot/doc/module/icinga2/chapter/icinga2-api#icinga2-api).

## <a id="icinga2x-elastic"></a>Icinga 2 and Elastic Stack

* Elastic Stack: Elasticsearch, Logstash, Kibana, Beats
* Icinga 2, Icinga Web 2

Run Vagrant:

    $ cd icinga2x-elastic && vagrant up

Note: This is a TODO and work in progress.

### User Interfaces

  GUI               | Url                               | Credentials
  ------------------|-----------------------------------|----------------
  Icinga Web 2      | http://192.168.33.7/icingaweb2    | icingaadmin/icinga
  Kibana            | http://192.168.33.7:5601          | -

## <a id="icinga2x-graylog"></a>Icinga 2 and Graylog

* Graylog Server and Web with Elasticsearch, MongoDB
* Icinga 2, Icinga Web 2

Run Vagrant:

    $ cd icinga2x-graylog && vagrant up

### User Interfaces

  GUI              | Url                             | Credentials
  -----------------|---------------------------------|------------------------
  Icinga Web 2     | http://192.168.33.6/icingaweb2  | icingaadmin/icinga
  Graylog          | http://192.168.33.6:9000        | admin/admin

## Misc

### Puppet Module Overview

These boxes use these imported puppet modules for provisioning:

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
  puppet-kibana4        | modules/kibana4               | https://github.com/lesaux/puppet-kibana4.git
  puppet-kibana5	| modules/kibana5		| https://github.com/Nextdoor/puppet-kibana5
  puppet-filebeat       | modules/filebeat		| https://github.com/pcfens/puppet-filebeat.git
  puppetlabs-mongodb	| modules/mongodb		| https://github.com/puppetlabs/puppetlabs-mongodb.git
  golja-influxdb        | modules/influxdb              | https://github.com/n1tr0g/golja-influxdb.git including a [PR for 1.0.0 support](https://github.com/n1tr0g/golja-influxdb/pull/47)
  puppet-graphite	| modules/graphite		| Patched for systemd usage from https://github.com/echocat/puppet-graphite.git
  puppet-grafana	| modules/grafana		| https://github.com/bfraser/puppet-grafana.git

#### Puppet Module Setup

**Notes for developers only.**

Add subtree:

    $ git subtree add --prefix modules/vim https://github.com/saz/puppet-vim master --squash

Update subtree:

    $ git subtree pull --prefix modules/postgresql https://github.com/puppetlabs/puppetlabs-postgresql.git master --squash
