# PRIVATE CLASS: do not use directly
class influxdb::repo::yum {

  $_operatingsystem = $::operatingsystem ? {
    'CentOS' => downcase($::operatingsystem),
    default  => 'rhel',
  }

  yumrepo { 'repos.influxdata.com':
    descr    => "InfluxDB Repository - ${::operatingsystem} \$releasever",
    baseurl  => "https://repos.influxdata.com/${$_operatingsystem}/\$releasever/\$basearch/stable",
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'https://repos.influxdata.com/influxdb.key',
  }

  Yumrepo['repos.influxdata.com'] -> Package<| tag == 'influxdb' |>
}
