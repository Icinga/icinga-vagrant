# Reload the systemctl daemon
#
# @api public
class systemd::systemctl::daemon_reload {
  exec { 'systemctl-daemon-reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    path        => $facts['path'],
  }
}
