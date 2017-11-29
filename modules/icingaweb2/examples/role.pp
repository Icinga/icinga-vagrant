include ::icingaweb2

icingaweb2::config::role {'linuxer':
  users       => 'bob, pete',
  groups      => 'linuxer',
  permissions => '*',
  filters     => {
    'monitoring/filter/object' => 'host_name=linux-*'
  }
}