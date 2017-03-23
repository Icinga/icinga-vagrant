# Changelog

## 2017-02-11 Release 1.3.0

Last release with Puppet3 support!

## 2016-12-25 Release 1.2.0

* Modulesync with latest Vox Pupuli defaults
* Fix wrong license in repo
* Fix several rubocop issues
* Fix several markdown issues in README.md
* Add temp_dir option to override OS temp dir location

## 2016-08-31 Release 1.1.2

  * [GH-213](https://github.com/voxpupuli/puppet-archive/issues/213) Fix *allow_insecure* for ruby provider
  * [GH-205](https://github.com/voxpupuli/puppet-archive/issues/205) Raise exception on bad source parameters
  * [GH-204](https://github.com/voxpupuli/puppet-archive/issues/204) Resolve camptocamp archive regression
  * Expose *allow_insecure* in nexus defined type
  * Make *archive_windir* fact confinement work on ruby 1.8 systems.  Note this does **not** mean the *type* will work on unsupported ruby 1.8 systems.


## 2016-08-18 Release 1.1.1

  * Modulesync with latest Vox Pupuli defaults
  * Fix cacert path
  * Fix AIX extraction
  * Feature: make allow_insecure parameter universal


## 2016-07-13 Release 1.0.0

  * GH-176 Add Compatiblity layer for camptocamp/archive
  * GH-174 Add allow_insecure parameter
  * Numerous Rubocop and other modulesync changes
  * Drop support for ruby 1.8


## 2016-03-18 Release 0.5.1

  * GH-146 Set aws_cli_install default to false
  * GH-142 Fix wget cookie options
  * GH-114 Document extract customization options
  * Open file in binary mode when writing files for windows download


## 2016-03-10 Release 0.5.0

Release 0.5.x contains significant changes:

  * faraday, faraday_middleware no longer required.
  * ruby provider is the default for windows (using net::http).
  * archive gem_provider attribute deprecated.
  * archive::artifactory server, port, url_path attributes deprecated.
  * S3 bucket support (experimental).

  * GH-55 use net::http to stream files
  * Add additional documentation
  * Simplify duplicate code in download/content methods
  * Pin rake to avoid rubocop/rake 11 incompatibility
  * Surface "checksum_verify" parameter in archive::nexus
  * GH-48 S3 bucket support


## 2016-3-2 Release 0.4.8

  * VoxPupuli Release
  * modulesync to fix forge release issues.
  * Cosmetic changes due to rubocop update.


## 2016-3-1 Release 0.4.7

  * VoxPupuli Release
  * Raise exception when error occurs during extraction.

## 2016-2-26 Release 0.4.6

  * VoxPupuli Release


## 2016-2-26 Release 0.4.5

  * Puppet-community release
  * Update travis/forge badge location
  * Fix aio-agent detection
  * Support .gz .xz format
  * Fix local files for non faraday providers
  * Fix GH-77 allows local files to be specified without using file:///
  * Fix GH-78 allow local file:///c:/... on windows
  * Fix phantom v0.4.4 release.


## 2015-12-2 Release 0.4.4

  * Puppet-community release
  * Ignore files properly for functional release
  * Add authentication to archive::nexus
  * Create directory before transfering file
  * Refactor file download code
  * Create and use fact for archive_windir
  * Cleanup old testing code


## 2015-11-25 Release 0.4.3

  * Puppet-community release


## 2015-11-25 Release 0.4.1

  * Automate release :)


## 2015-11-25 Release 0.4.0

  * Migrate Module to Puppet-Community
  * Make everything Rubocop Clean
  * Make everything lint clean
  * Various fixes concerning Jar handling
  * Support for wget
  * Spec Tests for curl
  * Support for bzip
  * More robust handling of sha512 checksums


## 2015-4-23 Release 0.3.0

Release 0.3.x contains breaking changes

  * The parameter 7zip have been changed to seven_zip to conform to Puppet 4.x variable name requirements.
  * The namevar name have been changed to path to allow files with the same filename to exists in different filepath.
  * This project have been migrated to [voxpupuli](https://github.com/voxpupuli/puppet-archive), please adjust your repo git source.

  * Fix Puppet 4 compatability issues
  * Fix archive namevar to use path


## 2015-3-5 Release 0.2.2

  * Add FTP and File support


## 2015-2-26 Release 0.2.1

  * Fix ruby 1.8.7 syntax error


## 2015-2-23 Release 0.2.0

  * Fix custom flags options
  * Add msi installation option for 7zip
  * Add support for configuring extract command user/group
  * Use temporary filepath for download


## 2014-12-08 Release 0.1.8

  * Update documentation
  * puppet-lint, metadata.json cleanup


## 2014-11-13 Release 0.1.7

  * Fix Puppet Enterprise detection
  * Fix checksum length restriction
  * Add puppetlabs stdlib/pe_gem dependency
  * Add spec testing


## 2014-11-05 Release 0.1.6

  * Fix Windows SSL authentication issues


## 2014-11-04 Release 0.1.5

  * Add cookie support


## 2014-10-03 Release 0.1.4

  * Fix file overwrite and re-extract


## 2014-10-03 Release 0.1.3

  * Fix windows x86 path bug


## 2014-10-02 Release 0.1.2

  * Fix autorequire and installation of dependencies


## 2014-10-01 Release 0.1.1

  * Add windows extraction support via 7zip


## 2014-9-26 Release 0.1.0

  * Initial Release
