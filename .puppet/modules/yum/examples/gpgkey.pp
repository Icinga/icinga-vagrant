yum::gpgkey { '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-smoketest1':
  ensure  => absent,
  content => '-----BEGIN PGP PUBLIC KEY BLOCK-----...',
}
