# Purpose

Test-Box for installing and running Icinga 2.

No hostonly network available currently.

# Run

    $ vagrant up --provider virtualbox
    $ vagrant ssh

    $ sudo -i

# Install Icinga 2

    # env ASSUME_ALWAYS_YES=YES pkg install icinga2 wget curl gdb vim python

    # sysrc icinga2_enable=yes

    # icinga2 api setup

    # cat >/usr/local/etc/icinga2/conf.d/api-users.conf <<EOF
    object ApiUser "root" {
      password = "icinga"
      permissions = [ "*" ]
    }
    EOF

    # service icinga2 restart

# API tests

    # curl -k -s -u root:icinga -H 'Accept: application/json' -X POST https://localhost:5665/v1/config/packages/example-cmdb

    # curl -k -s -u root:icinga -H 'Accept: application/json' -X POST -d '{ "files": { "conf.d/test.conf": "object Host \"cmdb-host\" { chec_command = \"dummy\" }" } }' 'https://localhost:5665/v1/config/stages/example-cmdb' | python -m json.tool

    # curl -k -s -u root:icinga -X GET 'https://localhost:5665/v1/config/files/example-cmdb/icinga2-freebsd-1481141308-4/startup.log'
