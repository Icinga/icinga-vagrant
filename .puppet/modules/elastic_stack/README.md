# elastic_stack

This module contains shared code for various Elastic modules, like
elastic-elasticsearch, elastic-logstash etc.

# Setting up the Elastic package repository
This module can configure package repositories for Elastic Stack components.

Example:

``` puppet
include elastic_stack::repo
```

You may wish to specify a major version, since each has its own repository:

``` puppet
class { 'elastic_stack::repo':
  version => 5,
}
```

To access prerelease versions, such as release candidates, set `prerelease` to `true`.
``` puppet
class { 'elastic_stack::repo':
  version    => 6,
  prerelease => true,
}
```

To access the repository for OSS-only packages, set `oss` to `true`.
``` puppet
class { 'elastic_stack::repo':
  oss => true,
}
```
