#!/bin/sh

I2WEBGIT="icinga2x-cluster/icingaweb2"

echo "Initializing Icinga Web 2 git submoule in main dir..."
cd ..
git submodule init && git submodule update
echo "..."

echo "Fetching latest Icinga Web 2 git master"
cd $I2WEBGIT; git checkout master; git pull origin master; cd ..
echo "..."

echo "Done. Now proceed with 'vagrant up'"
