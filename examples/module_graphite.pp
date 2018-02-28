include icingaweb2

class { 'icingaweb2::module::graphite':
  git_revision => 'v0.9.0',
  url          => 'https://localhost:8080'
}