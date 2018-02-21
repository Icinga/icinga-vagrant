include icingaweb2

$conf_dir        = $::icingaweb2::params::conf_dir
$module_conf_dir = "${conf_dir}/modules/map"

$map_settings = {
  'module-map' => {
    'section_name' => 'map',
    'target'       => "${module_conf_dir}/config.ini",
    'settings'     => {
      'stateType'      => 'hard',
      'default_lat'    => '52.520645',
      'default_long'   => '13.409779',
      'default_zoom'   => '6',
      'max_zoom'       => '19',
      'min_zoom'       => '2',
      'dashlet_height' => '300',
      'marker_size'    => '15',
    },
  },
}

icingaweb2::module { 'map':
  install_method => 'git',
  git_repository => 'https://github.com/nbuchwitz/icingaweb2-module-map.git',
  git_revision   => 'v1.0.3',
  settings       => $map_settings,
}