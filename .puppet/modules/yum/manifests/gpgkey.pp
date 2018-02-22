# Define: yum::gpgkey
#
# This definition saves and imports public GPG key for RPM. Key can
# be stored on Puppet's fileserver or as inline content. Key can be
# also removed from system.
#
# Parameters:
#   [*path*]     - alternative file location (defaults to name)
#   [*ensure*]   - specifies if key should be present or absent
#   [*content*]  - content
#   [*source*]   - source (e.g.: puppet:///)
#   [*owner*]    - file owner
#   [*group*]    - file group
#   [*mode*]     - file mode
#
# Actions:
#
# Requires:
#   RPM based system
#
# Sample usage:
#   yum::gpgkey { '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-smoketest1':
#     ensure  => 'present',
#     content => '-----BEGIN PGP PUBLIC KEY BLOCK-----
#   ...
#   -----END PGP PUBLIC KEY BLOCK-----';
#   }
#
define yum::gpgkey (
  String                    $path    = $name,
  Enum['present', 'absent'] $ensure  = 'present',
  Optional[String]          $content = undef,
  Optional[String]          $source  = undef,
  String                    $owner   = 'root',
  String                    $group   = 'root',
  String                    $mode    = '0644'
) {

  $_creators = [$content, $source]
  $_used_creators = $_creators.filter |$value| { !empty($value) }

  unless size($_used_creators) != 1 {
    File[$path] {
      content => $content,
      source  => $source,
    }
  } else {
    case size($_used_creators) {
      0:       { fail('Missing params: $content or $source must be specified') }
      default: { fail('You cannot specify more than one of content, source') }
    }
  }

  file { $path:
    ensure => $ensure,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
  }

  $rpmname = "gpg-pubkey-$( \
gpg --quiet --with-colon --homedir=/root --throw-keyids <${path} | \
cut -d: -f5 | cut -c9- | tr '[A-Z]' '[a-z]' | head -1)"

  case $ensure {
    'present', default: {
      exec { "rpm-import-${name}":
        path    => '/bin:/usr/bin:/sbin/:/usr/sbin',
        command => "rpm --import ${path}",
        unless  => "rpm -q ${rpmname}",
        require => File[$path],
      }
    }

    'absent': {
      exec { "rpm-delete-${name}":
        path    => '/bin:/usr/bin:/sbin/:/usr/sbin',
        command => "rpm -e ${rpmname}",
        onlyif  => ["test -f ${path}", "rpm -q ${rpmname}"],
        before  => File[$path],
      }
    }
  }
}
