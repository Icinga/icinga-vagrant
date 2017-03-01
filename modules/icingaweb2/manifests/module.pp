
define icingaweb2::module (
  $builtin = false,
  $enable = true,
  $repo_url = undef,
) {
  $repo_base_url = "https://github.com/Icinga/icingaweb2-module-"

  if !$repo_url {
    $repo_source_url = "$repo_base_url$title"
  } else {
    $repo_source_url = $repo_url
  }

  $repo_path = "$::icingaweb2::web_module_dir/$title"

  validate_string($repo_path)

  if !$builtin {
    vcsrepo { $repo_path:
      ensure   => 'latest',
      path     => $repo_path,
      provider => 'git',
      revision => 'master',
      source   => $repo_source_url,
      force    => true,
      require  => [ Package['git'], File[$::icingaweb2::web_module_dir] ]
    }
  }

  file {
    "$::icingaweb2::config_dir/enabledModules/$title":
      ensure 	=> 'link',
      target 	=> $repo_path,
      require 	=> File["$::icingaweb2::config_dir/enabledModules"];
  }

}
