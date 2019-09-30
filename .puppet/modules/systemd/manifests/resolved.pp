# **NOTE: THIS IS A [PRIVATE](https://github.com/puppetlabs/puppetlabs-stdlib#assert_private) CLASS**
#
# This class provides an abstract way to trigger resolved.
# Each parameters correspond to resolved.conf(5):
# https://www.freedesktop.org/software/systemd/man/resolved.conf.html
#
# @param ensure
#   The state that the ``resolved`` service should be in
#
# @param dns
#   A space-separated list of IPv4 and IPv6 addresses to use as system DNS servers.
#   DNS requests are sent to one of the listed DNS servers in parallel to suitable
#   per-link DNS servers acquired from systemd-networkd.service(8) or set at runtime
#   by external applications. requires puppetlabs-inifile
#
# @param fallback_dns
#   A space-separated list of IPv4 and IPv6 addresses to use as the fallback DNS
#   servers. Any per-link DNS servers obtained from systemd-networkd take
#   precedence over this setting. requires puppetlabs-inifile
#
# @param domains
#   A space-separated list of domains host names or IP addresses to be used
#   systemd-resolved take precedence over this setting.
#
# @param llmnr
#   Takes a boolean argument or "resolve".
#
# @param multicast_dns
#   Takes a boolean argument or "resolve".
#
# @param dnssec
#   Takes a boolean argument or "allow-downgrade".
#
# @param dnsovertls
#   Takes a boolean argument or "opportunistic" or "no"
#
# @param cache
#   Takes a boolean argument.
#
# @param dns_stub_listener
#   Takes a boolean argument or one of "udp" and "tcp".
#
# @param use_stub_resolver
#   Takes a boolean argument. When "false" (default) it uses /var/run/systemd/resolve/resolv.conf
#   as /etc/resolv.conf. When "true", it uses /var/run/systemd/resolve/stub-resolv.conf
#
class systemd::resolved (
  Enum['stopped','running'] $ensure                                  = $systemd::resolved_ensure,
  Optional[Variant[Array[String],String]] $dns                       = $systemd::dns,
  Optional[Variant[Array[String],String]] $fallback_dns              = $systemd::fallback_dns,
  Optional[Variant[Array[String],String]] $domains                   = $systemd::domains,
  Optional[Variant[Boolean,Enum['resolve']]] $llmnr                  = $systemd::llmnr,
  Optional[Variant[Boolean,Enum['resolve']]] $multicast_dns          = $systemd::multicast_dns,
  Optional[Variant[Boolean,Enum['allow-downgrade']]] $dnssec         = $systemd::dnssec,
  Optional[Variant[Boolean,Enum['opportunistic', 'no']]] $dnsovertls = $systemd::dnsovertls,
  Boolean $cache                                                     = $systemd::cache,
  Optional[Variant[Boolean,Enum['udp', 'tcp']]] $dns_stub_listener   = $systemd::dns_stub_listener,
  Boolean $use_stub_resolver                                         = $systemd::use_stub_resolver,
){

  assert_private()

  $_enable_resolved = $ensure ? {
    'stopped' => false,
    'running' => true,
    default   => $ensure,
  }

  service { 'systemd-resolved':
    ensure => $ensure,
    enable => $_enable_resolved,
  }

  $_resolv_conf_target = $use_stub_resolver ? {
    true    => '/run/systemd/resolve/stub-resolv.conf',
    default => '/run/systemd/resolve/resolv.conf',
  }
  file { '/etc/resolv.conf':
    ensure  => 'symlink',
    target  => $_resolv_conf_target,
    require => Service['systemd-resolved'],
  }

  if $dns {
    if $dns =~ String {
      $_dns = $dns
    } else {
      $_dns = join($dns, ' ')
    }
    ini_setting{ 'dns':
      ensure  => 'present',
      value   => $_dns,
      setting => 'DNS',
      section => 'Resolve',
      path    => '/etc/systemd/resolved.conf',
      notify  => Service['systemd-resolved'],
    }
  }

  if $fallback_dns {
    if $fallback_dns =~ String {
      $_fallback_dns = $fallback_dns
    } else {
      $_fallback_dns = join($fallback_dns, ' ')
    }
    ini_setting{ 'fallback_dns':
      ensure  => 'present',
      value   => $_fallback_dns,
      setting => 'FallbackDNS',
      section => 'Resolve',
      path    => '/etc/systemd/resolved.conf',
      notify  => Service['systemd-resolved'],
    }
  }

  if $domains {
    if $domains =~ String {
      $_domains = $domains
    } else {
      $_domains = join($domains, ' ')
    }
    ini_setting{ 'domains':
      ensure  => 'present',
      value   => $_domains,
      setting => 'Domains',
      section => 'Resolve',
      path    => '/etc/systemd/resolved.conf',
      notify  => Service['systemd-resolved'],
    }
  }

  $_llmnr = $llmnr ? {
    true    => 'yes',
    false   => 'no',
    default => $llmnr,
  }

  if $_llmnr {
    ini_setting{ 'llmnr':
      ensure  => 'present',
      value   => $_llmnr,
      setting => 'LLMNR',
      section => 'Resolve',
      path    => '/etc/systemd/resolved.conf',
      notify  => Service['systemd-resolved'],
    }
  }

  $_multicast_dns = $multicast_dns ? {
    true    => 'yes',
    false   => 'no',
    default => $multicast_dns,
  }

  if $_multicast_dns {
    ini_setting{ 'multicast_dns':
      ensure  => 'present',
      value   => $_multicast_dns,
      setting => 'MulticastDNS',
      section => 'Resolve',
      path    => '/etc/systemd/resolved.conf',
      notify  => Service['systemd-resolved'],
    }
  }

  $_dnssec = $dnssec ? {
    true    => 'yes',
    false   => 'no',
    default => $dnssec,
  }

  if $_dnssec {
    ini_setting{ 'dnssec':
      ensure  => 'present',
      value   => $_dnssec,
      setting => 'DNSSEC',
      section => 'Resolve',
      path    => '/etc/systemd/resolved.conf',
      notify  => Service['systemd-resolved'],
    }
  }

  $_dnsovertls = $dnsovertls ? {
    true    => 'opportunistic',
    false   => false,
    default => $dnsovertls,
  }

  if $_dnsovertls {
    ini_setting{ 'dnsovertls':
      ensure  => 'present',
      value   => $_dnsovertls,
      setting => 'DNSOverTLS',
      section => 'Resolve',
      path    => '/etc/systemd/resolved.conf',
      notify  => Service['systemd-resolved'],
    }
  }

  $_cache = $cache ? {
    true    => 'yes',
    false   => 'no',
  }

  if $cache {
    ini_setting{ 'cache':
      ensure  => 'present',
      value   => $_cache,
      setting => 'Cache',
      section => 'Resolve',
      path    => '/etc/systemd/resolved.conf',
      notify  => Service['systemd-resolved'],
    }
  }

  $_dns_stub_listener = $dns_stub_listener ? {
    true    => 'yes',
    false   => 'no',
    default => $dns_stub_listener,
  }

  if $_dns_stub_listener {
    ini_setting{ 'dns_stub_listener':
      ensure  => 'present',
      value   => $_dns_stub_listener,
      setting => 'DNSStubListener',
      section => 'Resolve',
      path    => '/etc/systemd/resolved.conf',
      notify  => Service['systemd-resolved'],
    }
  }

}
