# 2.5.0 (2015-10-31)

**Enhancements**
- Support for [Grafana 2.5](http://grafana.org/blog/2015/10/28/Grafana-2-5-Released.html). This is just a version bump to reflect that Grafana 2.5 is now installed by default
- [PR #58](https://github.com/bfraser/puppet-grafana/pull/58) Sort ```cfg``` keys so ```config.ini``` content is not updated every Puppet run

**Fixes**
- [Issue #52](https://github.com/bfraser/puppet-grafana/issues/52) Version logic moved to ```init.pp``` so overriding the version of Grafana to install works as intended

**Behind The Scenes**

- [PR #59](https://github.com/bfraser/puppet-grafana/pull/59) More specific version requirements in ```metadata.json``` due to use of ```contain``` function
- [PR #61](https://github.com/bfraser/puppet-grafana/pull/61) Fixed typos in ```metadata.json```

# 2.1.0 (2015-08-07)

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

# 2.0.2 (2015-04-30)

**Enhancements**
- Support for Grafana 2.0. Users of Grafana 1.x should stick to version 1.x of the Puppet module
- Support 'archive', 'docker' and 'package' install methods
- Ability to supply a hash of parameters to the Docker container when using 'docker' install method
- [PR #24](https://github.com/bfraser/puppet-grafana/pull/24) Ability to configure Grafana using configuration hash parameter ```cfg```

**Behind The Scenes**
- Update module operatingsystem support, tags, Puppet requirements
- Tests for 'archive' and 'package' install methods

# 1.0.1 (2015-02-27)

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

# 1.0.0 (2014-12-16)

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

# 0.2.2 (2014-10-27)

**Enhancements**
- Add default_route parameter to manage start dashboard

**Fixes**
- Symlink behavior

**Behind The Scenes**
- [Issue #9](https://github.com/bfraser/puppet-grafana/issues/9) Remove stdlib inclusion from manifest

# 0.2.1 (2014-10-14)

**Enhancements**
- Support for multiple datasources
- Install Grafana 1.8.1 by default

**Behind The Scenes**
- Added RSpec tests
- Add stdlib as a module dependency
- Add operating system compatibility

# 0.1.3 (2014-07-03)

**Enhancements**
- Added support for InfluxDB

# 0.1.2 (2014-06-30)

First release on the Puppet Forge
