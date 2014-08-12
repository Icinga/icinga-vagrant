# Icinga 2 Multi Instance Vagrant Boxes

* Icinga 2 Core as cluster (icinga2a cfg master, icinga2b checker)
* Icinga Web 2 as user interface with internal auth db and IDO backend

  Instance                              | Url
  --------------------------------------|--------------------------------------
  icinga2a (host_only 192.168.33.10)    | http://localhost:8085
  icinga2b (host_only 192.168.33.20)    | http://localhost:8086

Backend is IDO MySQL only.

## Requirements

* Vagrant >= 1.2.x from http://www.vagrantup.com
* Virtualbox >= 4.2.16 from http://www.virtualbox.org

Windows users require additionally

* SSH provided by the Git package from http://msysgit.github.io
* Ruby for Windows from http://rubyinstaller.org (add Ruby executables to PATH)


## Installation

    $ vagrant up

    $ vagrant ssh icinga2a
    $ vagrant ssh icinga2b

    $ sudo -i


## User Interfaces

http://localhost:8085 and http://localhost:8086 show an entry page including all
urls and credentials.

  GUI               | Url               | Credentials
  ------------------|-------------------|----------------
  Icinga Web 2      | /icingaweb        | icingaadmin/icinga


## SSH Access

Either `vagrant ssh <hostname>` or manually (open the VirtualBox gui and check the
network port forwarding).

  Name            | Value
  ----------------|----------------
  Host            | 127.0.0.1
  Port            | 2222 (22022)
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

