include epel
include graphite

include iptables

# http
iptables::allow { 'tcp/22': port => '22', protocol => 'tcp' }
iptables::allow { 'tcp/80': port => '80', protocol => 'tcp' }
iptables::allow { 'tcp/443': port => '443', protocol => 'tcp' }

# graphite
iptables::allow { 'tcp/2003': port => '2003', protocol => 'tcp' }
iptables::allow { 'tcp/2004': port => '2004', protocol => 'tcp' }

exec { 'enable-graphite-realtime-refresh':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => 'sed -i \'s/var interval =.*/var interval = 1;/g\' /opt/graphite/webapp/content/js/composer_widgets.js',
  require => Anchor[graphite::end],
}
