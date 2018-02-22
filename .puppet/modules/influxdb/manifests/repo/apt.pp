# PRIVATE CLASS: do not use directly

class influxdb::repo::apt(
  $ensure = 'present',
) {

  #downcase operatingsystem
  $_operatingsystem = downcase($::operatingsystem)

  $key = {
    'id'     => '05CE15085FC09D18E99EFB22684A14CF2582E0C5',
    'source' => 'https://repos.influxdata.com/influxdb.key',
  }

  $include = {
    'src' => false,
  }

  apt::source { 'repos.influxdata.com':
    ensure   => $ensure,
    location => "https://repos.influxdata.com/${_operatingsystem}",
    release  => $::lsbdistcodename,
    repos    => 'stable',
    key      => $key,
    include  => $include,
  }

}
