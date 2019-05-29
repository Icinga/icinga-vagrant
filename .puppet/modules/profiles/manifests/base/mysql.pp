class profiles::base::mysql {

  $mysql_server_override_options = {
  }

  class { '::mysql::server':
    root_password => 'icingar0xx',
    remove_default_accounts => true,
    override_options => $mysql_server_override_options
  }
}
