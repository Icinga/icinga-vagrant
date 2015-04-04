# == Class: graphite
#
# This class installs and configures graphite/carbon/whisper.
#
# === Parameters
#
# [*gr_user*]
#   The user who runs graphite. If this is empty carbon runs as the user that invokes it.
#   Default is empty.
# [*gr_max_cache_size*]
#   Limit the size of the cache to avoid swapping or becoming CPU bound. Use the value "inf" (infinity) for an unlimited cache size.
#   Default is inf.
# [*gr_max_updates_per_second*]
#   Limits the number of whisper update_many() calls per second, which effectively means the number of write requests sent to the disk.
#   Default is 500.
# [*gr_max_creates_per_minute*]
#   Softly limits the number of whisper files that get created each minute.
#   Default is 50.
# [*gr_line_receiver_interface*]
#   Interface the line receiver listens.
#   Default is 0.0.0.0
# [*gr_line_receiver_port*]
#   Port of line receiver.
#   Default is 2003
# [*gr_enable_udp_listener*]
#   Set this to True to enable the UDP listener.
#   Default is False.
# [*gr_udp_receiver_interface*]
#   Its clear, isnt it?
#   Default is 0.0.0.0
# [*gr_udp_receiver_port*]
#   Self explaining.
#   Default is 2003
# [*gr_pickle_receiver_interface*]
#   Pickle is a special receiver who handle tuples of data.
#   Default is 0.0.0.0
# [*gr_pickle_receiver_port*]
#   Self explaining.
#   Default is 2004
# [*gr_use_insecure_unpickler*]
#   Set this to True to revert to the old-fashioned insecure unpickler.
#   Default is False.
# [*gr_cache_query_interface*]
#   Interface to send cache queries to.
#   Default is 0.0.0.0
# [*gr_cache_query_port*]
#   Self explaining.
#   Default is 7002.
# [*gr_timezone*]
#   Timezone for graphite to be used.
#   Default is GMT.
# [*gr_storage_schemas*]
#  The storage schemas.
#  Default is [{name => "default", pattern => ".*", retentions => "1s:30m,1m:1d,5m:2y"}]
# [*gr_web_server*]
#   The web server to use.
#   Valid values are 'apache' and 'nginx'. 'nginx' is only supported on
#   Debian-like systems.
#   Default is 'apache'.
# [*gr_apache_port*]
#   The port to run web server on if you have an existing web server on the default
#   port 80.
#   Default is 80.
# [*gr_django_1_4_or_less*]
#   Set to true to use old Django settings style.
#   Default is false.
# [*gr_django_db_xxx*]
#   Django database settings. (engine|name|user|password|host|port)
#   Default is a local sqlite3 db.
# [*secret_key*]
#   Secret used as salt for things like hashes, cookies, sessions etc.
#   Has to be the same on all nodes of a graphite cluster.
#   Default is UNSAFE_DEFAULT (CHANGE IT!)
# [*nginx_htpasswd*]
#   The user and salted SHA-1 (SSHA) password for Nginx authentication.
#   If set, Nginx will be configured to use HTTP Basic authentication with the
#   given user & password.
#   Default is undefined


# === Examples
#
# class {'graphite':
#   gr_max_cache_size      => 256,
#   gr_enable_udp_listener => True,
#   gr_timezone            => 'Europe/Berlin'
# }
#
class graphite (
  $gr_user                      = '',
  $gr_max_cache_size            = inf,
  $gr_max_updates_per_second    = inf,
  $gr_max_creates_per_minute    = inf,
  $gr_line_receiver_interface   = '0.0.0.0',
  $gr_line_receiver_port        = 2003,
  $gr_enable_udp_listener       = 'False',
  $gr_udp_receiver_interface    = '0.0.0.0',
  $gr_udp_receiver_port         = 2003,
  $gr_pickle_receiver_interface = '0.0.0.0',
  $gr_pickle_receiver_port      = 2004,
  $gr_use_insecure_unpickler    = 'False',
  $gr_cache_query_interface     = '0.0.0.0',
  $gr_cache_query_port          = 7002,
  $gr_timezone                  = 'Europe/Berlin',
  $gr_storage_schemas           = [
    {
      name       => 'carbon',
      priority   => '100',
      pattern    => '^carbon\.',
      retentions => '1m:90d'
    },
    {
      name       => 'icinga',
      priority   => '200',
      pattern    => '^icinga\.',
      retentions => '1s:12h'
    },
    {
      name       => 'default',
      priority   => '10',
      pattern    => '.*',
      retentions => '1s:30m,1m:1d,5m:2y'
    }
  ],
  $gr_web_server                = 'apache',
  $gr_apache_port               = 80,
  $gr_apache_port_https         = 443,
  $gr_django_1_4_or_less        = false,
  $gr_django_db_engine          = 'django.db.backends.sqlite3',
  $gr_django_db_name            = '/opt/graphite/storage/graphite.db',
  $gr_django_db_user            = '',
  $gr_django_db_password        = '',
  $gr_django_db_host            = '',
  $gr_django_db_port            = '',
  $secret_key                   = 'UNSAFE_DEFAULT',
  $nginx_htpassword             = undef,
) {

	class { 'graphite::install': notify => Class['graphite::config'], }

	class { 'graphite::config':	require => Class['graphite::install'], }

	# Allow the end user to establish relationships to the "main" class
	# and preserve the relationship to the implementation classes through
	# a transitive relationship to the composite class.
	anchor { 'graphite::begin': before => Class['graphite::install'] }
	anchor { 'graphite::end':  require => Class['graphite::config'] }
}
