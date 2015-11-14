# == Class: grafana
#
# This class installs and configures grafana.
#
# === Parameters
#
# [*package_base*]
#   The base url for all packages.
#   Default is 'http://grafanarel.s3.amazonaws.com'
# [*version*]
#   Version of grafana to be installed.
#   Default is '1.9.1'
# [*install_dir*]
#   Install directory of grafana.
#   Default is '/opt'
# [*graphite_scheme*]
#   Scheme of graphite service.
#   Default is 'http'
# [*graphite_host*]
#   Hostname of graphite server.
#   Default is 'localhost'
# [*graphite_port*]
#   Port of graphite service.
#   Default is 80
# [*elasticsearch_scheme*]
#   Scheme of elasticsearch service.
#   Default is 'http'
# [*elasticsearch_host*]
#   Hostname of elasticsearch. You will need an elasticsearch
#   for saving dashboards
#   Default is '' (empty)
# [*elasticsearch_port*]
#   Port of elasticsearch service.
#   Default is 9200
# [*elasticsearch_index*]
#   Name of elasticsearch index.
#   Default is 'grafana-dash'
# [*opentsdb_scheme*]
#   Scheme of OpenTSDB service.
#   Default is 'http'
# [*opentsdb_host*]
#   Hostname of OpenTSDB.
#   Default is '' (empty)
# [*opentsdb_port*]
#   Port of OpenTSDB service.
#   Default is 4242
# [*influxdb_scheme*]
#   Scheme of influxdb.
#   Default is 'http'
# [*influxdb_host*]
#   Hostname of influxdb.
#   Default is '' (empty)
# [*influxdb_port*]
#   Port of influxdb.
#   Default is 8086
# [*influxdb_dbpath*]
#   DB path of influxdb.
#   Default is '/db/grafana'
# [*influxdb_user*]
#   Name of db user.
#   Default is 'grafana'
# [*influxdb_pass*]
#   Password of db user.
#   Default is 'grafana'
# [*timezone_offset*]
#   If you experiance problems with zoom, it is probably caused by timezone diff between
#   your browser and the graphite-web application. timezoneOffset setting can be used to have Grafana
#   translate absolute time ranges to the graphite-web timezone.
#   Example:
#     If TIME_ZONE in graphite-web config file local_settings.py is set to America/New_York, then set
#     timezoneOffset to "-0500" (for UTC - 5 hours)
#   Example:
#     If TIME_ZONE is set to UTC, set this to "0000"
#   Default is '0000'
# [*playlist_timespan*]
#   Playlist timespan.
#   Default is '1m'
# [*max_results*]
#   Specify the limit for dashboard search results.
#   Default is 20
# [*default_route*]
#   Default dashboard to route to.
#   Default is '/dashboard/file/default.json'
#
class grafana (
  $package_base          = 'http://grafanarel.s3.amazonaws.com',
  $version               = '1.9.1',
  $install_dir           = '/opt',
  $graphite_scheme       = 'http',
  $graphite_host         = 'localhost',
  $graphite_port         = 80,
  $elasticsearch_scheme  = 'http',
  $elasticsearch_host    = '',
  $elasticsearch_port    = 9200,
  $elasticsearch_index   = 'grafana-dash',
  $opentsdb_scheme       = 'http',
  $opentsdb_host         = '',
  $opentsdb_port         = 4242,
  $influxdb_scheme       = 'http',
  $influxdb_host         = '',
  $influxdb_port         = 8086,
  $influxdb_dbpath       = '/db/grafana',
  $influxdb_user         = 'grafana',
  $influxdb_pass         = 'grafana',
  $influxdb_grafana_user = 'grafana',
  $influxdb_grafana_pass = 'grafana',
  $timezone_offset       = '0000',
  $playlist_timespan     = '1m',
  $max_results           = 20,
  $default_route         = '/dashboard/file/default.json',
) {
  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  # The anchor resources allow the end user to establish relationships
  # to the "main" class and preserve the relationship to the
  # implementation classes through a transitive relationship to
  # the composite class.
  # https://projects.puppetlabs.com/projects/puppet/wiki/Anchor_Pattern
  anchor { 'grafana::begin': }->
  class { 'grafana::install': }->
  class { 'grafana::config': }->
  anchor { 'grafana::end': }
}
