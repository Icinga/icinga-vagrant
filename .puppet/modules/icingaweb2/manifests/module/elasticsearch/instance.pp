# == Define: icingaweb2::module::elasticsearch::instance
#
# Manage an Elasticsearch instance
#
# === Parameters
#
# [*name*]
#   Name of the Elasticsearch instance
#
# [*uri*]
#   URI to the Elasticsearch instance
#
# [*user*]
#   The user to use for authentication
#
# [*password*]
#   The password to use for authentication
#
# [*ca*]
#   The path of the file containing one or more certificates to verify the peer with or the path to the directory
#   that holds multiple CA certificates.
#
# [*client_certificate*]
#   The path of the client certificates
#
# [*client_private_key*]
#   The path of the client private key
#
#
define icingaweb2::module::elasticsearch::instance(
  String                         $uri                = undef,
  Optional[String]               $user               = undef,
  Optional[String]               $password           = undef,
  Optional[Stdlib::Absolutepath] $ca                 = undef,
  Optional[Stdlib::Absolutepath] $client_certificate = undef,
  Optional[Stdlib::Absolutepath] $client_private_key = undef,
){
  assert_private("You're not supposed to use this defined type manually.")

  $conf_dir        = $::icingaweb2::params::conf_dir
  $module_conf_dir = "${conf_dir}/modules/elasticsearch"

  $instance_settings = {
    'uri'                => $uri,
    'user'               => $user,
    'password'           => $password,
    'ca'                 => $ca,
    'client_certificate' => $client_certificate,
    'client_private_key' => $client_private_key,
  }

  icingaweb2::inisection { "elasticsearch-instance-${name}":
    section_name => $name,
    target       => "${module_conf_dir}/instances.ini",
    settings     => delete_undef_values($instance_settings)
  }
}