# **NOTE: THIS IS A [PRIVATE](https://github.com/puppetlabs/puppetlabs-stdlib#assert_private) CLASS**
#
# This class provides an abstract way to trigger systemd-timesyncd
#
# @param ensure
#   The state that the ``networkd`` service should be in
#
# @param $ntp_server
#   A space-separated list of NTP servers, will be combined with interface specific
#   addresses from systemd-networkd. requires puppetlabs-inifile
#
# @param fallback_ntp_server
#   A space-separated list of NTP server host names or IP addresses to be used
#   as the fallback NTP servers. Any per-interface NTP servers obtained from
#   systemd-networkd take precedence over this setting. requires puppetlabs-inifile
class systemd::timesyncd (
  Enum['stopped','running'] $ensure                    = $systemd::timesyncd_ensure,
  Optional[Variant[Array,String]] $ntp_server          = $systemd::ntp_server,
  Optional[Variant[Array,String]] $fallback_ntp_server = $systemd::fallback_ntp_server,
){

  assert_private()

  $_enable_timesyncd = $ensure ? {
    'stopped' => false,
    'running' => true,
    default   => $ensure,
  }

  service{ 'systemd-timesyncd':
    ensure => $ensure,
    enable => $_enable_timesyncd,
  }

  if $ntp_server {
    if $ntp_server =~ String {
      $_ntp_server = $ntp_server
    } else {
      $_ntp_server = join($ntp_server, ' ')
    }
    ini_setting{'ntp_server':
      ensure  => 'present',
      value   => $_ntp_server,
      setting => 'NTP',
      section => 'Time',
      path    => '/etc/systemd/timesyncd.conf',
      notify  => Service['systemd-timesyncd'],
    }
  }

  if $fallback_ntp_server {
    if $fallback_ntp_server =~ String {
      $_fallback_ntp_server = $fallback_ntp_server
    } else {
      $_fallback_ntp_server = join($fallback_ntp_server, ' ')
    }
    ini_setting{'fallback_ntp_server':
      ensure  => 'present',
      value   => $_fallback_ntp_server,
      setting => 'FallbackNTP',
      section => 'Time',
      path    => '/etc/systemd/timesyncd.conf',
      notify  => Service['systemd-timesyncd'],
    }
  }
}
