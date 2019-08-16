node default {

  notify { 'enduser-before': }
  notify { 'enduser-after': }

  class { 'wget':
    require => Notify['enduser-before'],
    before  => Notify['enduser-after'],
  }
}
