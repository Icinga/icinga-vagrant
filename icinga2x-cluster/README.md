# Icinga 2 Multi Instance Vagrant Boxes

* Icinga 2 Core as cluster (icinga2a cfg master, icinga2b checker)
* Icinga Web 2 as user interface with local LDAP (auth) and IDO backend
* Legacy interfaces: Icinga Classic UI, Web 1.x

- icinga2a (host_only 192.168.33.10) - http://localhost:8080
- icinga2b (host_only 192.168.33.20) - http://localhost:8081

Both boxes mount icingaweb2/ for vagrant/virtualbox allowing to pull the
latest git master.

Backend is IDO MySQL only.

## Requirements

* Vagrant >= 1.2.x from http://www.vagrantup.com
* Virtualbox >= 4.2.16 from http://www.virtualbox.org

Windows users require additionally

* SSH provided by the Git package from http://msysgit.github.io
* Ruby for Windows from http://rubyinstaller.org (add Ruby executables to PATH)


## Installation

Tip: Shortcut:

  $ ./init.sh

The main directory requires the git submodules to be initialized.

  $ cd ..
  $ git submodule init && git submodule update

Then fetch the latest Icinga Web 2 git master.

  $ cd icinga2x-cluster/icingaweb2 && git pull origin master && cd ..

And proceed with the Vagrant startup:

  $ vagrant up

  $ vagrant ssh icinga2a
  $ vagrant ssh icinga2b

  $ sudo -i


## User Interfaces

http://localhost:8080 and http://localhost:8081 show an entry page including all
urls and credentials.

## SSH Access

Either `vagrant ssh <hostname>` or manually.

  Name            | Value
  ----------------|----------------
  Host            | 127.0.0.1
  Port            | 2222 (2022)
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

## Icinga Web 2 update

$ pwd
$ cd icingaweb2
$ git checkout master
$ git pull origin master

