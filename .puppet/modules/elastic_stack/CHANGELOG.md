## Release 7.0.0
- Default to Elastic Stack version 7
- Drop support for Puppet version < 4.10.0

## Release 6.3.2
 - Allow puppetlabs-apt version 7.x
 - Allow puppetlabs-stdlib version 6.x
 - Allow puppet-yum version 4.x
 - Constrain puppetlabs-yumrepo_core to puppet 6+

## Release 6.3.1
- Remove extraneous files from module package

## Release 6.3.0 [Deleted from Forge]

- Support Puppet 6

## Release 6.2.4

- Allow puppetlabs-apt version 6.x

## Release 6.2.3

- Allow puppetlabs-yum version 3.x

## Release 6.2.2

- Allow puppetlabs-stdlib version 5.x

## Release 6.2.1

- Allow puppetlabs-apt version 5.x

## Release 6.2.0

- Add base_repo_url param

## Release 6.1.0

- Support OSS-only package repositories

## Release 6.0.1

- Remove aggressive ordering causing all packages to come after apt::update

## Release 6.0.0

Version number increase to indicate that this module is considered of reasonable
quality and is used by version 6.0.0 of elastic/logstash.

- Changed default repository to version to 6

## Release 0.2.1

- Remove some resource defaults that were causing problems on Puppet 5

## Release 0.2.0

- Expand declared OS support
- Relax minimum Puppet version to 4.6.1
- Support pre-release artifacts
