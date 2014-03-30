#!/bin/bash

set -e

mountIcinga2webConfd () {
    # Remount /vagrant/config/ with appropriate permissions since the group apache is missing initially
    mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g apache`,dmode=775,fmode=775 /vagrant/icingaweb2/config/ /vagrant/icingaweb2/config/
}

mountIcinga2webVarLog () {
    # Remount /vagrant/var/log/ with appropriate permissions since the group apache is missing initially
    mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g apache`,dmode=775,fmode=775 /vagrant/icingaweb2/var/log/ /vagrant/icingaweb2/var/log/
}

fixIcingaWeb2Config () {
    touch /etc/icingaweb/config.ini
    chown apache:apache /etc/icingaweb/config.ini
}

fixIcingaWeb2Config
mountIcinga2webConfd
mountIcinga2webVarLog

echo "Done."

exit 0

