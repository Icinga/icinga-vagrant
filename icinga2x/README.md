# Icinga 2 Standalone Vagrant Box

* Icinga 2 Core
* Legacy interfaces: Icinga Classic UI, Web 1.x
* Icinga Web 2 as user interface with internal auth db and DB IDO MySQL backend


  Instance  | Network                   | HTTP
  ----------|---------------------------|--------------------------------------
  icinga2   |                           | http://localhost:8080


Backend is IDO MySQL only.

## Requirements

* Vagrant >= 1.2.x from http://www.vagrantup.com
* Virtualbox >= 4.2.16 from http://www.virtualbox.org

Windows users require additionally

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

http://localhost:8080 shows an entry page including all urls and
credentials.

  GUI               | Url               | Credentials
  ------------------|-------------------|----------------
  Icinga Classic UI | /icinga           | icingaadmin/icingaadmin
  Icinga Web 1.x    | /icinga-web       | root/password
  Icinga Web 2      | /icingaweb        | icingaadmin/icinga


## Ports

  VM Name   | Host Port | Guest Port
  ----------|-----------|-----------
  icinga2   | 2080      | 22
  icinga2   | 8080      | 80


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
