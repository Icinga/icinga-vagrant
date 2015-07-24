#!/bin/bash
echo "Checking pre-requisites."

function vercomp {
  [ ! $(echo -e "$1\n$2" | sort --version-sort | head -1) = "$2" ]
}

# vagrant
vagrant_version=`vagrant --version | sed -e 's/Vagrant\s//g'`
vagrant_version_req=1.6.5

if vercomp vagrant_version_req vagrant_version; then
  echo "$vagrant_version is older than required $vagrant_version_req"
  exit 1
fi

# virtualbox
vbox_version=`vboxmanage --version | sed -e 's/_.*//g'`
vbox_version_req=4.2.16

if vercomp vbox_version_req vbox_version; then
  echo "$vbox_version is older than required $vbox_version_req"
  exit 1
fi

# git
if ! git --version 2>&1 >/dev/null; then
  echo "Cannot determine git executable, please fix it!"
  exit 1
fi

# ruby
if ! ruby -v 2>&1 >/dev/null; then
  echo "Cannot determine ruby executable, please fix it!"
  exit 1
fi

# ssh
if ! ssh -V 2>/dev/null; then
  echo "Cannot determine ssh executable, please fix it!"
  exit 1
fi

echo "Done. Now navigate into the available Vagrant boxes."



