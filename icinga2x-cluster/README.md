# Icinga 2 Multi Instance Vagrant Boxes

* Icinga 2 Core as cluster (icinga2a cfg master, icinga2b checker)
* Icinga Web 2 as user interface with internal auth db and IDO backend

Overview:

  Instance  | Network                   | HTTP
  ----------|---------------------------|--------------------------------------
  icinga2a  | host_only 192.168.33.10   | http://192.168.33.10
  icinga2b  | host_only 192.168.33.20   | http://192.168.33.20

Backend is IDO MySQL only.

## Requirements

* Vagrant >= 1.6.5 from http://www.vagrantup.com
* Virtualbox >= 4.2.16 from http://www.virtualbox.org

Windows users require additionally:

* SSH provided by the Git package from http://msysgit.github.io
* Ruby for Windows from http://rubyinstaller.org (add Ruby executables to PATH)


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


## User Interfaces

http://localhost:8085 and http://localhost:8086 show an entry page including all
urls and credentials.

  GUI               | Url               | Credentials
  ------------------|-------------------|----------------
  Icinga Web 2      | /icingaweb2       | icingaadmin/icinga


## Ports

  VM Name   | Host Port | Guest Port
  ----------|-----------|-----------
  icinga2a  | 2085      | 22
  icinga2a  | 8085      | 80
  icinga2b  | 2086      | 22
  icinga2b  | 8086      | 80


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

# Updates

## Vagrant update

On local config change (git pull for this repository).

    $ pwd
    $ git pull
    $ git log
    $ vagrant provision
