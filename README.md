# Icinga Vagrant Boxes

Icinga Vagrant boxes used for development, tests and demo cases.

## Requirements

Each VM requires at least 1 Core and 1 GB RAM.

The icinga2x-cluster demo with 2 VMs only makes sense on a Quad-Core with at
least 4 GB RAM.

* Vagrant >= 1.2.x from http://www.vagrantup.com
* Virtualbox >= 4.2.16 from http://www.virtualbox.org

Windows users require additionally

* SSH provided by the Git package from http://msysgit.github.io
* Ruby for Windows from http://rubyinstaller.org (add Ruby executables to PATH)

## Icinga 1.x

* 1 box
* Icinga 1.x Core, IDOUtils MySQL, Classic UI, Web

    $ cd icinga1x && less README.md

## Icinga 2 Standalone

* 1 box
* Icinga 2 Core, DB IDO MySQL, Icinga 1.x Classic UI/Web, Icinga Web 2

    $ cd icinga2x && less README.md

## Icinga 2 Cluster

* 2 boxes as Icinga 2 Master/Checker Cluster
* Icinga 2 Core, DB IDO MySQL, Icinga Web 2

    $ cd icinga2x-cluster && less README.md

## Graphite Standalone

* 1 box
* Graphite with whisper, carbon cache, web

    $ cd graphite && less README.md

