# == Define: docker:run
#
# A define which manages a running docker container.
#
# == Parameters
#
# [*restart*]
# Sets a restart policy on the docker run.
# Note: If set, puppet will NOT setup an init script to manage, instead
# it will do a raw docker run command using a CID file to track the container
# ID.
#
# If you want a normal named container with an init script and a restart policy
# you must use the extra_parameters feature and pass it in like this:
#
#    extra_parameters => ['--restart=always']
#
# However, if your system is using sytemd this restart policy will be
# ineffective because the ExecStop commands will run which will cause
# docker to stop restarting it.  In this case you should use the
# systemd_restart option to specify the policy you want.
#
# This will allow the docker container to be restarted if it dies, without
# puppet help.
#
# [*service_prefix*]
#   (optional) The name to prefix the startup script with and the Puppet
#   service resource title with.  Default: 'docker-'
#
# [*restart_service*]
#   (optional) Whether or not to restart the service if the the generated init
#   script changes.  Default: true
#
# [*restart_service_on_docker_refresh*]
#   Whether or not to restart the service if the docker service is restarted.
#   Only has effect if the docker_service parameter is set.
#   Default: true
#
# [*manage_service*]
#  (optional) Whether or not to create a puppet Service resource for the init
#  script.  Disabling this may be useful if integrating with existing modules.
#  Default: true
#
# [*docker_service*]
#  (optional) If (and how) the Docker service itself is managed by Puppet
#  true          -> Service['docker']
#  false         -> no Service dependency
#  anything else -> Service[docker_service]
#  Default: false
#
# [*health_check_cmd*]
# (optional) Specifies the command to execute to check that the container is healthy using the docker health check functionality.
# Default: undef
#
# [*health_check_interval*]
# (optional) Specifies the interval that the health check command will execute in seconds.
# Default: undef
#
# [*restart_on_unhealthy*]
# (optional) Checks the health status of Docker container and if it is unhealthy the service will be restarted.
# The health_check_cmd parameter must be set to true to use this functionality.
# Default: undef
#
# [*net*]
#
# The docker network to attach to a container.
# Can be a String or Array (if using multiple networks)
# Default: bridge
#
# [*extra_parameters*]
# An array of additional command line arguments to pass to the `docker run`
# command. Useful for adding additional new or experimental options that the
# module does not yet support.
#
# [*systemd_restart*]
# (optional) If the container is to be managed by a systemd unit file set the
# Restart option on the unit file.  Can be any valid value for this systemd
# configuration.  Most commonly used are on-failure or always.
# Default: on-failure
#
# [*custom_unless*]
# (optional) Specify an additional unless for the Docker run command when using restart.
# Default: undef
#
# [*after_create*]
# (optional) Specifies the command to execute after container is created but before it is started.
# Default: undef
#
# [*remain_after_exit*]
# (optional) If the container is to be managed by a systemd unit file set the
# RemainAfterExit option on the unit file.  Can be any valid value for this systemd
# configuration.
# Default: Not included in unit file
#
define docker::run(
  Optional[Pattern[/^[\S]*$/]] $image,
  Optional[Pattern[/^present$|^absent$/]] $ensure       = 'present',
  Optional[String] $command                             = undef,
  Optional[Pattern[/^[\d]*(b|k|m|g)$/]] $memory_limit   = '0b',
  Variant[String,Array,Undef] $cpuset                   = [],
  Variant[String,Array,Undef] $ports                    = [],
  Variant[String,Array,Undef] $labels                   = [],
  Variant[String,Array,Undef] $expose                   = [],
  Variant[String,Array,Undef] $volumes                  = [],
  Variant[String,Array,Undef] $links                    = [],
  Optional[Boolean] $use_name                           = false,
  Optional[Boolean] $running                            = true,
  Variant[String,Array,Undef] $volumes_from             = [],
  Variant[String,Array] $net                            = 'bridge',
  Variant[String,Boolean] $username                     = false,
  Variant[String,Boolean] $hostname                     = false,
  Variant[String,Array,Undef] $env                      = [],
  Variant[String,Array,Undef] $env_file                 = [],
  Variant[String,Array,Undef] $dns                      = [],
  Variant[String,Array,Undef] $dns_search               = [],
  Variant[String,Array,Undef] $lxc_conf                 = [],
  Optional[String] $service_prefix                      = 'docker-',
  Optional[String] $service_provider                    = undef,
  Optional[Boolean] $restart_service                    = true,
  Optional[Boolean] $restart_service_on_docker_refresh  = true,
  Optional[Boolean] $manage_service                     = true,
  Variant[String,Boolean] $docker_service               = false,
  Optional[Boolean] $disable_network                    = false,
  Optional[Boolean] $privileged                         = false,
  Optional[Boolean] $detach                             = undef,
  Variant[String,Array[String],Undef] $extra_parameters = undef,
  Optional[String] $systemd_restart                     = 'on-failure',
  Variant[String,Hash,Undef] $extra_systemd_parameters  = {},
  Optional[Boolean] $pull_on_start                      = false,
  Variant[String,Array,Undef] $after                    = [],
  Variant[String,Array,Undef] $after_service            = [],
  Variant[String,Array,Undef] $depends                  = [],
  Variant[String,Array,Undef] $depend_services          = [],
  Optional[Boolean] $tty                                = false,
  Variant[String,Array,Undef] $socket_connect           = [],
  Variant[String,Array,Undef] $hostentries              = [],
  Optional[String] $restart                             = undef,
  Variant[String,Boolean] $before_start                 = false,
  Variant[String,Boolean] $before_stop                  = false,
  Optional[String]  $after_create                       = undef,
  Optional[Boolean] $remove_container_on_start          = true,
  Optional[Boolean] $remove_container_on_stop           = true,
  Optional[Boolean] $remove_volume_on_start             = false,
  Optional[Boolean] $remove_volume_on_stop              = false,
  Optional[Integer] $stop_wait_time                     = 0,
  Optional[String]  $syslog_identifier                  = undef,
  Optional[Boolean] $read_only                          = false,
  Optional[String]  $health_check_cmd                   = undef,
  Optional[Boolean] $restart_on_unhealthy               = false,
  Optional[Integer] $health_check_interval              = undef,
  Variant[String,Array,Undef] $custom_unless            = [],
  Optional[String] $remain_after_exit                   = undef,
) {
  include docker::params
  if ($socket_connect != []) {
    $sockopts = join(any2array($socket_connect), ',')
    $docker_command = "${docker::params::docker_command} -H ${sockopts}"
  }else {
    $docker_command = $docker::params::docker_command
  }
  $service_name = $docker::service_name
  $docker_group = $docker::docker_group

  if $restart {
    assert_type(Pattern[/^(no|always|unless-stopped|on-failure)|^on-failure:[\d]+$/], $restart)
  }

  if ($remove_volume_on_start and !$remove_container_on_start) {
    fail(translate("In order to remove the volume on start for ${title} you need to also remove the container"))
  }

  if ($remove_volume_on_stop and !$remove_container_on_stop) {
    fail(translate("In order to remove the volume on stop for ${title} you need to also remove the container"))
  }

  if $use_name {
    notify { "docker use_name warning: ${title}":
      message  => 'The use_name parameter is no-longer required and will be removed in a future release',
      withpath => true,
    }
  }

  if $systemd_restart {
    assert_type(Pattern[/^(no|always|on-success|on-failure|on-abnormal|on-abort|on-watchdog)$/], $systemd_restart)
  }

  $service_provider_real = $service_provider ? {
    undef   => $docker::params::service_provider,
    default => $service_provider,
  }

  if $detach == undef {
    $valid_detach = $service_provider_real ? {
      'systemd' => false,
      default   => $docker::params::detach_service_in_init,
    }
  } else {
    $valid_detach = $detach
  }

  $extra_parameters_array = any2array($extra_parameters)
  $after_array = any2array($after)
  $depends_array = any2array($depends)
  $depend_services_array = any2array($depend_services)

  $docker_run_flags = docker_run_flags({
    cpuset                => any2array($cpuset),
    disable_network       => $disable_network,
    dns                   => any2array($dns),
    dns_search            => any2array($dns_search),
    env                   => any2array($env),
    env_file              => any2array($env_file),
    expose                => any2array($expose),
    extra_params          => any2array($extra_parameters),
    hostentries           => any2array($hostentries),
    hostname              => $hostname,
    links                 => any2array($links),
    lxc_conf              => any2array($lxc_conf),
    memory_limit          => $memory_limit,
    net                   => $net,
    ports                 => any2array($ports),
    labels                => any2array($labels),
    privileged            => $privileged,
    socket_connect        => any2array($socket_connect),
    tty                   => $tty,
    username              => $username,
    volumes               => any2array($volumes),
    volumes_from          => any2array($volumes_from),
    read_only             => $read_only,
    health_check_cmd      => $health_check_cmd,
    restart_on_unhealthy  => $restart_on_unhealthy,
    health_check_interval => $health_check_interval,
    osfamily              => $::osfamily,
  })

  $sanitised_title = docker::sanitised_name($title)
  if empty($depends_array) {
    $sanitised_depends_array = []
  }
  else {
    $sanitised_depends_array = docker::sanitised_name($depends_array)
  }

  if empty($after_array) {
    $sanitised_after_array = []
  }
  else {
    $sanitised_after_array = docker::sanitised_name($after_array)
  }

  if $::osfamily == 'windows' {
    $exec_environment = "PATH=${::docker_program_files_path}/Docker/;${::docker_systemroot}/System32/"
    $exec_timeout = 3000
    $exec_path = ["${::docker_program_files_path}/Docker/"]
    $exec_provider = 'powershell'
    $cidfile = "${::docker_user_temp_path}/${service_prefix}${sanitised_title}.cid"
# lint:ignore:140chars
    $restart_check = "${docker_command} inspect ${sanitised_title} -f '{{ if eq \\\"unhealthy\\\" .State.Health.Status }} {{ .Name }}{{ end }}' | findstr ${sanitised_title}"
    $container_running_check = "\$state = ${docker_command} inspect ${sanitised_title} -f \"{{ .State.Running }}\"; if (\$state -ieq \"true\") { Exit 0 } else { Exit 1 }"
# lint:endignore
  } else {
    $exec_environment = 'HOME=/root'
    $exec_path = ['/bin', '/usr/bin']
    $exec_timeout = 0
    $exec_provider = undef
    $cidfile = "/var/run/${service_prefix}${sanitised_title}.cid"
# lint:ignore:140chars
    $restart_check = "${docker_command} inspect ${sanitised_title} -f '{{ if eq \"unhealthy\" .State.Health.Status }} {{ .Name }}{{ end }}' | grep ${sanitised_title}"
    $container_running_check = "${docker_command} inspect ${sanitised_title} -f \"{{ .State.Running }}\" | grep true"
# lint:endignore
  }

  if $restart_on_unhealthy {
    exec { "Restart unhealthy container ${title} with docker":
      command     => "${docker_command} restart ${sanitised_title}",
      onlyif      => $restart_check,
      environment => $exec_environment,
      path        => $exec_path,
      provider    => $exec_provider,
      timeout     => $exec_timeout
    }
  }

  if $restart {
    if $ensure == 'absent' {
      exec { "stop ${title} with docker":
        command     => "${docker_command} stop --time=${stop_wait_time} ${sanitised_title}",
        onlyif      => "${docker_command} inspect ${sanitised_title}",
        environment => $exec_environment,
        path        => $exec_path,
        provider    => $exec_provider,
        timeout     => $exec_timeout
      }

      exec { "remove ${title} with docker":
        command     => "${docker_command} rm -v ${sanitised_title}",
        onlyif      => "${docker_command} inspect ${sanitised_title}",
        environment => $exec_environment,
        path        => $exec_path,
        provider    => $exec_provider,
        timeout     => $exec_timeout
      }

      file { $cidfile:
        ensure => absent,
      }
    }
    else {
      $run_with_docker_command = [
        "${docker_command} run -d ${docker_run_flags}",
        "--name ${sanitised_title} --cidfile=${cidfile}",
        "--restart=\"${restart}\" ${image} ${command}",
      ]
      $inspect = ["${docker_command} inspect ${sanitised_title}"]
      if $custom_unless {
        $exec_unless = concat($custom_unless, $inspect)
      } else {
        $exec_unless = $inspect
      }
      exec { "run ${title} with docker":
        command     => join($run_with_docker_command, ' '),
        unless      => $exec_unless,
        environment => $exec_environment,
        path        => $exec_path,
        provider    => $exec_provider,
        timeout     => $exec_timeout
      }

      if $running == false {
        exec { "stop ${title} with docker":
          command     => "${docker_command} stop --time=${stop_wait_time} ${sanitised_title}",
          onlyif      => $container_running_check,
          environment => $exec_environment,
          path        => $exec_path,
          provider    => $exec_provider,
          timeout     => $exec_timeout
          }
      } else {
        exec { "start ${title} with docker":
          command     => "${docker_command} start ${sanitised_title}",
          unless      => $container_running_check,
          environment => $exec_environment,
          path        => $exec_path,
          provider    => $exec_provider,
          timeout     => $exec_timeout
        }
      }
    }
  } else {

    $docker_run_inline_start = template('docker/docker-run-start.erb')
    $docker_run_inline_stop = template('docker/docker-run-stop.erb')

    case $service_provider_real {
      'systemd': {
        $initscript = "/etc/systemd/system/${service_prefix}${sanitised_title}.service"
        $startscript = "/usr/local/bin/docker-run-${sanitised_title}-start.sh"
        $stopscript = "/usr/local/bin/docker-run-${sanitised_title}-stop.sh"
        $startstop_template = 'docker/usr/local/bin/docker-run.sh.epp'
        $init_template = 'docker/etc/systemd/system/docker-run.erb'
        $mode = '0644'
        $hasstatus = true
      }
      'upstart': {
        $initscript = "/etc/init.d/${service_prefix}${sanitised_title}"
        $init_template = 'docker/etc/init.d/docker-run.erb'
        $mode = '0750'
        $startscript = undef
        $stopscript = undef
        $startstop_template = undef
        $hasstatus = true
      }
      default: {
        if $::osfamily != 'windows' {
          fail(translate('Docker needs a Debian or RedHat based system.'))
        }
        elsif $ensure == 'present' {
          fail(translate('Restart parameter is required for Windows'))
        }

        $hasstatus = $::docker::params::service_hasstatus
      }
    }

    if $syslog_identifier {
      $_syslog_identifier = $syslog_identifier
    } else {
      $_syslog_identifier = "${service_prefix}${sanitised_title}"
    }

    if $ensure == 'absent' {
      if $::osfamily == 'windows'{
        exec {
          "stop container ${service_prefix}${sanitised_title}":
          command     => "${docker_command} stop --time=${stop_wait_time} ${sanitised_title}",
          onlyif      => "${docker_command} inspect ${sanitised_title}",
          environment => $exec_environment,
          path        => $exec_path,
          provider    => $exec_provider,
          timeout     => $exec_timeout,
          notify      => Exec["remove container ${service_prefix}${sanitised_title}"]
        }
      }
      else {
        service { "${service_prefix}${sanitised_title}":
          ensure    => false,
          enable    => false,
          hasstatus => $hasstatus,
          provider  => $service_provider_real,
        }
      }
      exec {
        "remove container ${service_prefix}${sanitised_title}":
        command     => "${docker_command} rm -v ${sanitised_title}",
        onlyif      => "${docker_command} inspect ${sanitised_title}",
        environment => $exec_environment,
        path        => $exec_path,
        refreshonly => true,
        provider    => $exec_provider,
        timeout     => $exec_timeout
      }
      if $::osfamily != 'windows' {
        file { "/etc/systemd/system/${service_prefix}${sanitised_title}.service":
          ensure => absent,
          path   => "/etc/systemd/system/${service_prefix}${sanitised_title}.service",
        }
        if ($startscript) {
          file { $startscript:
            ensure => absent
          }
        }
        if ($stopscript) {
          file { $stopscript:
            ensure => absent
          }
        }
      }
      else {
        file { $cidfile:
          ensure => absent,
        }
      }
    }
    else {
      if ($startscript) {
        file { $startscript:
          ensure  => present,
          content => epp($startstop_template, {'script' => $docker_run_inline_start}),
          owner   => 'root',
          group   => $docker_group,
          mode    => '0770'
        }
      }
      if ($stopscript) {
        file { $stopscript:
          ensure  => present,
          content => epp($startstop_template, {'script' => $docker_run_inline_stop}),
          owner   => 'root',
          group   => $docker_group,
          mode    => '0770'
        }
      }

      file { $initscript:
        ensure  => present,
        content => template($init_template),
        owner   => 'root',
        group   => $docker_group,
        mode    => $mode,
      }

      if $manage_service {
        if $running == false {
          service { "${service_prefix}${sanitised_title}":
            ensure    => $running,
            enable    => false,
            hasstatus => $hasstatus,
            require   => File[$initscript],
          }
        }
        else {
          # Transition help from moving from CID based container detection to
          # Name-based container detection. See #222 for context.
          # This code should be considered temporary until most people have
          # transitioned. - 2015-04-15
          if $initscript == "/etc/init.d/${service_prefix}${sanitised_title}" {
            # This exec sequence will ensure the old-style CID container is stopped
            # before we replace the init script with the new-style.
            $transition_onlyif = [
              "/usr/bin/test -f /var/run/docker-${sanitised_title}.cid &&",
              "/usr/bin/test -f /etc/init.d/${service_prefix}${sanitised_title}",
            ]
            exec { "/bin/sh /etc/init.d/${service_prefix}${sanitised_title} stop":
              onlyif  => join($transition_onlyif, ' '),
              require => [],
            }
            -> file { "/var/run/${service_prefix}${sanitised_title}.cid":
              ensure => absent,
            }
            -> File[$initscript]
          }

          service { "${service_prefix}${sanitised_title}":
            ensure    => $running,
            enable    => true,
            provider  => $service_provider_real,
            hasstatus => $hasstatus,
            require   => File[$initscript],
          }
        }

        if $docker_service {
          if $docker_service == true {
            Service['docker'] -> Service["${service_prefix}${sanitised_title}"]
            if $restart_service_on_docker_refresh == true {
              Service['docker'] ~> Service["${service_prefix}${sanitised_title}"]
            }
          } else {
            Service[$docker_service] -> Service["${service_prefix}${sanitised_title}"]
            if $restart_service_on_docker_refresh == true {
              Service[$docker_service] ~> Service["${service_prefix}${sanitised_title}"]
            }
          }
        }
      }
      if $service_provider_real == 'systemd' {
        exec { "docker-${sanitised_title}-systemd-reload":
          path        => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
          command     => 'systemctl daemon-reload',
          refreshonly => true,
          require     => [File[$initscript],File[$startscript],File[$stopscript]],
          subscribe   => [File[$initscript],File[$startscript],File[$stopscript]]
        }
        Exec["docker-${sanitised_title}-systemd-reload"] -> Service<| title == "${service_prefix}${sanitised_title}" |>
      }

      if $restart_service {
        if $startscript or $stopscript {
          [File[$initscript],File[$startscript],File[$stopscript]] ~> Service<| title == "${service_prefix}${sanitised_title}" |>
        }
        else {
          [File[$initscript]] ~> Service<| title == "${service_prefix}${sanitised_title}" |>
        }
      }
      else {
        if $startscript or $stopscript {
          [File[$initscript],File[$startscript],File[$stopscript]] -> Service<| title == "${service_prefix}${sanitised_title}" |>
        }
        else {
          [File[$initscript]] -> Service<| title == "${service_prefix}${sanitised_title}" |>
        }
      }
    }
  }
}
