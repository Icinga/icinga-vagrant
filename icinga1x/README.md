# Icinga 1.x Demo Vagrant Box

* Icinga 1.x Core with IDOUtils MySQL
* Icinga Classic UI
* Icinga Web with Reporting Cronk
* Icinga Reporting with Jasperserver

  Instance                              | Url
  --------------------------------------|--------------------------------------
  icinga                                | http://localhost:8080

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

  GUI               | Url               | Credentials
  ------------------|-------------------|----------------
  Icinga Classic UI | :8080/icinga      | icingaadmin/icingaadmin
  Icinga Web 1.x    | :8080//icinga-web	| root/password
  Jasperserver	    | :8081/jasperserver | jasperadmin/jasperadmin

> **Note**
>
> The Icinga Web Reporting Cronk fetches its data directly from Jasperserver via PHP SOAP api.

## SSH Access

Either `vagrant ssh` or manually.

  Name            | Value
  ----------------|----------------
  Host            | 127.0.0.1
  Port            | 2222
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

