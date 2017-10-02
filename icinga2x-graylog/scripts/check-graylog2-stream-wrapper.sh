#!/bin/bash

# WARNING: Maintained by Puppet!

# Quick & dirty script to fetch the first stream id from the Graylog2 server
# API. This is needed because the stream id changes each time the Vagrant box
# is provisioned.
# This is only useful for this Vagrant setup!!

set -e

USER=$(echo $@ | sed -re 's,.*-user (\S+).*,\1,')
PASS=$(echo $@ | sed -re 's,.*-password (\S+).*,\1,')
URL=$(echo $@ | sed -re 's,.*-url (\S+).*,\1,')

STREAM_ID=$(curl -s -u $USER:$PASS \
  "$URL/streams?pretty=true" | \
  fgrep '"id" :'| \
  head -1 | \
  sed -re 's/"id" : "(.+)",/\1/')

exec /usr/lib64/nagios/plugins/check-graylog2-stream "$@" -stream $STREAM_ID
