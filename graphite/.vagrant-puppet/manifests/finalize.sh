#!/bin/bash

echo "Sleep 5 seconds and restart httpd for graphite."
sleep 5
/etc/init.d/httpd restart

echo "The Graphite Vagrant VM has finished installing. See http://localhost:8090/ for more details."

