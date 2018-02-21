selinux::fcontext{'set-mysql-log-context':
  context  => 'mysqld_log_t',
  pathname => '/var/tmp/mysql',
}
