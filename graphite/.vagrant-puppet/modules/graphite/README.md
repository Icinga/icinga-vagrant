# Module graphite

This module installs and makes basic configs for graphite, with carbon and whisper.

# Tested on
RHEL/CentOS/Scientific 6+
Debian 6+
Ubunutu 10.04 and newer

# Requirements

Configure conf files as you need:

templates/opt/graphite/conf/storage-schemas.conf.erb
templates/opt/graphite/webapp/graphite/local_settings.py.erb

### Modules needed:

stdlib by puppetlabs

### Software versions needed:
facter > 1.6.2
puppet > 2.6.2

On Redhat distributions you need the EPEL or RPMforge repository, because Graphite needs packages, which are not part of the default repos.

# Parameters

The descriptions are short and their are more variables to tweak your graphite if needed.
For further information take a look at the file templates/opt/graphite/conf/carbon.conf.erb

<table>
  <tr>
  	<th>Parameter</th><th>Default</th><th>Description</th>
  </tr>
  <tr>
    <td>gr_user</td><td> its empty </td><td>The user who runs graphite. If this is empty carbon runs as the user that invokes it.</td>
  </tr>
  <tr>
    <td>gr_max_cache_size</td><td>inf</td><td>Limit the size of the cache to avoid swapping or becoming CPU bound. Use the value "inf" (infinity) for an unlimited cache size.</td>
  </tr>
  <tr>
    <td>gr_max_updates_per_second</td><td>500</td><td>Limits the number of whisper update_many() calls per second, which effectively means the number of write requests sent to the disk.</td>
  </tr>
  <tr>
    <td>gr_max_creates_per_minute</td><td>50</td><td>Softly limits the number of whisper files that get created each minute.</td>
  </tr>
  <tr>
    <td>gr_line_receiver_interface</td><td>0.0.0.0</td><td>Interface the line receiver listens</td>
  </tr>
  <tr>
    <td>gr_line_receiver_port</td><td>2003</td><td>Port of line receiver</td>
  </tr>
  <tr>
    <td>gr_enable_udp_listener</td><td>False</td><td>Set this to True to enable the UDP listener.</td>
  </tr>
  <tr>
    <td>gr_udp_receiver_interface</td><td>0.0.0.0</td><td>Its clear, isnt it?</td>
  </tr>
  <tr>
    <td>gr_udp_receiver_port</td><td>2003</td><td>Self explaining</td>
  </tr>
  <tr>
    <td>gr_pickle_receiver_interface</td><td>0.0.0.0</td><td>Pickle is a special receiver who handle tuples of data.</td>
  </tr>
  <tr>
    <td>gr_pickle_receiver_port</td><td>2004</td><td>Self explaining</td>
  </tr>
  <tr>
    <td>gr_use_insecure_unpickler</td><td>False</td><td>Set this to True to revert to the old-fashioned insecure unpickler.</td>
  </tr>
  <tr>
    <td>gr_cache_query_interface</td><td>0.0.0.0</td><td>Interface to send cache queries to.</td>
  </tr>
  <tr>
    <td>gr_cache_query_port</td><td>7002</td><td>Self explaining.</td>
  </tr>
  <tr>
    <td>gr_storage_schemas</td><td><pre>[
  {
    name       => "default",
    pattern    => ".*",
    retentions => "1s:30m,1m:1d,5m:2y"
  }
]</pre></td><td>The storage schemas.</td>
  </tr>
  <tr>
    <td>gr_apache_port</td><td>80</td><td>The HTTP port apache will use.</td>
  </tr>
  <tr>
    <td>gr_apache_port_https</td><td>443</td><td>The HTTPS port apache will use.</td>
  </tr>
  <tr>
    <td>gr_django_1_4_or_less</td><td>false</td><td>Django settings style.</td>
  </tr>
  <tr>
    <td>gr_django_db_xxx</td><td>sqlite3 settings</td><td>Django database settings. (engine|name|user|password|host|port)</td>
  </tr>
  <tr>
    <td>secret_key</td><td>UNSAFE_DEFAULT</td><td>CHANGE IT! Secret used as salt for things like hashes, cookies, sessions etc. Has to be the same on all nodes of a graphite cluster.</td>
  </tr>
</table>

# Sample usage:

### Out of the box graphite installation
<pre>
node "graphite.my.domain" {
	include graphite
}
</pre>

### Tuned graphite installation

<pre>

# This carbon cache will accept TCP and UDP datas and
# the cachesize is limited to 256mb
node "graphite.my.domain" {
	class {'graphite':
		gr_max_cache_size => 256,
		gr_enable_udp_listener => True
	}
}
</pre>

## Optional

### Move Apache to alternative ports:

The default puppet set up won't work if you have an existing web server in
place. In my case this was Nginx. For me moving apache off to another port was
good enough. To allow this you do

<pre>

  # Move apache to alternate HTTP/HTTPS ports:
node "graphite.my.domain" {
    class {'graphite':
        gr_apache_port => 2080,
        gr_apache_port_https => 2443,
    }
}

</pre>


# Author

written by Daniel Werdermann dwerdermann@web.de

# Contributers

 * Oisin Mulvihill, oisin dot mulvihill at gmail dot com.