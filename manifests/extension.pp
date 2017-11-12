# Install a PHP extension package
#
# === Parameters
#
# [*ensure*]
#   The ensure of the package to install
#   Could be "latest", "installed" or a pinned version
#
# [*package_prefix*]
#   Prefix to prepend to the package name for the package provider
#
# [*provider*]
#   The provider used to install the package
#   Could be "pecl", "apt", "dpkg" or any other OS package provider
#   If set to "none", no package will be installed
#
# [*source*]
#   The source to install the extension from. Possible values
#   depend on the *provider* used
#
# [*pecl_source*]
#   The pecl source channel to install pecl package from
#   Superseded by *source*
#
# [*so_name*]
#   The DSO name of the package (e.g. opcache for zendopcache)
#
# [*php_api_version*]
#   This parameter is used to build the full path to the extension
#   directory for zend_extension in PHP < 5.5 (e.g. 20100525)
#
# [*header_packages*]
#   System packages dependencies to install for extensions (e.g. for
#   memcached libmemcached-dev on Debian)
#
# [*compiler_packages*]
#   System packages dependencies to install for compiling extensions
#   (e.g. build-essential on Debian)
#
# [*zend*]
#  Boolean parameter, whether to load extension as zend_extension.
#  Defaults to false.
#
# [*settings*]
#   Nested hash of global config parameters for php.ini
#
# [*settings_prefix*]
#   Boolean/String parameter, whether to prefix all setting keys with
#   the extension name or specified name. Defaults to false.
#
# [*sapi*]
#   String parameter, whether to specify ALL sapi or a specific sapi.
#   Defaults to ALL.
#
# [*responsefile*]
#   File containing answers for interactive extension setup. Supported
#   *providers*: pear, pecl.
#
define php::extension (
  $ensure            = 'installed',
  $provider          = undef,
  $source            = undef,
  $pecl_source       = undef,
  $so_name           = $name,
  $php_api_version   = undef,
  $package_prefix    = $::php::package_prefix,
  $header_packages   = [],
  $compiler_packages = $::php::params::compiler_packages,
  $zend              = false,
  $settings          = {},
  $settings_prefix   = false,
  $sapi              = 'ALL',
  $responsefile      = undef,
  $install_options   = undef,
) {

  if ! defined(Class['php']) {
    warning('php::extension is private')
  }

  validate_string($ensure)
  validate_string($package_prefix)
  validate_string($so_name)
  validate_string($php_api_version)
  validate_string($sapi)
  validate_array($header_packages)
  validate_bool($zend)

  if $source and $pecl_source {
    fail('Only one of $source and $pecl_source can be specified.')
  }

  if $source {
    $real_source = $source
  }
  else {
    $real_source = $pecl_source
  }

  if $provider != 'none' {
    case $provider {
      'pecl': { $real_package = $title }
      'pear': { $real_package = $title }
      default: { $real_package = "${package_prefix}${title}" }
    }

    unless empty($header_packages) {
      ensure_resource('package', $header_packages)
      Package[$header_packages] -> Package[$real_package]
    }

    if $provider == 'pecl' or $provider == 'pear' {
      ensure_packages( [ $real_package ], {
        ensure          => $ensure,
        provider        => $provider,
        source          => $real_source,
        responsefile    => $responsefile,
        install_options => $install_options,
        require         => [
          Class['::php::pear'],
          Class['::php::dev'],
        ],
      })

      unless empty($compiler_packages) {
        ensure_resource('package', $compiler_packages)
        Package[$compiler_packages] -> Package[$real_package]
      }
    }
    else {
      if $responsefile != undef {
        warning("responsefile param is not supported by php::extension provider ${provider}")
      }

      ensure_packages( [ $real_package ], {
        ensure   => $ensure,
        provider => $provider,
        source   => $real_source,
      })
    }

    $package_depends = "Package[${real_package}]"
  } else {
    $package_depends = undef
  }

  if $zend == true {
    $extension_key = 'zend_extension'
    if $php_api_version != undef {
      $module_path = "/usr/lib/php5/${php_api_version}/"
    }
    else {
      $module_path = undef
    }
  }
  else {
    $extension_key = 'extension'
    $module_path = undef
  }

  if $so_name != $name {
    $lowercase_title = $so_name
  }
  else {
    $lowercase_title = downcase($title)
  }

  # Ensure "<extension>." prefix is present in setting keys if requested
  if $settings_prefix {
    if is_string($settings_prefix) {
      $full_settings_prefix = $settings_prefix
    } else {
      $full_settings_prefix = $lowercase_title
    }
    $full_settings = ensure_prefix($settings, "${full_settings_prefix}.")
  } else {
    $full_settings = $settings
  }

  if $provider != 'pear' {
    $final_settings = deep_merge(
      {"${extension_key}" => "${module_path}${so_name}.so"},
      $full_settings
    )
  } else {
    $final_settings = $full_settings
  }

  $config_root_ini = pick_default($::php::config_root_ini, $::php::params::config_root_ini)
  ::php::config { $title:
    file    => "${config_root_ini}/${lowercase_title}.ini",
    config  => $final_settings,
    require => $package_depends,
  }

  # Ubuntu/Debian systems use the mods-available folder. We need to enable
  # settings files ourselves with php5enmod command.
  $ext_tool_enable   = pick_default($::php::ext_tool_enable, $::php::params::ext_tool_enable)
  $ext_tool_query    = pick_default($::php::ext_tool_query, $::php::params::ext_tool_query)
  $ext_tool_enabled  = pick_default($::php::ext_tool_enabled, $::php::params::ext_tool_enabled)

  if $::osfamily == 'Debian' and $ext_tool_enabled {
    $cmd = "${ext_tool_enable} -s ${sapi} ${lowercase_title}"

    if $sapi == 'ALL' {
      exec { $cmd:
        onlyif  => "${ext_tool_query} -s cli -m ${lowercase_title} | /bin/grep 'No module matches ${lowercase_title}'",
        require =>::Php::Config[$title],
      }
    } else {
      exec { $cmd:
        onlyif  => "${ext_tool_query} -s ${sapi} -m ${lowercase_title} | /bin/grep 'No module matches ${lowercase_title}'",
        require =>::Php::Config[$title],
      }
    }

    if $::php::fpm {
      Package[$::php::fpm::package] ~> Exec[$cmd]
    }
  }
}
