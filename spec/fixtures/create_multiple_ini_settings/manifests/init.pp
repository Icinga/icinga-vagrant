# Manifest creating multiple ini_settings
class create_multiple_ini_settings {
  if $facts['osfamily'] == 'windows' {
    $defaults = { 'path' => 'C:/tmp/foo.ini' }
  } else {
    $defaults = { 'path' => '/tmp/foo.ini' }
  }

  $example = {
    'section1' => {
      'setting1'  => 'value1',
      'settings2' => {
        'ensure' => 'absent'
      }
    }
  }

  create_ini_settings($example, $defaults)
}

