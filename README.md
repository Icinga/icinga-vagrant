# Icinga Vagrant Boxes

#### Table of Contents

1. [About](#about)
2. [License](#license)
3. [Support](#support)
4. [Requirements](#requirements)
5. [Installation](#installation)
6. [Configuration](#configuration)
7. [FAQ](#faq)
8. [Thanks](#thanks)
9. [Contributing](#contributing)


# About <a id="about"></a>

The Icinga Vagrant boxes allow you to run Icinga 2, Icinga Web 2 and integrations
(Graphite, InfluxDB, Grafana, Elastic Stack, Graylog) in various scenarios.

A simple `vagrant up` fully installs these VMs and you are ready to explore
the Icinga ecosystem and possible integrations.

You can use these boxes for your own local demos, or to learn how to use Icinga
in your environment.

* [Icinga 2 Standalone](README.md#boxes-icinga2x), [Icinga 2 Cluster](README.md#boxes-icinga2x-cluster)
* [Icinga 2 and InfluxDB](README.md#boxes-icinga2x-influxdb)
* [Icinga 2 and Elastic](README.md#boxes-icinga2x-elastic)
* [Icinga 2 and Graylog](README.md#boxes-icinga2x-graylog)

## Icinga Web 2 <a id="about-icingaweb2"></a>

<img src="https://github.com/Icinga/icinga-vagrant/blob/master/doc/screenshot/icinga2x/vagrant_icinga2_icingaweb2_dashboard.png" alt="Icinga Web 2 Dashboard" height="300">
<img src="https://github.com/Icinga/icinga-vagrant/blob/master/doc/screenshot/icinga2x-influxdb/vagrant_icinga2_icingaweb2_grafana_module_influxdb.png" alt="Icinga Web 2 Detail View with Grafana" height="300">
<img src="https://github.com/Icinga/icinga-vagrant/blob/master/doc/screenshot/icinga2x/vagrant_icinga2_icingaweb2_maps.png" alt="Icinga Web 2 Maps" height="300">
<img src="https://github.com/Icinga/icinga-vagrant/blob/master/doc/screenshot/icinga2x/vagrant_icinga2_icingaweb2_businessprocess.png" alt="Icinga Web 2 Business Process" height="300">
<img src="https://github.com/Icinga/icinga-vagrant/blob/master/doc/screenshot/icinga2x/vagrant_icinga2_icingaweb2_director.png" alt="Icinga Web 2 Director" height="300">

## Dashing <a id="about-dashing"></a>

<img src="https://github.com/Icinga/icinga-vagrant/blob/master/doc/screenshot/icinga2x/vagrant_icinga2_dashing.png" alt="Dashing" height="300">

## Elastic & Icingabeat <a id="about-elastic"></a>

<img src="https://github.com/Icinga/icinga-vagrant/blob/master/doc/screenshot/icinga2x-elastic/vagrant_icinga2_elastic_kibana_icingabeat.png" alt="Elastic Stack and Icingabeat" height="300">

## Grafana <a id="about-grafana"></a>

<img src="https://github.com/Icinga/icinga-vagrant/blob/master/doc/screenshot/icinga2x/vagrant_icinga2_grafana.png" alt="Icinga 2 Grafana with Graphite" height="300">

# License <a id="license"></a>

Box specific code is licensed under the terms of the GNU General Public License Version 2, you will find a copy of this license in the LICENSE file included in the source package.

Included Puppet modules in the `modules` directory provide their own license details.

# Support <a id="support"></a>

These boxes are built for demos and development tests only. Team members and partners
may use these for their Icinga Camp presentations or any other event too.

Join the [Icinga community channels](https://www.icinga.com/about/get-involved/) for questions.

> **Note**
>
> Boxes can run snapshot builds and unstable code to test the latest and the greatest.
>
> You can also use them to test Icinga packages prior to the next release.

In case you've found a problem or want to submit a patch, please open an issue
on GitHub and/or create a PR.


# Requirements <a id="requirements"></a>

* [Vagrant](https://www.vagrantup.com) >= 1.8.x

One of these virtualization providers:

* [Virtualbox](https://www.virtualbox.org/) >= 5.x
* [Parallels Desktop Pro/Business](https://www.parallels.com/de/products/desktop/) >= 12
* [libvirt](https://libvirt.org/)

Each Vagrant box setup requires at least 2 Cores and 2 GB RAM.
The required resources are automatically configured during the
`vagrant up` run.

## Linux <a id="requirements-linux"></a>

### VirtualBox <a id="requirements-linux-virtualbox"></a>

Example on Fedora (needs RPMFusion repository for VirtualBox):

```
sudo dnf install vagrant
sudo dnf install virtualbox
vagrant plugin install virtualbox
```

Fedora uses libvirt by default. More details on VirtualBox can be found [here](https://developer.fedoraproject.org/tools/vagrant/vagrant-virtualbox.html).

Example on Ubuntu:

```
$ sudo apt-get install vagrant
$ sudo apt-get install virtualbox
```

## macOS <a id="requirements-macOS"></a>

macOS runs best with the Parallels provider, VirtualBox works as well.

## Windows <a id="requirements-windows"></a>

Windows requires VirtualBox as provider. You'll also need the [Git package](https://git-for-windows.github.io/) which includes SSH.

Install the Git package and set `autocrlf` to `false`.

<img src="https://github.com/Icinga/icinga-vagrant/blob/master/doc/images/basics/git_windows_clrf_false.png" alt="Windows Git CRLF" height="300">

You can also set the options on the command line afterwards:

```
C:\Users\michi> git.exe config --global core.autocrlf false
```

Set the Windows command line as default:

<img src="https://github.com/Icinga/icinga-vagrant/blob/master/doc/images/basics/git_windows_default_shell_cmd.png" alt="Windows Git Command Line" height="300">

> **Note**
>
> If `vagrant up` hangs with Vagrant 2.0.0 on Windows 7, you might need to upgrade your Powershell
> version. See [this note](https://github.com/hashicorp/vagrant/issues/8783#issuecomment-325411772) for details.

## Providers <a id="requirements-providers"></a>

Choose one of the providers below. VirtualBox can be used nearly everwhere. If
you have a Parallels Pro license on macOS, or prefer to use libvirt, that's possible
too.

### Virtualbox <a id="requirements-providers-virtualbox"></a>

If Virtualbox is installed, this will be enabled by default.

The Virtualbox provider uses the [bento](https://app.vagrantup.com/bento/) base box.

### Parallels <a id="requirements-providers-virtualbox"></a>

You'll need to install the [vagrant-parallels](http://parallels.github.io/vagrant-parallels/docs/)
plugin first:

```
$ vagrant plugin install vagrant-parallels
```

The Parallels provider uses the [bento](https://app.vagrantup.com/bento/) base box.

### Libvirt <a id="requirements-providers-libvirt"></a>

You should have `qemu` and `libvirt installed if you plan to run Vagrant
on your local system. Then install the `vagrant-libvirt` plugin:

```
$ vagrant plugin install vagrant-libvirt
```

The libvirt provider uses the official CentOS base boxes.


# Installation <a id="installation"></a>

## Linux <a id="installation-linux"></a>

```
$ git clone https://github.com/Icinga/icinga-vagrant && cd icinga-vagrant
```

Change into the directory of the scenario and start the box(es).

```
$ cd icinga2x
$ vagrant up
```

Proceed here for an overview about all available [boxes](#boxes).

## Windows <a id="installation-windows"></a>

Clone this repository:

```
C:\Users\michi\Documents> git.exe clone https://github.com/Icinga/icinga-vagrant
```

<img src="https://github.com/Icinga/icinga-vagrant/blob/master/doc/images/basics/vagrant_windows_icinga_git_clone.png" alt="Windows Git Clone" height="300">

Change into the directory of the scenario and start the box(es).

<img src="https://github.com/Icinga/icinga-vagrant/blob/master/doc/images/basics/vagrant_windows_icinga_list_up.png" alt="Windows Vagrant Up" height="300">

Proceed here for an overview about all available [boxes](#boxes).

## Boxes <a id="boxes"></a>

### Icinga 2 Standalone <a id="boxes-icinga2x"></a>

* 1 VM
* [Icinga 2](https://www.icinga.com/products/icinga-2/)
* [Icinga Web 2](https://www.icinga.com/products/icinga-web-2/)
  * [Icinga Director](https://github.com/Icinga/icingaweb2-module-director), [Grafana](https://github.com/Mikesch-mp/icingaweb2-module-grafana), [Business Process](https://github.com/Icinga/icingaweb2-module-businessprocess), [Generic TTS](https://github.com/Icinga/icingaweb2-module-generictts), [NagVis](https://github.com/Icinga/icingaweb2-module-nagvis), [Map](https://github.com/nbuchwitz/icingaweb2-module-map) modules
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
  Graphite Web	    | http://192.168.33.5:8003          | -
  Grafana           | http://192.168.33.5:8004          | admin/admin
  Dashing           | http://192.168.33.5:8005          | -

Note: In case Dashing is not running, restart it manually:

```
$ vagrant ssh -c "sudo systemctl start dashing-icinga2"
```


### Icinga 2 Cluster <a id="boxes-icinga2x-cluster"></a>

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


### Icinga 2 InfluxDB <a id="boxes-icinga2x-influxdb"></a>

* 1 VM
* [Icinga 2](https://www.icinga.com/products/icinga-2/)
* [Icinga Web 2](https://www.icinga.com/products/icinga-web-2/)
  * [Grafana](https://github.com/Mikesch-mp/icingaweb2-module-grafana) module
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


### Icinga 2 and Elastic Stack <a id="boxes-icinga2x-elastic"></a>

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

Note: Logstash integration is missing in [#31](https://github.com/Icinga/icinga-vagrant/issues/31).

#### Application Interfaces

  Application               | Url                               | Credentials
  --------------------------|-----------------------------------|----------------
  Icinga Web 2              | http://192.168.33.7/icingaweb2    | icingaadmin/icinga
  Icinga 2 API              | https://192.168.33.7:5665/v1      | root/icinga
  Kibana                    | http://192.168.33.7:5601          | icinga/icinga
  Elasticsearch/Nginx       | http://192.168.33.7:9200	        | icinga/icinga
  Kibana (TLS)              | https://192.168.33.7:5602         | icinga/icinga
  Elasticsearch/Nginx (TLS) | https://192.168.33.7:9202	        | icinga/icinga

### Icinga 2 and Graylog <a id="boxes-icinga2x-graylog"></a>

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


# Configuration <a id="configuration"></a>

The default configuration for specific scenarios is stored in the `Vagrantfile.nodes` file.
In case you want to modify its content to e.g. add synced folders or change the host-only IP address
you can copy its content into the `Vagrantfile.local` file and modify it there.

`Vagrantfile.local` is not tracked by Git.

If you change the base box, keep in mind that provisioning only has been tested and developed
with CentOS 7, no other distributions are currently supported.

Example for additional synced folders:

```
$ vim icinga2x/Vagrantfile.local

nodes = {
  'icinga2' => {
    :box_virtualbox => 'bento/centos-7.4',
    :box_parallels  => 'bento/centos-7.4',
    :box_libvirt    => 'centos/7',
    :net            => 'demo.local',
    :hostonly       => '192.168.33.5',
    :memory         => '2048',
    :cpus           => '2',
    :mac            => '020027000500',
    :forwarded      => {
      '443'  => '8443',
      '80'   => '8082',
      '22'   => '2082',
      '8003' => '8082'
    },
    :synced_folders => {
      '../../icingaweb2-module-graphite' => '/usr/share/icingaweb2-modules/graphite'
    }
  }
}
```


# FAQ <a id="faq"></a>

## Vagrant Commands <a id="faq-vagrant-commands"></a>

### Up <a id="faq-vagrant-commands-up"></a>

Start all VMs:

```
$ vagrant up
```

Depending on the provider you have chosen above, you might want to set
it explicitely:

```
$ vagrant up --provider=virtualbox
```

### SSH <a id="faq-vagrant-commands-ssh"></a>

SSH into the box as local `vagrant` user (**Tip**: Use `sudo -i` to become `root`):

```
$ vagrant ssh
```

> **Note**
>
> Multi-VM boxes require the hostname for `vagrant ssh` like so: `vagrant ssh icinga2b`.
> That works in a similar fashion for other sub commands.

### Halt <a id="faq-vagrant-commands-halt"></a>

Stop all VMs:

```
$ vagrant halt
```

### Provision <a id="faq-vagrant-commands-provision"></a>

Update packages/reset configuration for all VMs:

```
$ vagrant provision
```

### Destroy <a id="faq-vagrant-commands-destroy"></a>

Destroy the VM (add `-f` to avoid the safety question)

```
$ vagrant destroy
```


## Documentation Reference <a id="faq-documentation-reference"></a>

Documentation for software used inside these boxes.

Project			| URL
------------------------|------------------------------
Icinga 2		| https://www.icinga.com/docs/icinga2/latest/doc/01-about/
Icinga Web 2		| https://www.icinga.com/docs/icingaweb2/latest/doc/01-About/
Director 		| https://www.icinga.com/docs/director/latest/doc/01-Introduction/
NagVis			| https://www.nagvis.org/doc
Graphite		| https://graphite.readthedocs.io
InfluxDB		| https://docs.influxdata.com/influxdb/
Grafana			| https://docs.grafana.org
Elastic			| https://www.elastic.co/guide/
Graylog			| http://docs.graylog.org

## Vagrant update <a id="faq-vagrant-update"></a>

On local config change (git pull for this repository).

```
$ pwd
$ git pull
$ git log
$ vagrant provision
```

## Behind a proxy <a id="faq-behind-proxy"></a>

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

# Thanks <a id="thanks"></a>

* [lippserd](https://github.com/lippserd) for the initial Vagrant box idea from Icinga Web 2.
* [gunnarbeutner](https://github.com/gunnarbeutner) for the base setup with Icinga 2.
* [NETWAYS](https://github.com/NETWAYS) for sponsoring the initial Icinga 2 Cluster setup.
* [bernd](https://github.com/bernd) for the Graylog box.
* [nbuchwitz](https://github.com/nbuchwitz) for fixes and workarounds on broken packages.
* [kornm](https://github.com/KornM) for the Vagrant HTTP proxy FAQ.
* [ruzickap](https://github.com/ruzickap) for the libvirt provider.
* [mightydok](https://github.com/mightydok) for fixes on Virtualbox provider.
* [joonas](https://github.com/joonas) for Puppet provisioner fixes.
* [tomdc](https://github.com/tomdc) for his contributions to Icinga 1.x/Jasper.

# Contributing <a id="contributing"></a>

## Overview <a id="contributing-overview"></a>

Each box uses a generic Vagrantfile to set the required resources for initial VM
startup. The `Vagrantfile` includes the `Vagrantfile.nodes` file which defines
VM specific settings.

The generic `shell_provisioner.sh` script ensures that all VM requirements are fulfilled
and also takes care about installing Puppet which will be used as provisioner in the next
step.

The main entry point is the Puppet provisioner which calls the `manifest/default.pp`.
Anything compiled into this catalog will be installed into the VM.

> **Note**
>
> The provisioner still uses Puppet 3. A migration to Puppet 5 is planned, see the GitHub issues.
> This requires major refactoring into roles/profiles too.

## Base Boxes <a id="contributing-base-boxes"></a>

Provider        | Base Box
----------------|----------------
VirtualBox      | [Bento](https://app.vagrantup.com/bento/)
Parallels       | [Bento](https://app.vagrantup.com/bento/)
libvirt         | [libvirt](https://app.vagrantup.com/centos/)

Pull updates.

```
vagrant box update
```

## Tools <a id="contributing-tools"></a>

### InfluxDB <a id="contributing-tools-influxdb"></a>

Current version via HTTP API:
```
curl -sl -I 192.168.33.8:8086/ping
```


## Puppet Module Overview <a id="contributing-puppet-modules"></a>

The Vagrant boxes use these imported puppet modules for provisioning. The modules are
pulled into this repository as git subtree. The main reason for not using submodules is
that the upstream source may be gone if this project does not catch with updating/migrating.

General:

  Name                     | Puppet Version | Path                      | Url
  -------------------------|----------------|---------------------------|-------------------------------
  puppetlabs-stdlib        | >= 2.7.20      | modules/stdlib            | https://github.com/puppetlabs/puppetlabs-stdlib.git
  puppetlabs-concat        | >= 4.7.0       | modules/concat            | https://github.com/puppetlabs/puppetlabs-concat.git
  puppetlabs-apache        | >= 4.7.0       | modules/apache            | https://github.com/puppetlabs/puppetlabs-apache.git
  puppetlabs-mysql         | >= 4.7.0       | modules/mysql             | https://github.com/puppetlabs/puppetlabs-mysql.git
  puppetlabs-postgresql    | >= 4.7.0       | modules/postgresql        | https://github.com/puppetlabs/puppetlabs-postgresql.git
  puppetlabs-vcsrepo       | >= 4.7.0       | modules/vcsrepo           | https://github.com/puppetlabs/puppetlabs-vcsrepo.git
  puppet-module-epel       | >= 3.0.0       | modules/epel              | https://github.com/stahnma/puppet-module-epel.git
  puppet-php               | >= 4.7.0<5.0.0 | modules/php               | https://github.com/voxpupuli/puppet-php.git
  puppet-selinux           | >= 4.7.1       | modules/selinux           | https://github.com/voxpupuli/puppet-selinux.git
  puppetlabs-java          | >= 4.7.0       | modules/java              | https://github.com/puppetlabs/puppetlabs-java.git
  puppet-yum               | >= 4.6.1       | modules/yum               | [ ] NEW: https://github.com/voxpupuli/puppet-yum OLD: https://github.com/CERIT-SC/puppet-yum.git
  puppet-archive           | >= 4.7.1       | modules/archive           | https://github.com/voxpupuli/puppet-archive.git
  puppet-vim               | >=4.0.0<5.0.0  | modules/vim               | https://github.com/saz/puppet-vim.git
  puppet-datacat           | Type for ES    | modules/datacat           | https://github.com/richardc/puppet-datacat.git
  puppet-inifile           | >= 4.7.0       | modules/inifile           | https://github.com/puppetlabs/puppetlabs-inifile.git

Specific projects:

  Name                     | Puppet Version | Path                      | Url
  -------------------------|----------------|---------------------------|-------------------------------
  puppet-elastic-stack     | >= 4.6.1       | modules/elastic\_stack    | https://github.com/elastic/puppet-elastic-stack
  puppet-icinga2           | 4.x            | modules/icinga2           | [ ] TO BE ADDED
  puppet-icingaweb2        | >= 4.7.0       | modules/icingaweb2        | [ ] TO BE ADDED
  puppet-graylog           | ???            | modules/graylog           | [ ] NEEDS v4 SUPPORT https://github.com/Graylog2/puppet-graylog.git
  puppet-elasticsearch     | >= 4.5.0       | modules/elasticsearch     | https://github.com/elasticsearch/puppet-elasticsearch.git
  puppet-nginx             | >= 4.7.0       | modules/nginx             | https://github.com/voxpupuli/puppet-nginx.git
  puppet-logstash          | >= 4.6.1       | modules/logstash          | https://github.com/elastic/puppet-logstash.git
  puppet-kibana            | >= 4.5.0       | modules/kibana            | https://github.com/elastic/puppet-kibana.git
  puppet-filebeat          | >= 4.0.0       | modules/filebeat          | https://github.com/pcfens/puppet-filebeat.git
  puppetlabs-mongodb       | >= 4.7.1       | modules/mongodb           | https://github.com/puppetlabs/puppetlabs-mongodb.git
  golja-influxdb           | >= 3.0.0<5.0.0 | modules/influxdb          | [ ] NEEDS TESTS https://github.com/n1tr0g/golja-influxdb.git
  puppet-graphite          | >= 3.0.0<5.0.0 | modules/graphite          | [ ] NEEDS TESTS ON UPDATE https://github.com/echocat/puppet-graphite.git
  puppet-grafana           | >= 4.7.1       | modules/grafana           | [ ] NEW https://github.com/voxpupuli/puppet-grafana OLD https://github.com/bfraser/puppet-grafana.git


### Puppet Module Git Subtree <a id="contributing-puppet-module-git-subtree"></a>

**Notes for developers only.**

Add subtree:

    $ git subtree add --prefix modules/vim https://github.com/saz/puppet-vim master --squash

Update subtree:

    $ git subtree pull --prefix modules/postgresql https://github.com/puppetlabs/puppetlabs-postgresql.git master --squash
