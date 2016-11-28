# == Class: logstash::service
#
# This class exists to coordinate all service management related actions,
# functionality and logical units in a central place.
#
# <b>Note:</b> "service" is the Puppet term and type for background processes
# in general and is used in a platform-independent way. E.g. "service" means
# "daemon" in relation to Unix-like systems.
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
#   class { 'logstash::service': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# https://github.com/elastic/puppet-logstash/graphs/contributors
#
class logstash::service {
  $default_startup_options = {
    'JAVACMD'             => '/usr/bin/java',
    'LS_HOME'             => '/usr/share/logstash',
    'LS_SETTINGS_DIR'     => '/etc/logstash',
    'LS_OPTS'             => '"--path.settings ${LS_SETTINGS_DIR}"',
    'LS_JAVA_OPTS'        => '""',
    'LS_PIDFILE'          => '/var/run/logstash.pid',
    'LS_USER'             => $logstash::logstash_user,
    'LS_GROUP'            => $logstash::logstash_group,
    'LS_GC_LOG_FILE'      => '/var/log/logstash/gc.log',
    'LS_OPEN_FILES'       => '16384',
    'LS_NICE'             => '19',
    'SERVICE_NAME'        => '"logstash"',
    'SERVICE_DESCRIPTION' => '"logstash"',
  }

  $startup_options = merge($default_startup_options, $logstash::startup_options)

  if $logstash::ensure == 'present' {
    case $logstash::status {
      'enabled': {
        $service_ensure = 'running'
        $service_enable = true
      }
      'disabled': {
        $service_ensure = 'stopped'
        $service_enable = false
      }
      'running': {
        $service_ensure = 'running'
        $service_enable = false
      }
      default: {
        fail("\"${logstash::status}\" is an unknown service status value")
      }
    }
  } else {
    $service_ensure = 'stopped'
    $service_enable = false
  }

  if $service_ensure == 'running' {
    # Then make sure the Logstash startup options are up to date.
    file {'/etc/logstash/startup.options':
      content => template('logstash/startup.options.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0664',
    }
    ~>
    # Invoke 'system-install', which generates startup scripts based on the
    # contents of the 'startup.options' file.
    exec { '/usr/share/logstash/bin/system-install':
      refreshonly => true,
      notify      => Service['logstash'],
    }
  }

  # Puppet 3 doesn't know that Debian 8 uses systemd, not SysV init,
  # so we'll help it out with our knowledge from the future.
  if($::operatingsystem == 'debian' and $::operatingsystemmajrelease == '8'){
    $service_provider = 'systemd'
  }
  else {
    # In most cases, Puppet can figure out the correct service
    # provider on its own, so we'll just say 'undef', and let it do
    # whatever it thinks is best.
    $service_provider = undef
  }

  service { 'logstash':
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasstatus  => true,
    hasrestart => true,
    provider   => $service_provider,
  }

  # If any files tagged as config files for the service are changed, notify
  # the service so it restarts.
  if $::logstash::restart_on_change {
    File<| tag == 'logstash_config' |> ~> Service['logstash']
    Logstash::Plugin<| |> ~> Service['logstash']
  }
}
