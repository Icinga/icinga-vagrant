# Class: kibana::config
#
# This class is called from kibana for service config.
#
class kibana::config {

  $_config_dir = $::kibana::repo_version ? {
    /^4[.]/ => '/opt/kibana/config',
    default => '/etc/kibana'
  }
  $_ensure = $::kibana::ensure ? {
    'absent' => $::kibana::ensure,
    default  => 'file',
  }
  $config = $::kibana::config

  file { "${_config_dir}/kibana.yml":
    ensure  => $_ensure,
    content => template("${module_name}/etc/kibana/kibana.yml.erb"),
  }
}
