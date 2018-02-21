#---
#monitoring::objects:
#  'icinga2::object::host':
#    centos7.localdomain:
#      address: 127.0.0.1
#      vars:
#        os: Linux
#  'icinga2::object::service':
#    ping4:
#      check_command: ping4
#      apply: true
#      assign: 
#        - host.address
#    ssh:
#      check_command: ssh
#      apply: true
#      assign:
#        - host.address && host.vars.os == Linux
#
#monitoring::defaults:
#  'icinga2::object::host':
#    import:
#      - generic-host
#    target: /etc/icinga2/conf.d/hosts.conf
#  'icinga2::object::service':
#    import:
#      - generic-service
#    target: /etc/icinga2/conf.d/services.conf


class { 'icinga2':
  manage_repo => true,
}

$defaults = lookup('monitoring::defaults')

lookup('monitoring::objects').each |String $object_type, Hash $content| {
  $content.each |String $object_name, Hash $object_config| {
    ensure_resource(
      $object_type,
      $object_name,
      deep_merge($defaults[$object_type], $object_config))
  }
}
