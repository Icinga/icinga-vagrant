# config.pp

class wget::config () inherits wget {

  assert_private("Use of private class ${name} by ${caller_module_name}")

  create_resources('wget::retrieve', $wget::retrievals)
}
