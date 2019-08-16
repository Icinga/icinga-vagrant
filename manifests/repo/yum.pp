# PRIVATE CLASS: do not use directly
class influxdb::repo::yum(
  $ensure   = 'present',
  $enabled  = 1,
  $gpgcheck = 1,
) {

  $_operatingsystem = $::operatingsystem ? {
    'CentOS' => downcase($::operatingsystem),
    default  => 'rhel',
  }

  yumrepo { 'repos.influxdata.com':
    ensure   => $ensure,
    descr    => "InfluxDB Repository - ${::operatingsystem} \$releasever",
    baseurl  => "https://repos.influxdata.com/${$_operatingsystem}/\$releasever/\$basearch/stable",
    enabled  => $enabled,
    gpgcheck => $gpgcheck,
    gpgkey   => 'https://repos.influxdata.com/influxdb.key',
  }

}
