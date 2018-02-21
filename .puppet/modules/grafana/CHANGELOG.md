# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v4.0.2](https://github.com/voxpupuli/puppet-grafana/tree/v4.0.2) (2017-10-12)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v4.0.1...v4.0.2)

**Implemented enhancements:**

- bump archive upper boundary to work with latest versions [\#73](https://github.com/voxpupuli/puppet-grafana/pull/73) ([bastelfreak](https://github.com/bastelfreak))
- add debian 8 and 9 support [\#72](https://github.com/voxpupuli/puppet-grafana/pull/72) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- fix typo in metadata \(redhat 6 twice vs 6/7\) [\#69](https://github.com/voxpupuli/puppet-grafana/pull/69) ([wyardley](https://github.com/wyardley))

## [v4.0.1](https://github.com/voxpupuli/puppet-grafana/tree/v4.0.1) (2017-09-22)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v4.0.0...v4.0.1)

**Fixed bugs:**

- Module doesn't work on Ubuntu Xenial [\#56](https://github.com/voxpupuli/puppet-grafana/issues/56)

**Merged pull requests:**

- Release 4.0.1 [\#68](https://github.com/voxpupuli/puppet-grafana/pull/68) ([wyardley](https://github.com/wyardley))

## [v4.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v4.0.0) (2017-09-20)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v3.0.0...v4.0.0)

**Implemented enhancements:**

- BREAKING: Switch to Puppet Data Types \(ldap\_cfg is now undef when disabled\) [\#66](https://github.com/voxpupuli/puppet-grafana/pull/66) ([wyardley](https://github.com/wyardley))
- BREAKING: Create grafana\_plugin resource type and change grafana::plugins [\#63](https://github.com/voxpupuli/puppet-grafana/pull/63) ([wyardley](https://github.com/wyardley))
- BREAKING: Update default Grafana version to 4.5.1 and improve acceptance tests [\#61](https://github.com/voxpupuli/puppet-grafana/pull/61) ([wyardley](https://github.com/wyardley))
- grafana\_user custom resource [\#60](https://github.com/voxpupuli/puppet-grafana/pull/60) ([atward](https://github.com/atward))
- Support newer versions of puppetlabs/apt module [\#53](https://github.com/voxpupuli/puppet-grafana/pull/53) ([ghoneycutt](https://github.com/ghoneycutt))
- Support custom plugins [\#44](https://github.com/voxpupuli/puppet-grafana/pull/44) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- gpg key error on CentOS 7 with default params [\#59](https://github.com/voxpupuli/puppet-grafana/issues/59)
- wget called even if not necessary [\#54](https://github.com/voxpupuli/puppet-grafana/issues/54)
- Fix typo in provider [\#58](https://github.com/voxpupuli/puppet-grafana/pull/58) ([atward](https://github.com/atward))

**Closed issues:**

- install\_method 'docker" ignores all other configurations [\#51](https://github.com/voxpupuli/puppet-grafana/issues/51)
- Usable for Grafana 4.x? [\#37](https://github.com/voxpupuli/puppet-grafana/issues/37)
- Remove docker dependency [\#22](https://github.com/voxpupuli/puppet-grafana/issues/22)

**Merged pull requests:**

- Update README.md [\#67](https://github.com/voxpupuli/puppet-grafana/pull/67) ([wyardley](https://github.com/wyardley))
- Get rid of the dependency on 'wget' module in favor of puppet-archive [\#65](https://github.com/voxpupuli/puppet-grafana/pull/65) ([wyardley](https://github.com/wyardley))
- Remove licenses from the top of files [\#64](https://github.com/voxpupuli/puppet-grafana/pull/64) ([wyardley](https://github.com/wyardley))
- Release 4.0.0 [\#62](https://github.com/voxpupuli/puppet-grafana/pull/62) ([bastelfreak](https://github.com/bastelfreak))
- Always use jessie apt repo when osfamily is Debian. [\#41](https://github.com/voxpupuli/puppet-grafana/pull/41) ([furhouse](https://github.com/furhouse))

## [v3.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v3.0.0) (2017-03-29)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v2.6.3...v3.0.0)

**Implemented enhancements:**

- implement package\_ensure param for archlinux [\#34](https://github.com/voxpupuli/puppet-grafana/pull/34) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- implement package\\_ensure param for archlinux [\#34](https://github.com/voxpupuli/puppet-grafana/pull/34) ([bastelfreak](https://github.com/bastelfreak))
- FIX configuration file ownership [\#30](https://github.com/voxpupuli/puppet-grafana/pull/30) ([cassianoleal](https://github.com/cassianoleal))

**Closed issues:**

- Configured grafana debian repo should contain current distribution [\#27](https://github.com/voxpupuli/puppet-grafana/issues/27)
- Error while creating dashboard [\#25](https://github.com/voxpupuli/puppet-grafana/issues/25)

**Merged pull requests:**

- Bump version, Update changelog [\#38](https://github.com/voxpupuli/puppet-grafana/pull/38) ([dhoppe](https://github.com/dhoppe))
- Debian and RedHat based operating systems should use the repository by default [\#36](https://github.com/voxpupuli/puppet-grafana/pull/36) ([dhoppe](https://github.com/dhoppe))
- Add support for archlinux [\#32](https://github.com/voxpupuli/puppet-grafana/pull/32) ([bastelfreak](https://github.com/bastelfreak))
- Fix grafana\_dashboards [\#31](https://github.com/voxpupuli/puppet-grafana/pull/31) ([cassianoleal](https://github.com/cassianoleal))
- supoort jessie for install method repo [\#28](https://github.com/voxpupuli/puppet-grafana/pull/28) ([roock](https://github.com/roock))
- Use operatinsystemmajrelease fact in repo url [\#24](https://github.com/voxpupuli/puppet-grafana/pull/24) ([mirekys](https://github.com/mirekys))
- The puppet 4-only release will start at 3.0.0 [\#21](https://github.com/voxpupuli/puppet-grafana/pull/21) ([rnelson0](https://github.com/rnelson0))

## [v2.6.3](https://github.com/voxpupuli/puppet-grafana/tree/v2.6.3) (2017-01-18)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v2.6.2...v2.6.3)

## [v2.6.2](https://github.com/voxpupuli/puppet-grafana/tree/v2.6.2) (2017-01-18)
[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v2.6.1...v2.6.2)

**Merged pull requests:**

- release 2.6.2 \(optimistic, i know ;\) [\#20](https://github.com/voxpupuli/puppet-grafana/pull/20) ([igalic](https://github.com/igalic))

## v2.6.1 (2017-01-18)

Just a notice: The next release will be a major one without Puppet 3 support!
This is the last Release that supports it!

## Releasing v2.6.0 (2017-01-18)

**Enhancements**

* add two types & provider: `grafana_datasource` & `grafana_dashboard` these
 type allow configuration of the datasource and the dashboard against the API
* allow configuration of `repo_name` for all installation methods
* be more conservative when installing from docker, while also allowing users to
  override our `stable` choice

**Fixes**

* ensure correct ownership of downloaded artefact
* fix use-before definition of `$version`: https://github.com/bfraser/puppet-grafana/issues/87

**Behind The Scenes**

* switch to voxpupuli/archive from camptocamp

**Changes since forking from bfraser/puppet-grafana**

* Add CONTRIBUTING.MD as well as our issues, spec etc… templates
* update README and other files to point to forked repository
* Rubocop and ruby-lint style-fixes!
* test with puppet > 4.x

## 2.5.0 (2015-10-31)

**Enhancements**
- Support for [Grafana 2.5](http://grafana.org/blog/2015/10/28/Grafana-2-5-Released.html). This is just a version bump to reflect that Grafana 2.5 is now installed by default
- [PR #58](https://github.com/bfraser/puppet-grafana/pull/58) Sort ```cfg``` keys so ```config.ini``` content is not updated every Puppet run

**Fixes**
- [Issue #52](https://github.com/bfraser/puppet-grafana/issues/52) Version logic moved to ```init.pp``` so overriding the version of Grafana to install works as intended

**Behind The Scenes**

- [PR #59](https://github.com/bfraser/puppet-grafana/pull/59) More specific version requirements in ```metadata.json``` due to use of ```contain``` function
- [PR #61](https://github.com/bfraser/puppet-grafana/pull/61) Fixed typos in ```metadata.json```

## 2.1.0 (2015-08-07)

**Enhancements**
- Support for [Grafana 2.1](http://grafana.org/blog/2015/08/04/Grafana-2-1-Released.html)
- [Issue #40](https://github.com/bfraser/puppet-grafana/issues/40) Support for [LDAP integration](http://docs.grafana.org/v2.1/installation/ldap/)
- [PR #34](https://github.com/bfraser/puppet-grafana/pull/34) Support for 'repo' install method to install packages from [packagecloud](https://packagecloud.io/grafana) repositories
- Addition of boolean parameter ```manage_package_repo``` to control whether the module will manage the package repository when using the 'repo' install method. See README.md for details
- [PR #39](https://github.com/bfraser/puppet-grafana/pull/39) Ability to ensure a specific package version is installed when using the 'repo' install method

**Fixes**
- [Issue #37](https://github.com/bfraser/puppet-grafana/issues/37) Archive install method: check if user and service are already defined before attempting to define them
- [Issue #42](https://github.com/bfraser/puppet-grafana/issues/42) Package versioning for RPM / yum systems
- [Issue #45](https://github.com/bfraser/puppet-grafana/issues/45) Fix resource dependency issues when ```manage_package_repo``` is false

**Behind The Scenes**
- Use 40 character GPG key ID for packagecloud apt repository

## 2.0.2 (2015-04-30)

**Enhancements**
- Support for Grafana 2.0. Users of Grafana 1.x should stick to version 1.x of the Puppet module
- Support 'archive', 'docker' and 'package' install methods
- Ability to supply a hash of parameters to the Docker container when using 'docker' install method
- [PR #24](https://github.com/bfraser/puppet-grafana/pull/24) Ability to configure Grafana using configuration hash parameter ```cfg```

**Behind The Scenes**
- Update module operatingsystem support, tags, Puppet requirements
- Tests for 'archive' and 'package' install methods

## 1.0.1 (2015-02-27)

**Enhancements**
- New parameter for Grafana admin password

**Fixes**
- Package install method now makes use of install_dir for config.js path

**Behind The Scenes**
- Add archive module to .fixtures.yml
- Unquote booleans to make lint happy
- Fix license identifier and unbounded dependencies in module metadata
- Allow Travis to fail on Ruby 1.8.7
- More Puppet versions are tested by Travis

## 1.0.0 (2014-12-16)

**Enhancements**
- Add max_search_results parameter
- Install Grafana 1.9.0 by default

**Documentation**
- Add download_url and install_method parameters to README

**Behind The Scenes**
- [Issue #6](https://github.com/bfraser/puppet-grafana/issues/6) Replace gini/archive dependency with camptocamp/archive
- Addition of CHANGELOG
- Style fixes
- Removal of vagrant-wrapper gem
- Fancy badges for build status

## 0.2.2 (2014-10-27)

**Enhancements**
- Add default_route parameter to manage start dashboard

**Fixes**
- Symlink behavior

**Behind The Scenes**
- [Issue #9](https://github.com/bfraser/puppet-grafana/issues/9) Remove stdlib inclusion from manifest

## 0.2.1 (2014-10-14)

**Enhancements**
- Support for multiple datasources
- Install Grafana 1.8.1 by default

**Behind The Scenes**
- Added RSpec tests
- Add stdlib as a module dependency
- Add operating system compatibility

## 0.1.3 (2014-07-03)

**Enhancements**
- Added support for InfluxDB

## 0.1.2 (2014-06-30)

First release on the Puppet Forge


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*