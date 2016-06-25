# Manage the installation of a Logstash plugin.
#
# By default, plugins are downloaded from RubyGems, but it is also possible
# to install from a local Gem, or one stored in Puppet.
#
# @example install a plugin
#   logstash::plugin { 'logstash-input-stdin': }
#
# @example remove a plugin
#   logstash::plugin { 'logstash-input-stout':
#     ensure => absent,
#   }
#
# @example install a plugin from a local file
#   logstash::plugin { 'logstash-input-custom':
#     source => 'file:///tmp/logstash-input-custom.gem',
#   }
#
# @example install a plugin from a Puppet module.
#   logstash::plugin { 'logstash-input-custom':
#     source => 'puppet:///modules/logstash-site-plugins/logstash-input-custom.gem',
#   }
#
# @param source [String] install from this file, not from RubyGems.
#
define logstash::plugin (
  $source = undef,
  $ensure = present,
)
{
  require logstash::package
  $exe = '/opt/logstash/bin/plugin'

  case $source { # Where should we get the plugin from?
    undef: {
      # No explict source, so search Rubygems for the plugin, by name.
      # ie. "/opt/logstash/bin/plugin install logstash-output-elasticsearch"
      $plugin = $name
    }

    /^\//: {
      # A gem file that is already available on the local filesystem.
      # Install from the local path.
      # ie. "/opt/logstash/bin/plugin install /tmp/logtash-filter-custom.gem"
      $plugin = $source
    }

    /^puppet:/: {
      # A 'puppet:///' URL. Download the gem from Puppet, then install
      # the plugin from the downloaded file.
      $downloaded_file = sprintf('/tmp/%s', basename($source))
      file { $downloaded_file:
        source => $source,
        before => Exec["install-${name}"],
      }
      $plugin = $downloaded_file
    }

    default: {
      fail('"source" should be a local path, a "puppet:///" url, or undef.')
    }
  }

  case $ensure {
    'present': {
      exec { "install-${name}":
        command => "${exe} install ${plugin}",
        unless  => "${exe} list | grep -q ^${name}$",
        timeout => 1800,
      }
    }

    'absent': {
      notify { "${exe} list | grep -q ^${name}$": } ->
      exec { "remove-${name}":
        command => "${exe} uninstall ${name}",
        onlyif  => "${exe} list | grep -q ^${name}$",
        timeout => 1800,
      }
    }

    default: {
      fail "'ensure' should be 'present' or 'absent'."
    }
  }
}
