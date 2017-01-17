# Icinga 2 HA Cluster Vagrant Boxes

* Icinga 2 Core as HA cluster (icinga2a and icinga2b as HA master, icinga2c as checker)
* Icinga Web 2 as user interface with internal auth db and IDO backend

Overview:

  Instance  | Network                   | HTTP
  ----------|---------------------------|--------------------------------------
  icinga2a  | host only 192.168.33.101  | http://192.168.33.101
  icinga2b  | host only 192.168.33.102  | http://192.168.33.102
  icinga2c  | host only 192.168.33.103  | http://192.168.33.103

## User Interfaces

  GUI               | Url                                   | Credentials
  ------------------|---------------------------------------|----------------
  Icinga Web 2      | http://192.168.33.101/icingaweb2      | icingaadmin/icinga
  Icinga Web 2      | http://192.168.33.102/icingaweb2      | icingaadmin/icinga
  Icinga Web 2      | http://192.168.33.103/icingaweb2      | icingaadmin/icinga

## Icinga 2 API

Access

* [https://192.168.33.101:5665/v1/objects/hosts](https://192.168.33.101:5665/v1/objects/hosts)
* [https://192.168.33.102:5665/v1/objects/hosts](https://192.168.33.102:5665/v1/objects/hosts)
* [https://192.168.33.103:5665/v1/objects/hosts](https://192.168.33.103:5665/v1/objects/hosts)

using the credentials `root/icinga`.


## Requirements

Each Vagrant box setup requires at least 2 Cores and 1 GB RAM.
The required resources are automatically configured during the
`vagrant up` run.

* Vagrant >= 1.6.5 from http://www.vagrantup.com

One of these virtualization providers:

* Virtualbox >= 4.2.16 from http://www.virtualbox.org
* Parallels Desktop Pro/Business >= 11 from http://www.parallels.com/products/desktop/

Windows users require additionally

* SSH provided by the Git package from http://msysgit.github.io
* Ruby for Windows from http://rubyinstaller.org (add Ruby executables to PATH)

You can use `init.sh` (Linux) and `init.bat` (Windows) to check the pre-requisites.

### Virtualbox Provider

If Virtualbox is installed, this will be enabled by default.

### Parallels Provider

You'll need to install the [vagrant-paralells](http://parallels.github.io/vagrant-parallels/docs/)
plugin first:

    $ vagrant plugin install vagrant-parallels

## Installation

You can only do `vagrant up` in a box directory. Verify that
by checking for the existance of the `Vagrantfile` file in the current
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

## Documentation

The Icinga 2 documentation is located at http://docs.icinga.com

# Updates

## Vagrant update

On local config change (git pull for this repository).

    $ pwd
    $ git pull
    $ git log
    $ vagrant provision
