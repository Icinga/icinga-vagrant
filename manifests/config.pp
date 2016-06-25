# == Class: logstash::config
#
# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'logstash::config': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class logstash::config {
  File {
    owner => $logstash::logstash_user,
    group => $logstash::logstash_group,
  }

  $notify_service = $logstash::restart_on_change ? {
    true  => Class['logstash::service'],
    false => undef,
  }

  if ( $logstash::ensure == 'present' ) {
    file { $logstash::configdir:
      ensure  => directory,
      purge   => $logstash::purge_configdir,
      recurse => $logstash::purge_configdir,
    }

    file { "${logstash::configdir}/conf.d":
      ensure  => directory,
      require => File[$logstash::configdir],
    }

    file_concat { 'ls-config':
      ensure  => 'present',
      tag     => "LS_CONFIG_${::fqdn}",
      path    => "${logstash::configdir}/conf.d/logstash.conf",
      owner   => $logstash::logstash_user,
      group   => $logstash::logstash_group,
      mode    => '0644',
      notify  => $notify_service,
      require => File[ "${logstash::configdir}/conf.d" ],
    }

    $directories = [
      $logstash::patterndir,
      $logstash::plugindir,
      "${logstash::plugindir}/logstash",
      "${logstash::plugindir}/logstash/inputs",
      "${logstash::plugindir}/logstash/outputs",
      "${logstash::plugindir}/logstash/filters",
      "${logstash::plugindir}/logstash/codecs",
    ]

    file { $directories:,
      ensure  => directory,
    }
  }
  elsif ( $logstash::ensure == 'absent' ) {
    file { $logstash::configdir:
      ensure  => 'absent',
      recurse => true,
      force   => true,
    }
  }
}
