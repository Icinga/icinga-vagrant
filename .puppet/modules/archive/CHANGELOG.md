# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v4.2.0](https://github.com/voxpupuli/puppet-archive/tree/v4.2.0) (2019-08-14)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v4.1.0...v4.2.0)

**Implemented enhancements:**

- add bunzip2 filetype support [\#378](https://github.com/voxpupuli/puppet-archive/pull/378) ([Dan33l](https://github.com/Dan33l))

## [v4.1.0](https://github.com/voxpupuli/puppet-archive/tree/v4.1.0) (2019-07-04)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v4.0.0...v4.1.0)

**Closed issues:**

- 4 Certificates expired, 3 expiring soon in cacert.pem [\#372](https://github.com/voxpupuli/puppet-archive/issues/372)

**Merged pull requests:**

- Update cacert.pem [\#373](https://github.com/voxpupuli/puppet-archive/pull/373) ([alexjfisher](https://github.com/alexjfisher))
- drop Ubuntu 14.04 support [\#371](https://github.com/voxpupuli/puppet-archive/pull/371) ([bastelfreak](https://github.com/bastelfreak))

## [v4.0.0](https://github.com/voxpupuli/puppet-archive/tree/v4.0.0) (2019-05-29)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v3.2.1...v4.0.0)

**Breaking changes:**

- modulesync 2.7.0 and drop puppet 4 [\#368](https://github.com/voxpupuli/puppet-archive/pull/368) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Allow `puppetlabs/stdlib` 6.x [\#369](https://github.com/voxpupuli/puppet-archive/pull/369) ([alexjfisher](https://github.com/alexjfisher))

**Merged pull requests:**

- explain how to download as simple as possible [\#366](https://github.com/voxpupuli/puppet-archive/pull/366) ([Dan33l](https://github.com/Dan33l))

## [v3.2.1](https://github.com/voxpupuli/puppet-archive/tree/v3.2.1) (2018-10-19)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v3.2.0...v3.2.1)

**Merged pull requests:**

- modulesync 2.1.0 and allow puppet 6.x [\#355](https://github.com/voxpupuli/puppet-archive/pull/355) ([bastelfreak](https://github.com/bastelfreak))

## [v3.2.0](https://github.com/voxpupuli/puppet-archive/tree/v3.2.0) (2018-08-26)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v3.1.1...v3.2.0)

**Implemented enhancements:**

- Bump stdlib dependency to \<6.0.0 [\#352](https://github.com/voxpupuli/puppet-archive/pull/352) ([HelenCampbell](https://github.com/HelenCampbell))
- Fallback to PowerShell for zip files on Windows [\#351](https://github.com/voxpupuli/puppet-archive/pull/351) ([GeoffWilliams](https://github.com/GeoffWilliams))

## [v3.1.1](https://github.com/voxpupuli/puppet-archive/tree/v3.1.1) (2018-08-02)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v3.1.0...v3.1.1)

**Fixed bugs:**

- do not escape path on windows for unzip command [\#344](https://github.com/voxpupuli/puppet-archive/pull/344) ([qs5779](https://github.com/qs5779))

**Closed issues:**

- need a good example for extracting a tgz [\#335](https://github.com/voxpupuli/puppet-archive/issues/335)

**Merged pull requests:**

- fix documentation - refactor example when extracting tar.gz [\#342](https://github.com/voxpupuli/puppet-archive/pull/342) ([azbarcea](https://github.com/azbarcea))
- purge EOL ubuntu 10.04/12.04 from metadata.json [\#341](https://github.com/voxpupuli/puppet-archive/pull/341) ([bastelfreak](https://github.com/bastelfreak))
- README.md: how to handle a .tar.gz file [\#338](https://github.com/voxpupuli/puppet-archive/pull/338) ([bastelfreak](https://github.com/bastelfreak))

## [v3.1.0](https://github.com/voxpupuli/puppet-archive/tree/v3.1.0) (2018-06-14)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v3.0.0...v3.1.0)

**Closed issues:**

- HTTPS download broken again on windows [\#289](https://github.com/voxpupuli/puppet-archive/issues/289)

**Merged pull requests:**

- Allow Ubuntu 18.04 [\#336](https://github.com/voxpupuli/puppet-archive/pull/336) ([mpdude](https://github.com/mpdude))
- Remove docker nodesets [\#334](https://github.com/voxpupuli/puppet-archive/pull/334) ([bastelfreak](https://github.com/bastelfreak))
- drop EOL OSs; fix puppet version range [\#332](https://github.com/voxpupuli/puppet-archive/pull/332) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.0](https://github.com/voxpupuli/puppet-archive/tree/v3.0.0) (2018-03-31)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v2.3.0...v3.0.0)

**Breaking changes:**

- Rewrite artifactory\_sha1 function with puppet v4 api [\#323](https://github.com/voxpupuli/puppet-archive/pull/323) ([alexjfisher](https://github.com/alexjfisher))
- Remove deprecated archive::artifactory parameters [\#322](https://github.com/voxpupuli/puppet-archive/pull/322) ([alexjfisher](https://github.com/alexjfisher))

**Implemented enhancements:**

- Adding windows server 2016 to metadata.json [\#325](https://github.com/voxpupuli/puppet-archive/pull/325) ([TraGicCode](https://github.com/TraGicCode))

**Merged pull requests:**

- bump puppet to latest supported version 4.10.0 [\#326](https://github.com/voxpupuli/puppet-archive/pull/326) ([bastelfreak](https://github.com/bastelfreak))
- Don't glob archive URL with curl [\#318](https://github.com/voxpupuli/puppet-archive/pull/318) ([derekhiggins](https://github.com/derekhiggins))

## [v2.3.0](https://github.com/voxpupuli/puppet-archive/tree/v2.3.0) (2018-02-21)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v2.2.0...v2.3.0)

**Implemented enhancements:**

- Support fetching latest SNAPSHOT artifacts [\#284](https://github.com/voxpupuli/puppet-archive/pull/284) ([alexjfisher](https://github.com/alexjfisher))

**Fixed bugs:**

- Fix typo in digest\_type: sh256 -\> sha256 [\#315](https://github.com/voxpupuli/puppet-archive/pull/315) ([mark0n](https://github.com/mark0n))

**Merged pull requests:**

- Fix checksum\_type sh256 -\> sha256 typo [\#309](https://github.com/voxpupuli/puppet-archive/pull/309) ([tylerjl](https://github.com/tylerjl))
- Fix typo "voxpupoli" [\#308](https://github.com/voxpupuli/puppet-archive/pull/308) ([nmesstorff](https://github.com/nmesstorff))

## [v2.2.0](https://github.com/voxpupuli/puppet-archive/tree/v2.2.0) (2017-11-21)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v2.1.0...v2.2.0)

**Closed issues:**

- Setting an invalid proxy\_server parameter should return a more helpful error message. [\#220](https://github.com/voxpupuli/puppet-archive/issues/220)

**Merged pull requests:**

- Log actual and expected checksums on mismatch [\#305](https://github.com/voxpupuli/puppet-archive/pull/305) ([jeffmccune](https://github.com/jeffmccune))

## [v2.1.0](https://github.com/voxpupuli/puppet-archive/tree/v2.1.0) (2017-10-10)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v2.0.0...v2.1.0)

**Closed issues:**

- unzip not installed and results in errors [\#291](https://github.com/voxpupuli/puppet-archive/issues/291)
- Support puppet:/// urls or edit readme? [\#283](https://github.com/voxpupuli/puppet-archive/issues/283)
- Using proxy\_server and/or proxy\_port has no effect on Windows [\#277](https://github.com/voxpupuli/puppet-archive/issues/277)
- puppet source [\#151](https://github.com/voxpupuli/puppet-archive/issues/151)

**Merged pull requests:**

- Fix typos in puppet:/// URL example [\#298](https://github.com/voxpupuli/puppet-archive/pull/298) ([gabe-sky](https://github.com/gabe-sky))
- Update cacert.pem [\#290](https://github.com/voxpupuli/puppet-archive/pull/290) ([nanliu](https://github.com/nanliu))
- Support Nexus 3 urls for artifact downloads [\#285](https://github.com/voxpupuli/puppet-archive/pull/285) ([rvdh](https://github.com/rvdh))

## [v2.0.0](https://github.com/voxpupuli/puppet-archive/tree/v2.0.0) (2017-08-25)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v1.3.0...v2.0.0)

**Breaking changes:**

- BREAKING: Drop puppet 3 support. Replace validate\_\* functions with Puppet 4 data type validations [\#264](https://github.com/voxpupuli/puppet-archive/pull/264) ([jkroepke](https://github.com/jkroepke))

**Implemented enhancements:**

- Enable allow\_insecure in archive::download [\#295](https://github.com/voxpupuli/puppet-archive/pull/295) ([alexjfisher](https://github.com/alexjfisher))
- Add custom download options [\#279](https://github.com/voxpupuli/puppet-archive/pull/279) ([nanliu](https://github.com/nanliu))
- Add support for downloading puppet URL’s [\#270](https://github.com/voxpupuli/puppet-archive/pull/270) ([hajee](https://github.com/hajee))

**Fixed bugs:**

- wget proxy implementation incorrect [\#256](https://github.com/voxpupuli/puppet-archive/issues/256)

**Closed issues:**

- allow\_insecure is not working [\#294](https://github.com/voxpupuli/puppet-archive/issues/294)
- Can't download latest SNAPSHOT artifactory artifacts [\#282](https://github.com/voxpupuli/puppet-archive/issues/282)
- Need option to set curl SSL protocol [\#273](https://github.com/voxpupuli/puppet-archive/issues/273)
- Add guide for migrating from puppet-staging [\#266](https://github.com/voxpupuli/puppet-archive/issues/266)
- Rubocop: fix RSpec/MessageSpies [\#260](https://github.com/voxpupuli/puppet-archive/issues/260)
- -z for curl option [\#241](https://github.com/voxpupuli/puppet-archive/issues/241)
- RSpec/MessageExpectation violations [\#208](https://github.com/voxpupuli/puppet-archive/issues/208)

**Merged pull requests:**

- Change how ruby proxy is invoked. [\#280](https://github.com/voxpupuli/puppet-archive/pull/280) ([nanliu](https://github.com/nanliu))
- Pass proxy values using the wget -e option [\#272](https://github.com/voxpupuli/puppet-archive/pull/272) ([nanliu](https://github.com/nanliu))
- GH-260 Fix rubocop RSpec/MessageSpies [\#271](https://github.com/voxpupuli/puppet-archive/pull/271) ([nanliu](https://github.com/nanliu))
- Fix README typo on credentials file and add the config too [\#269](https://github.com/voxpupuli/puppet-archive/pull/269) ([aerostitch](https://github.com/aerostitch))
- Add puppet-staging migration examples [\#268](https://github.com/voxpupuli/puppet-archive/pull/268) ([alexjfisher](https://github.com/alexjfisher))

## [v1.3.0](https://github.com/voxpupuli/puppet-archive/tree/v1.3.0) (2017-02-10)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v1.2.0...v1.3.0)

## v1.2.0 (2016-12-25)

* Modulesync with latest Vox Pupuli defaults
* Fix wrong license in repo
* Fix several rubocop issues
* Fix several markdown issues in README.md
* Add temp_dir option to override OS temp dir location

## v1.1.2 (2016-08-31)

  * [GH-213](https://github.com/voxpupuli/puppet-archive/issues/213) Fix *allow_insecure* for ruby provider
  * [GH-205](https://github.com/voxpupuli/puppet-archive/issues/205) Raise exception on bad source parameters
  * [GH-204](https://github.com/voxpupuli/puppet-archive/issues/204) Resolve camptocamp archive regression
  * Expose *allow_insecure* in nexus defined type
  * Make *archive_windir* fact confinement work on ruby 1.8 systems.  Note this does **not** mean the *type* will work on unsupported ruby 1.8 systems.


## v1.1.1 (2016-08-18)

  * Modulesync with latest Vox Pupuli defaults
  * Fix cacert path
  * Fix AIX extraction
  * Feature: make allow_insecure parameter universal


## v1.0.0 (2016-07-13)

  * GH-176 Add Compatiblity layer for camptocamp/archive
  * GH-174 Add allow_insecure parameter
  * Numerous Rubocop and other modulesync changes
  * Drop support for ruby 1.8


## v0.5.1 (2016-03-18)

  * GH-146 Set aws_cli_install default to false
  * GH-142 Fix wget cookie options
  * GH-114 Document extract customization options
  * Open file in binary mode when writing files for windows download


## v0.5.0 (2016-03-10)

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


## v0.4.8 (2016-03-02)

  * VoxPupuli Release
  * modulesync to fix forge release issues.
  * Cosmetic changes due to rubocop update.


## v0.4.7 (2016-03-1)

  * VoxPupuli Release
  * Raise exception when error occurs during extraction.

## v0.4.6 (2016-02-26)

  * VoxPupuli Release


## v0.4.5 (2016-02-26)

  * Puppet-community release
  * Update travis/forge badge location
  * Fix aio-agent detection
  * Support .gz .xz format
  * Fix local files for non faraday providers
  * Fix GH-77 allows local files to be specified without using file:///
  * Fix GH-78 allow local file:///c:/... on windows
  * Fix phantom v0.4.4 release.


## v0.4.4 (2015-12-2)

  * Puppet-community release
  * Ignore files properly for functional release
  * Add authentication to archive::nexus
  * Create directory before transfering file
  * Refactor file download code
  * Create and use fact for archive_windir
  * Cleanup old testing code


## v0.4.3 (2015-11-25)

  * Puppet-community release


## v0.4.1 (2015-11-25)

  * Automate release :)


## v0.4.0 (2015-11-25)

  * Migrate Module to Puppet-Community
  * Make everything Rubocop Clean
  * Make everything lint clean
  * Various fixes concerning Jar handling
  * Support for wget
  * Spec Tests for curl
  * Support for bzip
  * More robust handling of sha512 checksums


## 0.3.0 (2015-04-23)

Release 0.3.x contains breaking changes

  * The parameter 7zip have been changed to seven_zip to conform to Puppet 4.x variable name requirements.
  * The namevar name have been changed to path to allow files with the same filename to exists in different filepath.
  * This project have been migrated to [voxpupuli](https://github.com/voxpupuli/puppet-archive), please adjust your repo git source.

  * Fix Puppet 4 compatability issues
  * Fix archive namevar to use path


## 0.2.2 (2015-03-05)

  * Add FTP and File support


## 0.2.1 (2015-02-26)

  * Fix ruby 1.8.7 syntax error


## 0.2.0 (2015-02-23)

  * Fix custom flags options
  * Add msi installation option for 7zip
  * Add support for configuring extract command user/group
  * Use temporary filepath for download


## 0.1.8 (2014-12-08)

  * Update documentation
  * puppet-lint, metadata.json cleanup


## 0.1.7 (2014-11-13)

  * Fix Puppet Enterprise detection
  * Fix checksum length restriction
  * Add puppetlabs stdlib/pe_gem dependency
  * Add spec testing


## 0.1.6 (2014-11-05)

  * Fix Windows SSL authentication issues


## 0.1.5 (2014-11-04)

  * Add cookie support


## 0.1.4 (2014-10-03)

  * Fix file overwrite and re-extract


## 0.1.3 (2014-10-03)

  * Fix windows x86 path bug


## 0.1.2 (2014-10-02)

  * Fix autorequire and installation of dependencies


## 0.1.1 (2014-10-01)

  * Add windows extraction support via 7zip


## 0.1.0 (2014-09-26)

  * Initial Release


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
