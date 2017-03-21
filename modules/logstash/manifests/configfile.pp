# This type represents a Logstash pipeline configuration file.
#
# Parameters are mutually exclusive. Only one should be specified.
#
# @param [String] content
#  Literal content to be placed in the file.
#
# @param [String] template
#  A template from which to render the file.
#
# @param [String] source
#  A file resource to be used for the file.
#
# @example Create a config file content with literal content.
#
#   logstash::configfile { 'heartbeat':
#     content => 'input { heartbeat {} }',
#   }
#
# @example Render a config file from a template.
#
#   logstash::configfile { 'from-template':
#     template => 'site-logstash-module/pipeline-config.erb',
#   }
#
# @example Copy the config from a file source.
#
#   logstash::configfile { 'apache':
#     source => 'puppet://path/to/apache.conf',
#   }
#
# @author https://github.com/elastic/puppet-logstash/graphs/contributors
#
define logstash::configfile(
  $content = undef,
  $source = undef,
  $template = undef,
)
{
  include logstash

  $path = "${logstash::config_dir}/conf.d/${name}"
  $owner = $logstash::logstash_user
  $group = $logstash::logstash_group
  $mode ='0440'
  $require = Package['logstash'] # So that we have '/etc/logstash/conf.d'.
  $tag = [ 'logstash_config' ] # So that we notify the service.

  if($template)   { $config = template($template) }
  elsif($content) { $config = $content }

  if($config){
    file { $path:
      content => $config,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      require => $require,
      tag     => $tag,
    }
  }
  elsif($source){
    file { $path:
      source  => $source,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      require => $require,
      tag     => $tag,
    }
  }
}
