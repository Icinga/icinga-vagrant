# This type represents a Grok pattern file for Logstash.
#
# @param [String] source
#   File source for the pattern file. eg. `puppet://[...]` or `file://[...]`
#
# @param [String] filename
#   Optionally set the destination filename.
#
# @example Define a pattern file.
#   logstash::patternfile { 'mypattern':
#     source => 'puppet:///path/to/my/custom/pattern'
#   }
#
# @example Define a pattern file with an explicit destination filename.
#   logstash::patternfile { 'mypattern':
#     source   => 'puppet:///path/to/my/custom/pattern',
#     filename => 'custom-pattern-name'
#   }
#
# @author https://github.com/elastic/puppet-logstash/graphs/contributors
#
define logstash::patternfile (
  Pattern[/^(puppet|file):\/\//] $source   = undef,
  Optional[String[1]]            $filename = undef,
) {
  require logstash::config

  $destination = pick($filename, basename($source))

  file { "${logstash::config_dir}/patterns/${destination}":
    ensure => file,
    source => $source,
    owner  => 'root',
    group  => $logstash::logstash_group,
    mode   => '0640',
    tag    => ['logstash_config'],
  }
}
