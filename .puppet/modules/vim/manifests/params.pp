class vim::params {
  $nocompatible = true
  $background   = 'dark'
  $backspace    = '2'
  $lastposition = true
  $indent       = true
  $matchparen   = true
  $powersave    = true
  $ruler        = false
  $syntax       = true
  $misc         = ['hlsearch','showcmd','showmatch','ignorecase','smartcase','incsearch','autowrite','hidden']
  $maps         = {}
  $code         = []
  case $::osfamily {
    'Debian': {
      $package         = 'vim-nox'
      $editor_name     = 'vim.nox'
      $set_as_default  = true
      $set_editor_cmd  = "update-alternatives --set editor /usr/bin/${editor_name}"
      $test_editor_set = "test /etc/alternatives/editor -ef /usr/bin/${editor_name}"
      $conf            = '/etc/vim/vimrc'
    }
    'RedHat': {
      $package         = 'vim-enhanced'
      $set_as_default  = false
      $set_editor_cmd  = undef
      $test_editor_set = undef
      $conf            = '/etc/vimrc'
    }
    'Archlinux': {
      $package         = 'vim'
      $set_as_default  = false
      $set_editor_cmd  = undef
      $test_editor_set = undef
      $conf            = '/etc/vimrc'
    }
    'FreeBSD': {
      $package         = 'vim-console'
      $set_as_default  = false
      $set_editor_cmd  = undef
      $test_editor_set = undef
      $conf            = '/usr/local/etc/vim/vimrc'
    }
    'Suse': {
      $package         = 'vim'
      $set_as_default  = false
      $set_editor_cmd  = undef
      $test_editor_set = undef
      $conf            = '/etc/vimrc'
    }
    'Gentoo': {
      $package         = 'app-editors/vim'
      $set_as_default  = true
      $set_editor_cmd  = 'eselect editor set /usr/bin/vim'
      $test_editor_set = 'eselect editor show|grep /usr/bin/vim'
      $conf            = '/etc/vimrc'
    }
    'Solaris': {
      if($::operatingsystemrelease =~ /^(5\.11|11|11\.\d+)$/){
        $package         = '/editor/vim'
        $conf            = '/usr/share/vim/vimrc'
        $set_as_default  = false
        $set_editor_cmd  = undef
        $test_editor_set = undef
      }else{
        fail("vim::params: Unsupported platform: ${::osfamily}/${::operatingsystemrelease}")
      }
    }
    default: {
      case $::operatingsystem {
        default: {
          fail("vim::params: Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
    }
  }
}
