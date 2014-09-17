# Icinga 1.x Demo Vagrant Box

* Icinga 1.x Core with IDOUtils MySQL
* Icinga Classic UI
* Icinga Web with Reporting Cronk
* Icinga Reporting with Jasperserver


  Instance  | Network                   | HTTP
  ----------|---------------------------|--------------------------------------
  icinga    |                           | http://localhost:8081

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

  GUI               | Url                   | Credentials
  ------------------|-----------------------|----------------
  Icinga Classic UI | :8081/icinga          | icingaadmin/icingaadmin
  Icinga Web 1.x    | :8081//icinga-web	    | root/password
  Jasperserver	    | :8082/jasperserver    | jasperadmin/jasperadmin

> **Note**
>
> The Icinga Web Reporting Cronk fetches its data directly from Jasperserver via PHP SOAP api.

## Ports

  VM Name   | Host Port | Guest Port
  ----------|-----------|-----------
  icinga1x  | 2081      | 22
  icinga1x  | 8081      | 80
  icinga1x  | 8082      | 8080


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

The Icinga 1.x documentation is located at http://docs.icinga.org

# Updates

## Vagrant update

On local config change (git pull for this repository).

    $ pwd
    $ git pull
    $ git log
    $ vagrant provision
