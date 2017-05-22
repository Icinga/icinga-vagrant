class graylog::params {
  $major_version = '2.2'
  $package_version = 'installed'

  $repository_release = 'stable'

  $default_config = {
    'plugin_dir'          => '/usr/share/graylog-server/plugin',
    'message_journal_dir' => '/var/lib/graylog-server/journal',
    'content_packs_dir'   => '/usr/share/graylog-server/contentpacks',
    'is_master'           => true,
  }

  $server_user = 'graylog'
  $server_group = 'graylog'
}
