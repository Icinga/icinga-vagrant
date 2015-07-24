# Icinga Vagrant Boxes

Icinga Vagrant boxes used for development, tests and demo cases.

Additionally there are boxes with special uses cases like Graphite,
Graylog2, etc.

## Requirements

Each VM requires at least 1 Core and 1 GB RAM.

The icinga2x-cluster demo with 2 VMs requires at least a Quad-Core with 4 GB RAM.

* Vagrant >= 1.6.5 from http://www.vagrantup.com
* Virtualbox >= 4.2.16 from http://www.virtualbox.org

Windows users require additionally

* SSH provided by the Git package from http://msysgit.github.io
* Ruby for Windows from http://rubyinstaller.org (add Ruby executables to PATH)

You can use `init.sh` (Linux) and `init.bat` (Windows) to check the pre-requisites.

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

Follow the instructions described in the `README.md` file
for each box.

Choose one of the available boxes below.

## Available Vagrant Boxes

### Icinga 1.x

* 1 VM
* Icinga 1.x Core, IDOUtils MySQL, Classic UI, Web

[Documentation](icinga1x/README.md):

    $ cd icinga1x && vagrant up

### Icinga 2 Standalone

* 1 VM
* Icinga 2 Core, DB IDO MySQL, Icinga 1.x Classic UI/Web, Icinga Web 2

[Documentation](icinga2x/README.md):

    $ cd icinga2x && vagrant up

### Icinga 2 Cluster

* 2 VMs as Icinga 2 Master/Checker Cluster
* Icinga 2 Core, DB IDO MySQL, Icinga Web 2

[Documentation](icinga2x-cluster/README.md):

    $ cd icinga2x-cluster && vagrant up

### Icinga 2 and Graylog2

* 1 VM
* Icinga 2 Core
* Graylog2 Server and Web with Elasticsearch, MongoDB

[Documentation](icinga2x-graylog2/README.md):

    $ cd icinga2x-graylog2 && vagrant up

### Graphite Standalone

> use https://github.com/pkkummermo/grafana-vagrant-puppet-box
> or a different box instead.

### Port Forwarding Overview

  Box Name          | VM Name   | Host Port | Guest Port
  ------------------|-----------|-----------|-----------
  icinga1x          | icinga1x  | 2081      | 22
  icinga1x          | icinga1x  | 8081      | 80
  icinga1x          | icinga1x  | 8082      | 8080
  icinga2x          | icinga2   | 2080      | 22
  icinga2x          | icinga2   | 8080      | 80
  icinga2x-cluster  | icinga2a  | 2085      | 22
  icinga2x-cluster  | icinga2a  | 8085      | 80
  icinga2x-cluster  | icinga2b  | 2086      | 22
  icinga2x-cluster  | icinga2b  | 8086      | 80
  icinga2x-graylog2 | i2g2	| 2110      | 22
  icinga2x-graylog2 | i2g2	| 8110      | 80
  icinga2x-graylog2 | i2g2	| 9000      | 9000
  icinga2x-graylog2 | i2g2	| 12201     | 12201 (tcp/udp)
  icinga2x-graylog2 | i2g2	| 12900     | 12900

### Puppet Module Overview

These boxes use these imported puppet modules for provisioning:

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
  graylog2-puppet	| modules/graylog2		| https://github.com/Graylog2/graylog2-puppet.git
  puppet-elasticsearch	| modules/elasticsearch		| https://github.com/elasticsearch/puppet-elasticsearch.git
  puppetlabs-mongodb	| modules/mongodb		| https://github.com/puppetlabs/puppetlabs-mongodb.git
  puppetlabs-java	| modules/java			| https://github.com/puppetlabs/puppetlabs-java.git



