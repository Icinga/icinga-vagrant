# Update the systemd temp files
#
# @api public
#
# @see systemd-tmpfiles(8)
#
# @param operations
#   The operations to perform on the systemd tempfiles
#
#   * All operations may be combined but you'll probably only ever want to
#     use ``create``
#
class systemd::tmpfiles (
  Array[Enum['create','clean','remove']] $operations = ['create']
) {

  $_ops = join(prefix($operations, '--'), ' ')

  exec { 'systemd-tmpfiles':
    command     => "systemd-tmpfiles ${_ops}",
    refreshonly => true,
    path        => $::path,
  }
}
