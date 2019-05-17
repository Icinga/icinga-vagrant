class profiles::base::mysql {

  # Required for Icinga Reporting & x509 module
  $mysql_server_override_options = {
    'mysqld' => {
      'innodb_file_format' 	=> 'barracuda',
      'innodb_file_per_table' 	=> '1',
      'innodb_large_prefix'	=> '1'
    }
  }

  class { '::mysql::server':
    root_password => 'icingar0xx',
    remove_default_accounts => true,
    override_options => $mysql_server_override_options
  }
}
