# Icinga 2 Standalone Vagrant Box

* Icinga 2 Core
* Legacy interfaces: Icinga Classic UI, Web 1.x

- icinga2 - http://localhost:8080

Backend is IDO MySQL only.

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


## SSH Access

Either `vagrant ssh` or manually.

  Name            | Value
  ----------------|----------------
  Host            | 127.0.0.1
  Port            | 2222
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
