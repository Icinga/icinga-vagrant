#!/bin/sh

git submodule init .. && git submodule update ..
cd icingaweb2; git checkout master; git pull origin master; cd ..
