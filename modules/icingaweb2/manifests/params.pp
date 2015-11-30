class icingaweb2::params {
  $config_dir 		= "/etc/icingaweb2"
  $config_dir_mode	= "2770" # this is mandatory for administrating web2 from the browser
  $config_file_mode	= "0660" # this is mandatory for administrating web2 from the browser
  $config_user		= "root"
  $config_group		= "icingaweb2"
  $git_repo_base 	= "https://git.icinga.org/"
  $web_root_dir		= "/usr/share/icingaweb2"
  $web_module_dir	= "$web_root_dir/modules/"
}

