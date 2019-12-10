# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v3.8.0](https://github.com/puppetlabs/puppetlabs-docker/tree/v3.8.0) (2019-10-01)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-docker/compare/v3.7.0...v3.8.0)

### Added

- pdksync - Add support on Debian10 [\#525](https://github.com/puppetlabs/puppetlabs-docker/pull/525) ([lionce](https://github.com/lionce))
- Add new Docker Swarm Tasks \(node ls, rm, update; service scale\) [\#509](https://github.com/puppetlabs/puppetlabs-docker/pull/509) ([khaefeli](https://github.com/khaefeli))

### Fixed

- Fix multiple additional flags for docker\_network [\#523](https://github.com/puppetlabs/puppetlabs-docker/pull/523) ([lemrouch](https://github.com/lemrouch))
- :bug: Fix wrong service detach handling [\#520](https://github.com/puppetlabs/puppetlabs-docker/pull/520) ([khaefeli](https://github.com/khaefeli))
- Fixing error: [\#516](https://github.com/puppetlabs/puppetlabs-docker/pull/516) ([darshannnn](https://github.com/darshannnn))
- Fix aliased plugin names [\#514](https://github.com/puppetlabs/puppetlabs-docker/pull/514) ([koshatul](https://github.com/koshatul))

## [v3.7.0](https://github.com/puppetlabs/puppetlabs-docker/tree/v3.7.0) (2019-07-18)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-docker/compare/v3.6.0...v3.7.0)

### Added

- Added option to override docker-compose download location [\#482](https://github.com/puppetlabs/puppetlabs-docker/pull/482) ([piquet90](https://github.com/piquet90))

## [v3.6.0](https://github.com/puppetlabs/puppetlabs-docker/tree/v3.6.0) (2019-06-25)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-docker/compare/3.5.0...v3.6.0)

### Changed

- \(FM-8100\) Update minimum supported Puppet version to 5.5.10 [\#486](https://github.com/puppetlabs/puppetlabs-docker/pull/486) ([eimlav](https://github.com/eimlav))

### Added

- \(FM-8151\) Add Windows Server 2019 support [\#493](https://github.com/puppetlabs/puppetlabs-docker/pull/493) ([eimlav](https://github.com/eimlav))
- Support for docker machine download and install [\#466](https://github.com/puppetlabs/puppetlabs-docker/pull/466) ([acurus-puppetmaster](https://github.com/acurus-puppetmaster))
- Add service\_provider parameter to docker::run [\#376](https://github.com/puppetlabs/puppetlabs-docker/pull/376) ([iamjamestl](https://github.com/iamjamestl))

### Fixed

- Tasks frozen string [\#499](https://github.com/puppetlabs/puppetlabs-docker/pull/499) ([khaefeli](https://github.com/khaefeli))
- Fix \#239 local\_user permission denied [\#497](https://github.com/puppetlabs/puppetlabs-docker/pull/497) ([thde](https://github.com/thde))
- \(MODULES-9193\) Revert part of MODULES-9177 [\#490](https://github.com/puppetlabs/puppetlabs-docker/pull/490) ([eimlav](https://github.com/eimlav))
- \(MODULES-9177\) Fix version validation regex [\#489](https://github.com/puppetlabs/puppetlabs-docker/pull/489) ([eimlav](https://github.com/eimlav))
- Fix publish flag being erroneously added to docker service commands [\#471](https://github.com/puppetlabs/puppetlabs-docker/pull/471) ([twistedduck](https://github.com/twistedduck))
- Fix container running check to work for windows hosts [\#470](https://github.com/puppetlabs/puppetlabs-docker/pull/470) ([florindragos](https://github.com/florindragos))
- Allow images tagged latest to update on each run [\#468](https://github.com/puppetlabs/puppetlabs-docker/pull/468) ([electrofelix](https://github.com/electrofelix))
- Fix docker::image to not run images [\#465](https://github.com/puppetlabs/puppetlabs-docker/pull/465) ([hugotanure](https://github.com/hugotanure))

# 3.5.0

Changes range for dependent modules

Use multiple networks in docker::run and docker::services

Fixes quotes with docker::services command

Publish multiple ports to docker::services

A full list of issues and PRs associated with this release can be found [here](https://github.com/puppetlabs/puppetlabs-docker/milestone/7?closed=1)

# 3.4.0

Introduces docker_stack type and provider

Fixes frozen string in docker swarm token task

Acceptance testing updates

Allow use of newer translate module

A full list of issues and PRs associated with this release can be found [here](https://github.com/puppetlabs/puppetlabs-docker/milestone/6?closed=1)


# Version 3.3.0

Pins apt repo to 500 to ensure packages are updated

Fixes issue in docker fact failing when docker is not started

Acceptance testing updates

Allows more recent version of the reboot module

A full list of issues and PRs associated with this release can be found [here](https://github.com/puppetlabs/puppetlabs-docker/milestone/5?closed=1)

# Version 3.2.0

Adds in support for Puppet 6

Containers will be restared due to script changes in [PR #367](https://github.com/puppetlabs/puppetlabs-docker/pull/367)

A full list of issues and PRs associated with this release can be found [here](https://github.com/puppetlabs/puppetlabs-docker/milestone/4?closed=1)

# Version 3.1.0

Adding in the following faetures/functionality

- Docker Stack support on Windows.

# Version 3.0.0

Various fixes for github issues
- 206
- 226
- 241
- 280
- 281
- 287
- 289
- 294
- 303
- 312
- 314

Adding in the following features/functionality

-Support for multiple compose files.

A full list of issues and PRs associated with this release can be found [here](https://github.com/puppetlabs/puppetlabs-docker/issues?q=is%3Aissue+milestone%3AV3.0.0+is%3Aclosed)


# Version 2.0.0

Various fixes for github issues
- 193
- 197
- 198
- 203
- 207
- 208
- 209
- 211
- 212
- 213
- 215
- 216
- 217
- 218
- 223
- 224
- 225
- 228
- 229
- 230
- 232
- 234
- 237
- 243
- 245
- 255
- 256
- 259

Adding in the following features/functionality

- Ability to define swarm clusters in Hiera.
- Support docker compose file V2.3.
- Support refresh only flag.
- Support for Docker healthcheck and unhealthy container restart.
- Support for Docker on Windows:
    - Add docker ee support for windows server 2016.
    - Docker image on Windows.
    - Docker run on Windows.
    - Docker compose on Windows.
    - Docker swarm on Windows.
    - Add docker exec functionality for docker on windows.
    - Add storage driver for Windows.  

A full list of issues and PRs associated with this release can be found [here](https://github.com/puppetlabs/puppetlabs-docker/milestone/2?closed=1)


# Version 1.1.0

Various fixes for Github issues
- 183
- 173
- 173
- 167
- 163
- 161

Adding in the following features/functionality

- IPv6 support
- Define type for docker plugins

A full list of issues and PRs associated with this release can be found [here](https://github.com/puppetlabs/puppetlabs-docker/milestone/1?closed=1)


# Version 1.0.5

Various fixes for Github issues
- 98
- 104
- 115
- 122
- 124

Adding in the following features/functionality

- Removed all unsupported OS related code from module
- Removed EPEL dependency
- Added http support in compose proxy
- Added in rubocop support and i18 gem support
- Type and provider for docker volumes
- Update apt module to latest
- Added in support for a registry mirror
- Facts for docker version and docker info
- Fixes for $pass_hash undef
- Fixed typo in param.pp
- Replaced deprecated stblib functions with data types

# Version 1.0.4

Correcting changelog

# Version 1.0.3
Various fixes for Github issues
 - 33
 - 68
 - 74
 - 77
 - 84

Adding in the following features/functionality:

 - Add tasks to update existing service
 - Backwards compatible TMPDIR
 - Optional GPG check on repos
 - Force pull on image tag 'latest'
 - Add support for overlay2.override_kernel_check setting
 - Add docker network fact
 - Add pw hash for registry login idompodency
 - Additional flags for creating a network
 - Fixing incorrect repo url for redhat

# Version 1.0.2
Various fixes for Github issues
 - 9
 - 11
 - 15
 - 21
Add tasks support for Docker Swarm

# Version 1.0.1
Updated metadata and CHANGELOG

# Version 1.0.0
Forked for garethr/docker v5.3.0
Added support for:
- Docker services within a swarm cluster
- Swarm mode
- Docker secrets


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
