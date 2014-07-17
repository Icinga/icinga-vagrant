#!/bin/bash

set -e

chmod 755 /vagrant

mountVagrant () {
    if ! $(/bin/mount | /bin/grep -q "/vagrant$"); then
        # Remount /vagrant/icingaweb2/ with appropriate permissions since the group apache is missing initially
        /bin/mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g apache`,dmode=775,fmode=664 /vagrant /vagrant
    fi
}

mountIcinga2web () {
    if ! $(/bin/mount | /bin/grep -q "/vagrant/icingaweb2$"); then
        # Remount /vagrant/icingaweb2/ with appropriate permissions since the group apache is missing initially
        /bin/mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g apache`,dmode=775,fmode=664 /vagrant/icingaweb2 /vagrant/icingaweb2
    fi
}

mountIcinga2webVarLog () {
    if ! $(/bin/mount | /bin/grep -q "/vagrant/icingaweb2/var/log"); then
        # Remount /vagrant/icingaweb2/var/log/ with appropriate permissions since the group apache is missing initially
        /bin/mount -t vboxsf -o \
            uid=`id -u vagrant`,gid=`id -g apache`,dmode=775,fmode=664 \
            /vagrant/icingaweb2/var/log/ \
            /vagrant/icingaweb2/var/log/
    fi
}

mountVagrant
mountIcinga2web
mountIcinga2webVarLog

echo "Done."

exit 0

