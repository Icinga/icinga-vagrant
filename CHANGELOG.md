Graylog Puppet Module Changes
=============================

## 1.1.1 (2015-06-26)

* Quote bare integer to pass validation check. (#28)

## 1.1.0 (2015-06-22)

* Use `required_packages` instead of `require` for apt source. (#15)
* Added spec tests for `graylog2::server` class. (#18)
* Suppress diffs for config files. (#23)
* Update for Graylog v1.1 release. (#26)
* Usage of any `mongodb_*` option other than `mongodb_uri` is deprecated
  and will log a warning.

## 1.0.0 (2015-02-17)

* Update for Graylog v1.0 release.
* Drops support for all previous releases.

## 0.9.1 (2014-12-02)

* Unbreak module by passing missing arguments for server and radio.

## 0.9.0 (2014-12-02)

* Adjust config templates to 0.92 release.
* Make `graylog2::repo` optional. (#7)
* Do not install `apt-transport-https` if the resource is already defined.
* Fix problems with newer Puppet versions regarding variables. (#8 / #11)

## 0.8.0 (2014-11-19)

* Add timeout option for graylog2-web-interface.
* Switch repository URLs to HTTPS.
* Add support for graylog2-stream-dashboard. (#5)

## 0.7.0 (2014-09-16)

* Add support for managing graylog2-radio. (#3)
* Compatibility fixes for Puppet 2.7.x. (#4)
* Add `command_wrapper`, `java_opts` and `extra_args` options. (#1, #3)

## 0.6.1 (2014-08-29)

* Fix puppet-lint warnings.
* README updates to clarify some things.

## 0.6.0 (2014-08-29)

* Remove default for the `root_password_sha2` parameter. This needs to be set
  by the user now!
* Remove support for Ubuntu 12.04 as there are no official packages for that
  at the moment.
* Switch to `localhost` for server listen URIs.
* Add new configuration options for Graylog 0.21.
* Switch to the official [Graylog2 package repositories](http://graylog2.org/resources/documentation/general/packages).
* Initial release under the `graylog2` namespace. This module is based on the
  `synyx/graylog2` module version 0.5.1.
