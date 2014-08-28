# Graphite Standalone Vagrant Box

* Graphite: Carbon Cache, Whisper, Web

  Instance                              | Url
  --------------------------------------|--------------------------------------
  graphite-web                          | http://localhost:8090

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

http://localhost:8080 shows Graphite web.

  GUI               | Url               | Credentials
  ------------------|-------------------|----------------
  Graphite Web      | /                 | none required


## Ports

  VM Name   | Host Port | Guest Port
  ----------|-----------|-----------
  graphite  | 2090      | 22
  graphite  | 8090      | 80


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

The Graphite documentation is located at http://graphite.readthedocs.org/en/latest/

# Updates

## Vagrant update

On local config change (git pull for this repository).

    $ pwd
    $ git pull
    $ git log
    $ vagrant provision
