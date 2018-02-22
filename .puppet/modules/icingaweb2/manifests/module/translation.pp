# == Class: icingaweb2::module::translation
#
# Install and configure the translation module.
#
# === Parameters
#
# [*ensure*]
#   Enable or disable module. Defaults to `present`
#
class icingaweb2::module::translation(
  Enum['absent', 'present'] $ensure = 'present',
){

  $conf_dir        = $::icingaweb2::params::conf_dir
  $module_conf_dir = "${conf_dir}/modules/translation"

  # gettext-tools SUSE
  package { $::icingaweb2::params::gettext_package_name:
    ensure => $ensure,
  }

  $settings = {
    'module-translation' => {
      'section_name' => 'translation',
      'target'       => "${module_conf_dir}/config.ini",
      'settings'     => {
        'msgmerge' => '/usr/bin/msgmerge',
        'xgettext' => '/usr/bin/xgettext',
        'msgfmt'   => '/usr/bin/msgfmt',
      },
    },
  }

  icingaweb2::module { 'translation':
    ensure         => $ensure,
    install_method => 'none',
    settings       => $settings,
  }
}
