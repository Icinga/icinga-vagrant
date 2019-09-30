# A $(yum clean all) Exec to be notified if desired.
class yum::clean {

  exec{'yum_clean_all':
    command     => '/usr/bin/yum clean all',
    refreshonly => true,
  }

}
