# == define: logstash::configfile
#
# This define is to manage the config files for Logstah
#
# === Parameters
#
# [*content*]
#  Supply content to be used for the config file. This can also be a template.
#
# [*source*]
#  Supply a puppet file resource to be used for the config file.
#
# [*order*]
#  The order number controls in which sequence the config file fragments are concatenated.
#
# === Examples
#
#     Set config file content with a literal value:
#
#     logstash::configfile { 'apache':
#       content => "",
#       order   => 10
#     }
#
#     or with a puppet file source:
#
#     logstash::configfile { 'apache':
#       source => 'puppet://path/to/apache.conf',
#       order  => 10
#     }
#
#     or with template (useful with Hiera):
#
#     logstash::configfile { 'apache':
#       template => "${module_name}/path/to/apache.conf.erb",
#       order   => 10
#     }
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
define logstash::configfile(
  $content = undef,
  $source = undef,
  $order = 10,
  $template = undef,
) {

  if ($template != undef ) {
    $config_content = template($template)
  }
  else {
    $config_content = $content
  }

  file_fragment { $name:
    tag     => "LS_CONFIG_${::fqdn}",
    content => $config_content,
    source  => $source,
    order   => $order,
    before  => [ File_concat['ls-config'] ],
  }
}
