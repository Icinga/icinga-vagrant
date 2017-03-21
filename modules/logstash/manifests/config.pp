# This class manages configuration directories for Logstash.
#
# @example Include this class to ensure its resources are available.
#   include logstash::config
#
# @author https://github.com/elastic/puppet-logstash/graphs/contributors
#
class logstash::config {
  require logstash::package

  # Configuration "fragment" directories for pipeline config and pattern files.
  # We'll keep these seperate since we may want to "purge" them. It's easy to
  # end up with orphan files when managing config fragments with Puppet.
  # Purging the directories resolves the problem.
  $fragment_directories = [
    "${logstash::config_dir}/conf.d",
    "${logstash::config_dir}/patterns",
  ]

  if($logstash::ensure == 'present') {
    file { $logstash::config_dir: ensure  => directory }

    file { $fragment_directories:
      ensure  => directory,
      purge   => $logstash::purge_config,
      recurse => $logstash::purge_config,
    }
  }
  elsif($logstash::ensure == 'absent') {
    # Completely remove the config directory. ie. 'rm -rf /etc/logstash'
    file { $logstash::config_dir:
      ensure  => 'absent',
      recurse => true,
      force   => true,
    }
  }

  File {
    owner => $logstash::logstash_user,
    group => $logstash::logstash_group,
  }
}
