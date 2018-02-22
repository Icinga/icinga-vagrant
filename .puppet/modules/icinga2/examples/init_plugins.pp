class { 'icinga2':
  manage_repo => true,
  plugins     => [ 'plugins', 'plugins-contrib', 'windows-plugins', 'nscp' ]
}
