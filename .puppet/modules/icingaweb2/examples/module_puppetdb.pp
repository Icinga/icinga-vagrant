include icingaweb2

class {'::icingaweb2::module::puppetdb':
  git_revision => 'master',
  ssl          => 'puppet',
  host         => 'puppetdb.example.com'
}