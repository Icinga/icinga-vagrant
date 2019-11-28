# @api private
class mongodb::opsmanager::config {
  $user  = $mongodb::opsmanager::user
  $group = $mongodb::opsmanager::group

  file { '/opt/mongodb/mms/conf/conf-mms.properties':
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => epp('mongodb/opsmanager/conf-mms.properties.epp'),
  }
}
