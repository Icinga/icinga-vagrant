# puppet-vim

Manage VIM via puppet.

Vim is an advanced text editor that seeks to provide the power of the de-facto Unix editor 'Vi', with a more complete feature set. 

This module aims to enable easy installation and configuration of VIM through class parameters on different platforms, in a way that the administrator can easily set it up differently according to need and/or personal taste.

## Usage

```
    class { 'vim': }
```

## Class parameters
###* set_as_default
* Accepted values: true or false
* Default: true
* Description: Set VIM as default editor.

###* ensure 
* Accepted values: present or absent 
* Default: present
* Description: Whether or not VIM will be installed

###* autoupgrade 
* Accepted values: true or false
* Default: false
* Description: Whether or not the VIM package should be automatically kept up-to-date using the distribution's packaging system

###* set_editor_cmd
* Accepted values: string
* Default: update-alternatives --set editor /usr/bin/${editor_name} (Debian)
* Description: The command used to set VIM as the default editor. Be careful if you're setting this parameter.

###* test_editor_set 
* Accepted values: string
* Default: test /etc/alternatives/editor -ef /usr/bin/${editor_name} (Debian)
* Description: Command used to verify that VIM is the default editor. Be careful if you're setting this parameter.

###* conf_file
* Accepted values: string
* Default: /etc/vim/vimrc (Debian), /etc/vimrc (RedHat)
* Description: Path to VIM's main configuration file.

###* opt_nocompatible
* Accepted values: true or false
* Default: true
* Description: If true, "set nocompatible" is added to the top of the vimrc.

###* opt_backspace
* Accepted values: string
* Default: 2
* Description: Set the behavior of the backspace key in insert mode.

###* opt_bg_shading
* Accepted values: dark or light
* Default: dark
* Description: Terminal background colour. This affects the colour scheme used by VIM to do syntax highlighting.

###* opt_indent
* Accepted values: true or false
* Default: true
* Description: If true, Vim loads indentation rules and plugins according to the detected filetype.

###* opt_lastposition
* Accepted values: true or false
* Default: true
* Description: If true, Vim jumps to the last known position when reopening a file.

###* opt_matchparen
* Accepted values: true or false
* Default: true
* Description: If true and syntax is on, putting your cursor on a paren/brace/bracket will highlight its pair.

###* opt_powersave
* Accepted values: true or false
* Default: true
* Description: If set to 'true' avoids cursor blinking that might wake up the processor.

###* opt_ruler
* Accepted values: true or false
* Default: false
* Description: Turns on the ruler.

###* opt_syntax
* Accepted values: true or false
* Default: true
* Description: Turns on syntax highlighting if supported by the terminal.

###* opt_misc
* Accepted values: array
* Default: ['hlsearch','showcmd','showmatch','ignorecase','smartcase','incsearch','autowrite','hidden']
* Description: Array containing options that will be set on VIM. Anything contained here will show as a "set option" line in your vimrc.

###* opt_maps
* Accepted values: hash
* Default: {}
* Description: Hash containing keybinds for use in "map <k> <v>" lines in your vimrc.

###* opt_code
* Accepted values: Array
* Default: []
* Description: Array containing custom lines in your vimrc.

## Sample Usage
Install VIM and use the provided configuration defaults
```
node default {
  class { 'vim': }
}
```
Turn on line numbering while keeping the default opt_misc values
```
node default {
  class { 'vim':
    opt_misc => ['hlsearch','showcmd','showmatch','ignorecase','smartcase','incsearch','autowrite','hidden','number'],
  }
}
```
Set F5 key to save and execute current file
```
node default {
  class { 'vim':
    opt_maps => { '<F5>': '<Esc>:w<CR>:!%:p<CR>' },
  }
}
```
Uninstall vim
```
node default {
  class { 'vim':
    ensure => absent,
  }
}
```

## Acknowlegments
This module was forked from the one originally written by Saz (https://github.com/saz/puppet-vim). It adds enterprise linux support and configuration file management, which were not present on the original at the time of the first release.
