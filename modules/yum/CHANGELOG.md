# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v2.1.0](https://github.com/voxpupuli/puppet-yum/tree/v2.1.0) (2017-11-02)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v2.0.2...v2.1.0)

**Implemented enhancements:**

- Add AmazonLinux 2017 compatibility. [\#71](https://github.com/voxpupuli/puppet-yum/pull/71) ([pillarsdotnet](https://github.com/pillarsdotnet))

## [v2.0.2](https://github.com/voxpupuli/puppet-yum/tree/v2.0.2) (2017-10-10)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v2.0.1...v2.0.2)

**Closed issues:**

- concat dependency update [\#57](https://github.com/voxpupuli/puppet-yum/issues/57)
- Yumrepo provider fork? [\#32](https://github.com/voxpupuli/puppet-yum/issues/32)

**Merged pull requests:**

- Release 2.0.2 [\#70](https://github.com/voxpupuli/puppet-yum/pull/70) ([bastelfreak](https://github.com/bastelfreak))
- Update README.md [\#69](https://github.com/voxpupuli/puppet-yum/pull/69) ([arjenz](https://github.com/arjenz))
- Emtpy hiera files throw puppet 4 warnings [\#67](https://github.com/voxpupuli/puppet-yum/pull/67) ([benohara](https://github.com/benohara))
- Prepare 2.0.1 [\#64](https://github.com/voxpupuli/puppet-yum/pull/64) ([jeefberkey](https://github.com/jeefberkey))

## [v2.0.1](https://github.com/voxpupuli/puppet-yum/tree/v2.0.1) (2017-09-01)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v2.0.0...v2.0.1)

**Implemented enhancements:**

- Update concat dependency [\#58](https://github.com/voxpupuli/puppet-yum/pull/58) ([cdenneen](https://github.com/cdenneen))

**Fixed bugs:**

- Drop empty yaml file [\#55](https://github.com/voxpupuli/puppet-yum/pull/55) ([traylenator](https://github.com/traylenator))

**Closed issues:**

- Update to puppetlabs/concat 3 or 4 [\#66](https://github.com/voxpupuli/puppet-yum/issues/66)
- yum::versionlock with ensure =\> absent doesn't purge entries [\#61](https://github.com/voxpupuli/puppet-yum/issues/61)
- versionlock.list updated after package {} install [\#43](https://github.com/voxpupuli/puppet-yum/issues/43)

**Merged pull requests:**

- Contain the versionlock subclass to help with ordering around package resources [\#65](https://github.com/voxpupuli/puppet-yum/pull/65) ([bovy89](https://github.com/bovy89))
- Support `ensure =\> absent` with yum::versionlock [\#62](https://github.com/voxpupuli/puppet-yum/pull/62) ([bovy89](https://github.com/bovy89))
- Prepare release 2.0.0 [\#52](https://github.com/voxpupuli/puppet-yum/pull/52) ([traylenator](https://github.com/traylenator))

## [v2.0.0](https://github.com/voxpupuli/puppet-yum/tree/v2.0.0) (2017-06-14)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v1.0.0...v2.0.0)

**Breaking changes:**

- BREAKING: Config create resources pattern [\#37](https://github.com/voxpupuli/puppet-yum/pull/37) ([lamawithonel](https://github.com/lamawithonel))

**Implemented enhancements:**

- Add module data for EPEL [\#44](https://github.com/voxpupuli/puppet-yum/pull/44) ([lamawithonel](https://github.com/lamawithonel))
- Manage yumrepos via data [\#40](https://github.com/voxpupuli/puppet-yum/pull/40) ([lamawithonel](https://github.com/lamawithonel))
- Update README.md [\#39](https://github.com/voxpupuli/puppet-yum/pull/39) ([Yuav](https://github.com/Yuav))
- Be more strict about versionlock strings [\#38](https://github.com/voxpupuli/puppet-yum/pull/38) ([lamawithonel](https://github.com/lamawithonel))

**Fixed bugs:**

- Versionlock release string may contain dots [\#49](https://github.com/voxpupuli/puppet-yum/pull/49) ([traylenator](https://github.com/traylenator))
- Fix typo. [\#45](https://github.com/voxpupuli/puppet-yum/pull/45) ([johntconklin](https://github.com/johntconklin))
- Remove `section` parameter from `yum::config` [\#33](https://github.com/voxpupuli/puppet-yum/pull/33) ([lamawithonel](https://github.com/lamawithonel))
- Comma seperated values puppet3 [\#31](https://github.com/voxpupuli/puppet-yum/pull/31) ([matonb](https://github.com/matonb))

**Closed issues:**

- Class\[Yum\]: has no parameter named 'config\_options' [\#48](https://github.com/voxpupuli/puppet-yum/issues/48)
- Augeas errors arise when applying yum settings on Cent OS 6 clients [\#47](https://github.com/voxpupuli/puppet-yum/issues/47)
- Remove individual configs from init.pp, use create\_resources pattern instead [\#36](https://github.com/voxpupuli/puppet-yum/issues/36)
- Fix versionlock regex [\#35](https://github.com/voxpupuli/puppet-yum/issues/35)
-  yum::config fails with comma separated values [\#21](https://github.com/voxpupuli/puppet-yum/issues/21)

**Merged pull requests:**

- Release 1.0.0 [\#30](https://github.com/voxpupuli/puppet-yum/pull/30) ([bastelfreak](https://github.com/bastelfreak))

## [v1.0.0](https://github.com/voxpupuli/puppet-yum/tree/v1.0.0) (2017-01-14)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.10.0...v1.0.0)

**Implemented enhancements:**

- Update for Puppet 4, remove support for Puppet 3 [\#25](https://github.com/voxpupuli/puppet-yum/pull/25) ([lamawithonel](https://github.com/lamawithonel))

**Merged pull requests:**

- Comma separated values for assumeyes [\#29](https://github.com/voxpupuli/puppet-yum/pull/29) ([matonb](https://github.com/matonb))

## [v0.10.0](https://github.com/voxpupuli/puppet-yum/tree/v0.10.0) (2017-01-11)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.15...v0.10.0)

**Implemented enhancements:**

- Bump min version\_requirement for Puppet + deps [\#22](https://github.com/voxpupuli/puppet-yum/pull/22) ([juniorsysadmin](https://github.com/juniorsysadmin))
- Add parameter clean\_old\_kernels [\#20](https://github.com/voxpupuli/puppet-yum/pull/20) ([treydock](https://github.com/treydock))
- Correct format of fixtures file. [\#14](https://github.com/voxpupuli/puppet-yum/pull/14) ([traylenator](https://github.com/traylenator))

**Merged pull requests:**

- Update changelog and version [\#12](https://github.com/voxpupuli/puppet-yum/pull/12) ([Yuav](https://github.com/Yuav))

## [v0.9.15](https://github.com/voxpupuli/puppet-yum/tree/v0.9.15) (2016-09-26)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.14...v0.9.15)

**Merged pull requests:**

- Added basic spec tests [\#11](https://github.com/voxpupuli/puppet-yum/pull/11) ([Yuav](https://github.com/Yuav))
- Bug: Puppet creates empty key files when using Hiera and create\_resources\(\) [\#7](https://github.com/voxpupuli/puppet-yum/pull/7) ([lklimek](https://github.com/lklimek))
- Manage yum::versionlock with concat [\#6](https://github.com/voxpupuli/puppet-yum/pull/6) ([jpoittevin](https://github.com/jpoittevin))

## [v0.9.14](https://github.com/voxpupuli/puppet-yum/tree/v0.9.14) (2016-08-15)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.13...v0.9.14)

**Merged pull requests:**

- Release 0.9.14 [\#5](https://github.com/voxpupuli/puppet-yum/pull/5) ([jyaworski](https://github.com/jyaworski))

## [v0.9.13](https://github.com/voxpupuli/puppet-yum/tree/v0.9.13) (2016-08-15)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.12...v0.9.13)

**Merged pull requests:**

- Release 0.9.13 [\#4](https://github.com/voxpupuli/puppet-yum/pull/4) ([jyaworski](https://github.com/jyaworski))

## [v0.9.12](https://github.com/voxpupuli/puppet-yum/tree/v0.9.12) (2016-08-12)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.11...v0.9.12)

## [v0.9.11](https://github.com/voxpupuli/puppet-yum/tree/v0.9.11) (2016-08-12)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.10...v0.9.11)

## [v0.9.10](https://github.com/voxpupuli/puppet-yum/tree/v0.9.10) (2016-08-12)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.9...v0.9.10)

## [v0.9.9](https://github.com/voxpupuli/puppet-yum/tree/v0.9.9) (2016-08-12)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.8...v0.9.9)

## [v0.9.8](https://github.com/voxpupuli/puppet-yum/tree/v0.9.8) (2016-08-04)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.8...v0.9.8)

## [0.9.8](https://github.com/voxpupuli/puppet-yum/tree/0.9.8) (2016-05-30)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.7...0.9.8)

## [0.9.7](https://github.com/voxpupuli/puppet-yum/tree/0.9.7) (2016-05-30)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.6...0.9.7)

## [0.9.6](https://github.com/voxpupuli/puppet-yum/tree/0.9.6) (2015-04-29)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.5...0.9.6)

## [0.9.5](https://github.com/voxpupuli/puppet-yum/tree/0.9.5) (2015-04-07)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.4...0.9.5)

## [0.9.4](https://github.com/voxpupuli/puppet-yum/tree/0.9.4) (2014-12-08)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.3...0.9.4)

## [0.9.3](https://github.com/voxpupuli/puppet-yum/tree/0.9.3) (2014-11-06)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.2...0.9.3)

## [0.9.2](https://github.com/voxpupuli/puppet-yum/tree/0.9.2) (2014-09-02)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.1...0.9.2)

## [0.9.1](https://github.com/voxpupuli/puppet-yum/tree/0.9.1) (2014-08-20)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/92c4d392fa2b2a05920798c66f8bf4097bf52d2c...0.9.1)



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*