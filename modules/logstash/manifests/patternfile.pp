# == Define: logstash::patternfile
#
# This define allows you to transport custom pattern files to the Logstash instance
#
# All default values are defined in the logstashc::params class.
#
#
# === Parameters
#
# [*source*]
#   Puppet file resource of the pattern file ( puppet:// )
#   Value type is string
#   Default value: None
#   This variable is required
#
# [*filename*]
#   if you would like the actual file name to be different then the source file name
#   Value type is string
#   This variable is optional
#
#
# === Examples
#
#     logstash::patternfile { 'mypattern':
#       source => 'puppet:///path/to/my/custom/pattern'
#     }
#
#     or wil an other actual file name
#
#     logstash::patternfile { 'mypattern':
#       source   => 'puppet:///path/to/my/custom/pattern_v1',
#       filename => 'custom_pattern'
#     }
#
#
# === Authors
#
# * Justin Lambert
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
define logstash::patternfile (
  $source,
  $filename = undef,
)
{
  require logstash::config

  validate_re($source, '^(puppet|file)://', 'Source must be either from a puppet fileserver or a locally accessible file (begins with either puppet:// or file://)' )

  $filename_real = $filename ? {
    undef   => inline_template('<%= @source.split("/").last %>'),
    default => $filename
  }

  file { "${logstash::patterndir}/${filename_real}":
    ensure => file,
    source => $source,
    owner  => $logstash::logstash_user,
    group  => $logstash::logstash_group,
    mode   => '0644',
    tag    => ['logstash_config'],
  }
}
