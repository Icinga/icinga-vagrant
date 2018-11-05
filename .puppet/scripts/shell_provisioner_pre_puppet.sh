#!/bin/bash

set -e

SSH_IP="$1"
HOSTNAME=`hostname -f`
HIERA_NODE_PATH="/hieradata/node/${HOSTNAME}.yaml"

if [[ $HOSTNAME == *.icinga.com ]]; then
  echo "Local Vagrant box detected, using defaults from ${HIERA_NODE_PATH}."
else
  echo "OpenStack SSH IP address detected: ${SSH_IP} for hostname ${HOSTNAME}"
  echo "Patching Hiera for Puppet provisioner in ${HIERA_NODE_PATH}."
  # Node specific IP address override
  echo "node::ipaddress:        \"${SSH_IP}\"" > ${HIERA_NODE_PATH}
  # Node local node_name override, not FQDN
  echo "icinga::icinga2::node_name: \"${HOSTNAME}\"" >> ${HIERA_NODE_PATH}
fi

