# TESTING

## Prerequisites
Before starting any test, you should make sure you have installed all dependent puppet modules. Find a list of all
dependencies in [README.md] or [metadata.json].

Required gems are installed with `bundler`:
```
cd puppet-icinga2
bundle install
```

## Validation tests
Validation tests will check all manifests, templates and ruby files against syntax violations and style guides .

Run validation tests:
```
cd puppet-icinga2
rake validate
```

## Puppet lint
With puppet-lint we test if our manifests conform to the recommended style guides from Puppet.

Run lint tests:
```
cd puppet-icinga2
rake lint
```

## Unit tests
For unit testing we use [RSpec]. All classes, defined resource types and functions should have appropriate unit tests.

Run unit tests:
```
cd puppet-icinga2
rake parallel_spec
```

## Integration tests
With integration tests this module is tested on multiple platforms to check the complete installation process. We define
these tests with [ServerSpec] and run them on VMs by using [Vagrant].
### Prerequisites
In addition to Vagrant, you need to install all dependent modules to run the tests properly. Those modules are listed in
`serverspec/environments/production/Puppetfile` and can be installed with [r10k]

```
cd puppet-icinga2/serverspec/environments/production
r10k puppetfile install -v
```

### Run tests
All available ServerSpec tests are listed in the `serverspec/spec` directory, where each instance has its own directory.

Run all integraion tests:

```
cd puppet-icinga2/serverspec
rake spec
```

List all available tasks/platforms:
```
cd puppet-icinga2/serverspec
rake --task
```

Run integration tests for a single platform:
```
cd puppet-icinga2/serverspec
rake spec:i2debian7puppet4
```

### Windows / SLES
Since we don't want to violate any licenses of Microsoft or SUSE, Windows and SLES boxes are not available publicly.

[README.md]: README.md
[puppet-lint]: http://puppet-lint.com/
[metadata.json]: metadata.json
[RSpec]: http://rspec-puppet.com/
[Serverspec]: http://serverspec.org/
[Vagrant]: https://www.vagrantup.com/
[R10k]: https://github.com/puppetlabs/r10k
