selinux::fcontext{'set-postfix-instance1-spool':
  equals      => true,
  pathname    => '/var/spool/postfix-instance1',
  destination => '/var/spool/postfix',
}
