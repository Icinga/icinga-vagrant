include icingaweb2

class {'::icingaweb2::module::puppetdb':
  git_revision => 'master',
  ssl          => 'none',
  certificates => {
    puppetdb1 => {
      ssl_key    => '-----BEGIN RSA PRIVATE KEY----- abc...',
      ssl_cacert => '-----BEGIN RSA PRIVATE KEY----- def...',
    }
  }
}