# puppet-iptables

Manage iptables incoming rules

The recommended usage is to place the configuration under an iptables hash in
hiera and just include the iptables module in your puppet configuration:

    include iptables

Example hiera config:

    iptables::allow_icmp: 'yes'
    iptables::allow_localhost: 'yes'
    iptables::log_failures: 'yes'
    iptables::ports:
      22:
        tcp: 'allow'
      80:
        tcp: 'allow'
      23:
        tcp: 'drop'
        udp: 'drop'

This example configures iptables to allow incoming TCP connections to ports 22
(ssh) and 80 (http), and silently drop all connections to port 23 (telnet).
All ICMP and localhost connections will be allowed and failed connections to
other ports will be logged to syslog.

Notes:

* The default policy is to deny all connections and log failures to syslog
  (usually /var/log/messages).

* To allow connections to a particular port add an allow rule like that for
  port 80 above.

* To avoid denied connections to a particular port being logged add a drop rule
  like that for port 23 above.

* To avoid any failed connections being logged set the log_failures parameter
  to 'no'.

* By default all ICMP traffic is allowed.  Set allow_icmp to 'no' to change
  this.

* By default all localhost traffic is allowed.  Set allow_localhost to 'no' to
  change this.

* If no iptables configuration is found then an allow rule is added for tcp/22
  (ssh) like the default iptables configuration.

* If there is both an allow rule and a drop rule for a port and protocol then
  access is allowed.

## Parameters

* *logfailures*: whether or not to log failed connections that are not explicitly dropped. Possible values: 'yes' or 'no'. Default: 'yes'

* *allow_icmp*: whether or not to allow all ICMP traffic. Possible values: 'yes' or 'no'. Default: 'yes'

* *allow_localhost*: whether or not to allow all localhost (127.0.0.0/8) traffic. Possible values: 'yes' or 'no'. Default: 'yes'

* *ports* hash:

    * *<port number>* hash: the port number to add a rule for (eg. 22)
        * 'tcp': Possible values are 'allow' or 'drop'.
        * 'udp': Possible values are 'allow' or 'drop'.

## Implementation

The iptables::allow and iptables::drop resources create files under
/root/iptables.d with a filename including the action (allow or drop), the
protocol (tcp or udp) and the port number.  Creating these files triggers an
update script that combines all the entries together into a new
/etc/sysconfig/iptables file and restarts the iptables service.

The iptables::clean class removes all files under /root/iptables.d.

## iptables::allow

Allow access to the specified port.

*port*: the incoming port number. Required.

*protocol*: either 'tcp' or 'udp'. Required.

Example:

    iptables::allow { 'tcp/22': port => '22', protocol => 'tcp' }

## iptables::drop

Deny access to the specified port without logging.

*port*: the incoming port number. Required.

*protocol*: either 'tcp' or 'udp'. Required.

Example:

    iptables::drop { 'tcp/21': port => '21', protocol => 'tcp' }

## iptables::clean

Remove all files under /root/iptables.d.  This has the effect of starting with
a clean configuration and is required if you want to remove rules for ports
defined previously.

To use just temporarily:

    include iptables::clean

in a host configuration.

## Support

License: Apache License, Version 2.0

GitHub URL: https://github.com/erwbgy/puppet-iptables
