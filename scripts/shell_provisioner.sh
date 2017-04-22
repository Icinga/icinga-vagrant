#!/bin/bash

set -e

OSTYPE="unknown"

if [ -x /usr/bin/lsb_release ]; then
  OSTYPE=$(lsb_release -i -s)
  CODENAME=$(lsb_release -sc)
elif [ -e /etc/redhat-release ]; then
  OSTYPE="RedHat"
else
  echo "Unsupported OS!" >&2
  exit 1
fi

if [ ! -e /var/initial_update ]; then
    echo "Running initial upgrade"
    if [ "$OSTYPE" = "Debian" ] || [ "$OSTYPE" = "Ubuntu" ]; then
        apt-get update
        apt-get dist-upgrade -y
        date > /var/initial_update
    elif [ "$OSTYPE" = "RedHat" ]; then
        yum update -y
        date > /var/initial_update
    fi
fi

if [ "$OSTYPE" = "Debian" ]; then
    bp="/etc/apt/sources.list.d/backports.list"
    if [ ! -e "$bp" ]; then
        echo "Enabling backports repo"
        echo "deb http://httpredir.debian.org/debian ${CODENAME}-backports main" >"$bp"
        apt-get update
    fi

    bpp="/etc/apt/sources.list.d/backports-puppet3.list"
    if [ ! -e "${bpp}" ]; then
        echo "Using backports snapshot for Puppet 3.8"
        echo "deb http://snapshot.debian.org/archive/debian/20160504T101549Z/ jessie-backports main" \
            > "${bpp}"
        apt-get -o Acquire::Check-Valid-Until=false update
    fi
elif [ "$OSTYPE" = "Ubuntu" ]; then
    if [ ! -e /etc/apt/sources.list.d/puppetlabs.list ]; then
        echo "Installing Puppetlabs release package..."
        wget -O /tmp/puppetlabs.deb "https://apt.puppetlabs.com/puppetlabs-release-${CODENAME}.deb"
        dpkg -i /tmp/puppetlabs.deb
        rm -f /tmp/puppetlabs.deb
        apt-get update
    fi
elif [ "$OSTYPE" = "RedHat" ]; then
    if [ ! -e /etc/yum.repos.d/puppetlabs.repo ]; then
        echo "Installing Puppet 3 release..."
        yum install -y https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
    fi
fi

if [ "$OSTYPE" = "Debian" ]  || [ "$OSTYPE" = "Ubuntu" ]; then
    if ! dpkg -l puppet &>/dev/null; then
        echo "Installing puppet..."
        apt-get install -y "puppet=3.8*" "puppet-common=3.8*"
    fi

    bpp="/etc/apt/sources.list.d/backports-puppet3.list"
    if [ -e "${bpp}" ] && grep "^deb" "${bpp}"; then
        echo "Disabling temporary snapshot repository..."
        sed -i 's/^deb/#\0/' "${bpp}"
        apt-get update
    fi

elif [ "$OSTYPE" = "RedHat" ]; then
    if ! rpm -q puppet &>/dev/null; then
        echo "Installing puppet..."
        yum install -y puppet
    fi
fi

if [ "$OSTYPE" = "RedHat" ]; then
    if [ `getenforce` = 'Enforcing' ]; then
        echo "Setting selinux to permissive"
        setenforce 0
    fi

    if grep -qP "^SELINUX=enforcing" /etc/selinux/config; then
        echo "Disabling selinux after reboot"
        sed -i 's/^\\(SELINUX=\\)enforcing/\\1disabled/' /etc/selinux/config
    fi
fi
