# Icinga Vagrant Boxes

Icinga Vagrant boxes used for development, tests and demo cases.

## Requirements

Each VM requires at least 1 Core and 1 GB RAM.

The icinga2x-cluster demo with 2 VMs requires at least a Quad-Core with 4 GB RAM.

* Vagrant >= 1.2.x from http://www.vagrantup.com
* Virtualbox >= 4.2.16 from http://www.virtualbox.org

Windows users require additionally

* SSH provided by the Git package from http://msysgit.github.io
* Ruby for Windows from http://rubyinstaller.org (add Ruby executables to PATH)

## Icinga 1.x

* 1 VM
* Icinga 1.x Core, IDOUtils MySQL, Classic UI, Web

[Documentation](icinga1x/README.md):

    $ cd icinga1x && less README.md

## Icinga 2 Standalone

* 1 VM
* Icinga 2 Core, DB IDO MySQL, Icinga 1.x Classic UI/Web, Icinga Web 2

[Documentation](icinga2x/README.md):

    $ cd icinga2x && less README.md

## Icinga 2 Cluster

* 2 VMs as Icinga 2 Master/Checker Cluster
* Icinga 2 Core, DB IDO MySQL, Icinga Web 2

[Documentation](icinga2x-cluster/README.md):

    $ cd icinga2x-cluster && less README.md

## Graphite Standalone

* 1 VM
* Graphite with whisper, carbon cache, web

[Documentation](graphite/README.md):

    $ cd graphite && less README.md

## Port Forwarding Overview

  Box Name          | VM Name   | Host Port | Guest Port
  ------------------|-----------|-----------|-----------
  icinga1x          | icinga1x  | 2081      | 22
  icinga1x          | icinga1x  | 8081      | 80
  icinga1x          | icinga1x  | 8082      | 8080
  icinga2x          | icinga2   | 2080      | 22
  icinga2x          | icinga2   | 8080      | 80
  icinga2x-cluster  | icinga2a  | 2085      | 22
  icinga2x-cluster  | icinga2a  | 8085      | 80
  icinga2x-cluster  | icinga2b  | 2086      | 22
  icinga2x-cluster  | icinga2b  | 8086      | 80
  graphite          | graphite  | 2090      | 22
  graphite          | graphite  | 8090      | 80
