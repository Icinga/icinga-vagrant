# -*- mode: ruby -*-
# vi: set ft=ruby :

raise "VAGRANT_HOME needs to be defined prior vagrant_helper!" unless defined? VAGRANT_HOME

VAGRANTFILE_API_VERSION = "2" unless defined? VAGRANTFILE_API_VERSION
VAGRANT_REQUIRED_VERSION = "1.8.0" unless defined? VAGRANT_REQUIRED_VERSION
VAGRANT_REQUIRED_LINKED_CLONE_VERSION = "1.8.4" unless defined? VAGRANT_REQUIRED_LINKED_CLONE_VERSION

# Require 1.6.5 at least
if ! defined? Vagrant.require_version
  if Gem::Version.new(Vagrant::VERSION) < Gem::Version.new(VAGRANT_REQUIRED_VERSION)
    puts "Vagrant >= " + VAGRANT_REQUIRED_VERSION + " required. Your version is " + Vagrant::VERSION
    exit 1
  end
else
  Vagrant.require_version ">= " + VAGRANT_REQUIRED_VERSION
end

nodesFile = VAGRANT_HOME + "/Vagrantfile.nodes"
localFile = VAGRANT_HOME + "/Vagrantfile.local"
nodes = {}

raise "ERROR: Vagrantfile.nodes is missing from source tree." unless File.exists?(nodesFile)

eval(IO.read(nodesFile), binding)

# allow to override the configuration
eval(IO.read(localFile), binding) if File.exists?(localFile)

# Export nodes to global scope
$nodes = nodes
