# TESTING

## Prerequisites
Before starting any test, you should make sure you have installed all dependent puppet modules. Find a list of all
dependencies in [README.md] or [metadata.json].

Required gems are installed with `bundler`:
```
cd puppet-icingaweb2
bundle install
```

## Validation tests
Validation tests will check all manifests, templates and ruby files against syntax violations and style guides .

Run validation tests:
```
cd puppet-icingaweb2
rake validate
```

## Puppet lint
With puppet-lint we test if our manifests conform to the recommended style guides from Puppet.

Run lint tests:
```
cd puppet-icingaweb2
rake lint
```

## Unit tests
For unit testing we use [RSpec]. All classes, defined resource types and functions should have appropriate unit tests.

Run unit tests:
```
cd puppet-icingaweb2
rake spec
```

## Integration tests
With integration tests this module is tested on multiple platforms to check the complete installation process. We define
these tests with [ServerSpec] and run them on VMs by using [Beaker].

Run all tests:
```
bundle exec rake acceptance
```

Run a single test:
``` 
bundle exec rake beaker:ubuntu-server-1604-x64
```

Don't destroy VM after tests:
```
export BEAKER_destroy=no
bundle exec rake beaker:ubuntu-server-1604-x64
```

### Run tests
All available ServerSpec tests are listed in the `spec/acceptance/` directory.

Run all integraion tests:

```
cd puppet-icingaweb2
rake beaker
```

List all available tasks/platforms:
```
cd puppet-icingaweb2
rake --task
```

Run integration tests for a single platform:
```
cd puppet-icingaweb2
rake beaker:centos-7
```

[README.md]: README.md
[puppet-lint]: http://puppet-lint.com/
[metadata.json]: metadata.json
[RSpec]: http://rspec-puppet.com/
[Serverspec]: http://serverspec.org/
[Beaker]: https://github.com/puppetlabs/beaker