#!/usr/bin/python
# This script uses libsemanage directly to access the ports list
# it is *much* faster than semanage port -l

# will work with python 2.6+
from __future__ import print_function
from sys import exit
try:
  import semanage
except ImportError:
  # The semanage python library does not exist, so let's assume SELinux is disabled...
  # In this case, the correct response is to return no ports when puppet does a
  # prefetch, to avoid an error. We depend on the semanage binary anyway, which
  # is uses the library
  exit(0)


handle = semanage.semanage_handle_create()

if semanage.semanage_is_managed(handle) < 0:
    exit(1)
if semanage.semanage_connect(handle) < 0:
    exit(1)

def print_port(kind, port):
    con = semanage.semanage_port_get_con(port)
    con_str = semanage.semanage_context_to_string(handle, con)
    high = semanage.semanage_port_get_high(port)
    low = semanage.semanage_port_get_low(port)
    proto = semanage.semanage_port_get_proto(port)
    proto_str = semanage.semanage_port_get_proto_str(proto)
    print(kind, con_str[1], high, low, proto_str)

# Always list local ports afterwards so that the provider works correctly
retval, ports = semanage.semanage_port_list(handle)

for port in ports:
    print_port('policy', port)

retval, ports = semanage.semanage_port_list_local(handle)

for port in ports:
    print_port('local', port)

semanage.semanage_disconnect(handle)
semanage.semanage_handle_destroy(handle)
