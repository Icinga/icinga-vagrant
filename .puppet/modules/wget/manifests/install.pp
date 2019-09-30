# install.pp

class wget::install inherits wget {

  assert_private("Use of private class ${name} by ${caller_module_name}")

  if $wget::package_manage {
    package { $wget::package_name:
      ensure => $wget::package_ensure,
      alias  => 'wget',
    }
  }
}
