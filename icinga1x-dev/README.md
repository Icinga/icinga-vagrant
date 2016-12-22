# About

Development box for Icinga 1.x and Icinga Web 1.x.

# Developer's Hints

    ssh -A vagrant@192.168.33.190
    git config --global user.name "Michael Friedrich"
    git config --global user.email "michael.friedrich@icinga.com"

## Icinga Core 1.x

    ssh -A vagrant@192.168.33.190
    git clone git@git.icinga.org:icinga-core.git

    cd icinga-core
    make distclean
    ./configure --with-init-dir=/etc/init.d --with-plugin-dir=/usr/lib64/nagios/plugins --with-command-group=icingacmd
    make all
    sudo make fullinstall
    sudo make install-config

    sudo systemctl restart httpd

    /etc/init.d/icinga restart

Specific CGI changes:

    make cgis
    sudo make install-cgis

### IDOUtils

    sudo mysql -e "CREATE DATABASE icinga;"
    sudo mysql -e "GRANT ALL ON icinga.* TO 'icinga'@'localhost' IDENTIFIED BY 'icinga';"
    sudo mysql icinga < /home/vagrant/icinga-core/module/idoutils/db/mysql/mysql.sql

    mv /usr/local/icinga/etc/idomod.cfg-sample /usr/local/icinga/etc/idomod.cfg
    mv /usr/local/icinga/etc/ido2db.cfg-sample /usr/local/icinga/etc/ido2db.cfg

    mv /usr/local/icinga/etc/modules/idoutils.cfg-sample /usr/local/icinga/etc/modules/idoutils.cfg

    /etc/init.d/icinga restart

http://192.168.33.190/icinga - icingaadmin/icingaadmin

### Docs

    make create-docs

## Icinga Web 1.x

    ssh -A vagrant@192.168.33.190
    git clone git@git.icinga.org:icinga-web.git
    cd icinga-web

    ./configure
    sudo make install install-apache-config

    sudo mysql -e "CREATE DATABASE icinga_web;"
    sudo mysql -e "GRANT ALL ON icinga_web.* TO 'icinga_web'@'localhost' IDENTIFIED BY 'icinga_web';"
    sudo mysql icinga_web < /home/vagrant/icinga-web/etc/schema/mysql.sql

    sudo systemctl restart httpd

http://192.168.33.190/icinga-web - root/password

## Icinga 2 Classic UI Tests

    yum -y install icinga2
    icinga2 api setup

    cat >/etc/icinga2/conf.d/api-users.conf <<EOF
    object ApiUser "root" {
      password = "icinga"
    }
    EOF

    icinga2 feature enable statusdata compatlog command

    systemctl restart icinga2

    yumdownloader icinga2-classicui-config
    rpm2cpio icinga2-classicui-* | cpio -ivd
    sudo cp ./etc/icinga/cgi.cfg /usr/local/icinga/etc/cgi-icinga2.cfg

    sudo cp /usr/local/icinga/etc/cgi.cfg /usr/local/icinga/etc/cgi-icinga1.cfg

    echo >>/usr/local/icinga/etc/cgi.cfg <<EOF
    standalone_installation=1
    object_cache_file=/var/cache/icinga2/objects.cache
    status_file=/var/cache/icinga2/status.dat
    resource_file=/etc/icinga/resource.cfg
    command_file=/var/run/icinga2/cmd/icinga2.cmd
    check_external_commands=1
    interval_length=60
    status_update_interval=10
    log_file=/var/log/icinga2/compat/icinga.log
    log_rotation_method=h
    log_archive_path=/var/log/icinga2/compat/archives
    date_format=us
    EOF


# Releases

## Icinga 1.x

Versions:

    ./update-version 1.14.0

Docs:

    ./configure && make create-docs

Changelog:

    vim Changelog

## Icinga Web 1.x

Versions:

    vim etc/make/version.m4
    autoconf
    vim doc/VERSION
    vim icinga-web.spec

Changelog:

    vim doc/CHANGELOG-1.14
