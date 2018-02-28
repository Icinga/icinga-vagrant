include icingaweb2

class { 'icingaweb2::module::fileshipper':
  git_revision => 'v1.0.1',
  base_directories => {
    temp => '/tmp'
  },
  directories      => {
    'test' => {
      'source'     => '/tmp/source',
      'target'     => '/tmp/target',
    }
  }
}