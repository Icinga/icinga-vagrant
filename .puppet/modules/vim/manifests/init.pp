# Class: vim
#
# This module manages vim and set it as default editor.
#
# Parameters:
#   [*set_as_default*]
#     Set editor as default editor.
#     Default: true
#
#   [*ensure*]
#     Ensure if present or absent.
#     Default: present
#
#   [*autoupgrade*]
#     Upgrade package automatically, if there is a newer version.
#     Default: false
#
#   [*package*]
#     Name of the package.
#     Only set this, if your platform is not supported or you know, what you're doing.
#     Default: auto-set, platform specific
#
#   [*set_editor_cmd*]
#     Command to set editor as default editor.
#     Only set this, if your platform is not supported or you know, what you're doing.
#     Default: auto-set, platform specific
#
#   [*test_editor_set*]
#     Command to check, if editor is set as default.
#     Only set this, if your platform is not supported or you know, what you're doing.
#     Default: auto-set, platform specific
#
#   [*conf_file*]
#     VIM's main configuration file.
#     Default: /etc/vim/vimrc (Debian), /etc/vimrc (RedHat)
#
#   [*opt_nocompatible*]
#     If true, "set nocompatible" is added to the top of the vimrc
#     Default: true
#
#   [*opt_backspace*]
#     Set the behavior of the backspace key in insert mode.
#     Default: 2
#
#   [*opt_bg_shading*]
#     Terminal background colour. This affects the colour scheme used by VIM to do syntax highlighting.
#     Valid values are either 'dark' or 'light'.
#     Default: dark
#
#   [*opt_indent*]
#     If true, Vim loads indentation rules and plugins according to the detected filetype.
#     Default: true
#
#   [*opt_lastposition*]
#     If true, Vim jumps to the last known position when reopening a file.
#     Default: true
#
#   [*opt_matchparen*]
#     If true and syntax is on, putting your cursor on a paren/brace/bracket will highlight its pair.
#     Default: true
#
#   [*opt_powersave*]
#     If set to 'true' avoids cursor blinking that might wake up the processor.
#     Default: true
#
#   [*opt_ruler*]
#     Turns on the ruler.
#     Default: false
#
#   [*opt_syntax*]
#     Turns on syntax highlighting if supported by the terminal.
#     Default: true
#
#   [*opt_misc*]
#     Array containing options that will be set on VIM.
#     Default: ['hlsearch','showcmd','showmatch','ignorecase','smartcase','incsearch','autowrite','hidden']
#
#   [*opt_maps*]
#     Hash containing key maps that will be set on VIM.
#     Default: {}
#
# Actions:
#   Installs vim and, if enabled, set it as default editor.
#
# Requires:
#   Nothing
#
# Sample Usage:
#   class { 'vim': }
#
# [Remember: No empty lines between comments and class definition]
class vim(
  $ensure            = 'present',
  $autoupgrade       = false,
  $skip_defaults_vim = 1,
  $set_as_default    = $vim::params::set_as_default,
  $package           = $vim::params::package,
  $set_editor_cmd    = $vim::params::set_editor_cmd,
  $test_editor_set   = $vim::params::test_editor_set,
  $conf_file         = $vim::params::conf,
  $opt_nocompatible  = $vim::params::nocompatible,
  $opt_backspace     = $vim::params::backspace,
  $opt_bg_shading    = $vim::params::background,
  $opt_indent        = $vim::params::indent,
  $opt_lastposition  = $vim::params::lastposition,
  $opt_matchparen    = $vim::params::matchparen,
  $opt_powersave     = $vim::params::powersave,
  $opt_ruler         = $vim::params::ruler,
  $opt_syntax        = $vim::params::syntax,
  $opt_misc          = $vim::params::misc,
  $opt_maps          = $vim::params::maps,
  $opt_code          = $vim::params::code,
) inherits vim::params {

  case $ensure {
    /(present)/: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }
      $file_ensure = 'file'
    }
    /(absent)/: {
      $package_ensure = 'absent'
      $file_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  package { $package:
    ensure => $package_ensure,
  }

  file { $conf_file:
    ensure  => $file_ensure,
    content => template('vim/vimrc.erb'),
  }

  if $set_as_default and $set_editor_cmd {
    exec { $set_editor_cmd:
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      unless  => $test_editor_set,
      require => Package[$package],
    }
  }
}
