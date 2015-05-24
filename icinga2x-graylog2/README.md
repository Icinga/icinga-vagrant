# Icinga 2 & Graylog Vagrant Box

* Icinga 2 Core & Icinga Web 2
* Graylog Server & Web
* MongoDB, Elasticsearch as Requirements

  Instance  | Network                   | HTTP
  ----------|---------------------------|--------------------------------------
  i2g2      |                           | http://localhost:8110
  i2g2      |                           | http://localhost:9000


## Setup

This box requires puppet modules for provisioning as git submodules.
Therefore you'll need to clone this repository recursively.

    $ git clone --recursive https://github.com/icinga/icinga-vagrant.git
    $ cd icinga-vagrant/icinga2x-graylog2

## Requirements

* Vagrant >= 1.6.5 from http://www.vagrantup.com
* Virtualbox >= 4.2.16 from http://www.virtualbox.org

Windows users require additionally

* SSH provided by the Git package from http://msysgit.github.io
* Ruby for Windows from http://rubyinstaller.org (add Ruby executables to PATH)


## Installation

You can only do `vagrant up` in a box directory. Verify that
by checking for the existence of the `Vagrantfile` file in the current
directory.

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


## User Interfaces

  GUI              | Url               | Credentials
  -----------------|-------------------|------------------------
  Graylog          | :8110/icingaweb2  | icingaadmin/icinga
  Graylog          | :9000/            | admin/admin


## Ports

  VM Name   | Host Port | Guest Port
  ----------|-----------|-----------
  i2g2      | 2110      | 22
  i2g2      | 8110      | 80
  i2g2      | 9000      | 9000
  i2g2      | 12201     | 12201 (tcp/udp)
  i2g2      | 12900     | 12900


## SSH Access

Either `vagrant ssh <hostname>` or manually (open the VirtualBox gui and check the
network port forwarding).

  Name            | Value
  ----------------|----------------
  Host            | 127.0.0.1
  Port            | Check [port list](#ports)
  Username        | vagrant
  Password        | vagrant


## Documentation

The Icinga 2 documentation is located at http://docs.icinga.org
The Graylog documentation is located at http://docs.graylog.org

# Updates

## Vagrant update

On local config change (git pull for this repository).

    $ pwd
    $ git pull
    $ git log
    $ vagrant provision
