# Icinga 1.x Demo Vagrant Box

* Icinga 1.x Core with IDOUtils MySQL
* Icinga Classic UI
* Icinga Web with Reporting Cronk
* Icinga Reporting with Jasperserver

  Instance                              | Url
  --------------------------------------|--------------------------------------
  icinga                                | http://localhost:8081

## Requirements

* Vagrant >= 1.2.x from http://www.vagrantup.com
* Virtualbox >= 4.2.16 from http://www.virtualbox.org

Windows users require additionally

* SSH provided by the Git package from http://msysgit.github.io
* Ruby for Windows from http://rubyinstaller.org (add Ruby executables to PATH)


## Installation

    $ vagrant up

    $ vagrant ssh

    $ sudo -i


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
