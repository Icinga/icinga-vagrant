# Used for testing the recipe in a Vagrant box
#
# Login via user "admin" and password "admin"

include java

class { 'graylog::allinone':
  elasticsearch => {
    version      => '2.4.4',
    repo_version => '2.x',
  },
  graylog       => {
    major_version => '2.2',
    config        => {
      'password_secret'          => '16BKgz0Qelg6eFeJYh8lc4hWU1jJJmAgHlPEx6qkBa2cQQTUG300FYlPOEvXsOV4smzRtnwjHAKykE3NIWXbpL7yGLN7V2P2',
      'root_password_sha2'       => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
      'versionchecks'            => false,
      'usage_statistics_enabled' => false,
    }
  }
}
