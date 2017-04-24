# Change Log

## 2017-01-12 - Release 0.8.0

This is the last release with Puppet 3 support!
- Modulesync with latest Vox Pupuli defaults

## 2016-12-28 Release 0.7.1

- selinux::module syncversion parameter now defaults to undef
  to workaround puppet selmodule syncversion bug on CentOS >= 7.3 ([PR #158](https://github.com/voxpupuli/puppet-selinux/pull/158))
- Bugfix for wrong named fact used in selinux::config ([PR #159](https://github.com/voxpupuli/puppet-selinux/pull/159))

## 2016-12-14 Release 0.7.0

- Remove custom fact selinux_custom_policy (not used anymore)
- Default the module prefix to '' (bugfix for CentOS7)


## 2016-12-24 Release 0.6.0

- Modulesync with latest Vox Pupuli defaults
- Add support for Fedora 25
- Update README.md with badges
- Improve spec tests
- Add acceptance tests
- Add Hiera support
- Fix CentOS 6 semanage syntax
- Implement puppet-strings
- Fix: Do relabel if necessary


## 2016-09-08 Release [v0.5.0](https://github.com/voxpupuli/puppet-selinux/tree/v0.5.0)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.4.1...v0.5.0)

**Merged pull requests:**

- Cleanups and dangling issues [\#117](https://github.com/voxpupuli/puppet-selinux/pull/117) ([maage](https://github.com/maage))
- Fixing operatingsystem for Amazon Linux [\#111](https://github.com/voxpupuli/puppet-selinux/pull/111) ([bleiva](https://github.com/bleiva))


## 2016-09-02 Release [0.4.1](https://github.com/voxpupuli/puppet-selinux/tree/v0.4.1)
[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.4.0...v0.4.1)

* This is the first release in the Vox Pupuli namespace (migrated from jfryman)

**Closed issues:**

- missing package dependency in ::module \(RHEL\) [\#112](https://github.com/voxpupuli/puppet-selinux/issues/112)
- Should not be running restorecon like this [\#107](https://github.com/voxpupuli/puppet-selinux/issues/107)
- Duplicate test? [\#102](https://github.com/voxpupuli/puppet-selinux/issues/102)
- Tag a new release [\#96](https://github.com/voxpupuli/puppet-selinux/issues/96)

**Merged pull requests:**

- Release checks fixes [\#113](https://github.com/voxpupuli/puppet-selinux/pull/113) ([maage](https://github.com/maage))
- Removes duplicate package test [\#103](https://github.com/voxpupuli/puppet-selinux/pull/103) ([jfryman](https://github.com/jfryman))

## 2016-06-02 Release [v0.4.0](https://github.com/voxpupuli/puppet-selinux/tree/v0.4.0)
[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.3.1...v0.4.0)

**Closed issues:**

- custom te file loads every time  RE: Only allow refresh in the event that the initial .te file is updated. [\#95](https://github.com/voxpupuli/puppet-selinux/issues/95)
- selinux::module works only if module name contains local\_ by default [\#90](https://github.com/voxpupuli/puppet-selinux/issues/90)
- selinux-module failing on RHEL 7, Makefile not there [\#88](https://github.com/voxpupuli/puppet-selinux/issues/88)
- Problems with package duplicate declaration \(ensure\_packages?\) [\#87](https://github.com/voxpupuli/puppet-selinux/issues/87)
- New release [\#85](https://github.com/voxpupuli/puppet-selinux/issues/85)
- Missing package selinux-policy-devel [\#84](https://github.com/voxpupuli/puppet-selinux/issues/84)
- Fedora 23 package name changed [\#82](https://github.com/voxpupuli/puppet-selinux/issues/82)
- selinux\_custom\_policy.rb:8: syntax error, unexpected ':', expecting kEND [\#76](https://github.com/voxpupuli/puppet-selinux/issues/76)
- default SELinux mode and override possibility [\#65](https://github.com/voxpupuli/puppet-selinux/issues/65)
- Error: CentOS- is not supported [\#52](https://github.com/voxpupuli/puppet-selinux/issues/52)

**Merged pull requests:**

- Use ensure\_packages to install policycoreutils [\#100](https://github.com/voxpupuli/puppet-selinux/pull/100) ([jfryman](https://github.com/jfryman))
- Add recursion support for restorecon. [\#99](https://github.com/voxpupuli/puppet-selinux/pull/99) ([Heidistein](https://github.com/Heidistein))
- Added support for running restorecon after modifying file contexts [\#98](https://github.com/voxpupuli/puppet-selinux/pull/98) ([crayfishx](https://github.com/crayfishx))
- Allow specifying selinux module content [\#94](https://github.com/voxpupuli/puppet-selinux/pull/94) ([lightoze](https://github.com/lightoze))
- Fix module installation [\#92](https://github.com/voxpupuli/puppet-selinux/pull/92) ([toddnni](https://github.com/toddnni))
- Switch to devel package for makefile on RHEL7 and Fedora 21+ [\#89](https://github.com/voxpupuli/puppet-selinux/pull/89) ([ncsutmf](https://github.com/ncsutmf))
- add more lint checks [\#86](https://github.com/voxpupuli/puppet-selinux/pull/86) ([jlambert121](https://github.com/jlambert121))
- Add support for Factor 1.6 [\#55](https://github.com/voxpupuli/puppet-selinux/pull/55) ([Gilum](https://github.com/Gilum))

## 2016-03-08 Release [v0.3.1](https://github.com/voxpupuli/puppet-selinux/tree/v0.3.1)
[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.3.0...v0.3.1)

**Closed issues:**

- selinux::fcontext fails in interesting ways when pathname is regex [\#83](https://github.com/voxpupuli/puppet-selinux/issues/83)
- Error: The parameter 'mode' is declared more than once [\#80](https://github.com/voxpupuli/puppet-selinux/issues/80)
- tagging new release [\#75](https://github.com/voxpupuli/puppet-selinux/issues/75)
- Move to selmodule/selboolean for selinux::module/boolean? [\#70](https://github.com/voxpupuli/puppet-selinux/issues/70)

**Merged pull requests:**

- The parameter 'mode' is declared more than once [\#81](https://github.com/voxpupuli/puppet-selinux/pull/81) ([edestecd](https://github.com/edestecd))
- Add syncversion parameter [\#78](https://github.com/voxpupuli/puppet-selinux/pull/78) ([mhjacks](https://github.com/mhjacks))
- Fix Issue \#76 [\#77](https://github.com/voxpupuli/puppet-selinux/pull/77) ([Thubo](https://github.com/Thubo))

## 2015-12-13 Release [v0.3.0](https://github.com/voxpupuli/puppet-selinux/tree/v0.3.0)
[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.2.6...v0.3.0)

**Closed issues:**

- Allow disabling of selinux package management [\#71](https://github.com/voxpupuli/puppet-selinux/issues/71)
- why is disabled the default mode? [\#68](https://github.com/voxpupuli/puppet-selinux/issues/68)
- What license is this software provided under? [\#66](https://github.com/voxpupuli/puppet-selinux/issues/66)

**Merged pull requests:**

- Pivot to internal types [\#73](https://github.com/voxpupuli/puppet-selinux/pull/73) ([jyaworski](https://github.com/jyaworski))
- Allow custom package name and management [\#72](https://github.com/voxpupuli/puppet-selinux/pull/72) ([jyaworski](https://github.com/jyaworski))
- Switch default behavior to not manage selinux [\#67](https://github.com/voxpupuli/puppet-selinux/pull/67) ([thrnio](https://github.com/thrnio))
- Whitespace lint fixes [\#63](https://github.com/voxpupuli/puppet-selinux/pull/63) ([mld](https://github.com/mld))
- Implements SELinux type checking and ensuring. [\#62](https://github.com/voxpupuli/puppet-selinux/pull/62) ([ElvenSpellmaker](https://github.com/ElvenSpellmaker))
- added hiera support [\#49](https://github.com/voxpupuli/puppet-selinux/pull/49) ([dacron](https://github.com/dacron))
- Make port exec statement unique for protocol [\#37](https://github.com/voxpupuli/puppet-selinux/pull/37) ([dlevene1](https://github.com/dlevene1))

## 2015-10-20 Release [v0.2.6](https://github.com/voxpupuli/puppet-selinux/tree/v0.2.6)
[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.2.5...v0.2.6)

**Closed issues:**

- Custom Module's reload on every puppet run. [\#56](https://github.com/voxpupuli/puppet-selinux/issues/56)
- no tag for 0.2.5 [\#51](https://github.com/voxpupuli/puppet-selinux/issues/51)

**Merged pull requests:**

- Fix for selinux::module absent case failed notify [\#59](https://github.com/voxpupuli/puppet-selinux/pull/59) ([ps-jay](https://github.com/ps-jay))
- Fallback to lsbmajdistrelease, if puppet version is \< 3.0 [\#54](https://github.com/voxpupuli/puppet-selinux/pull/54) ([jkroepke](https://github.com/jkroepke))
- Add Permissive to puppet-selinux module [\#53](https://github.com/voxpupuli/puppet-selinux/pull/53) ([jewnix](https://github.com/jewnix))

## 2015-08-05 Release [v0.2.5](https://github.com/voxpupuli/puppet-selinux/tree/v0.2.5)
[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.2.3...v0.2.5)

**Closed issues:**

- port match is not correct enough [\#39](https://github.com/voxpupuli/puppet-selinux/issues/39)
- "checkloaded" exec always schedules build/install on RHEL7 / CentOS 7 [\#27](https://github.com/voxpupuli/puppet-selinux/issues/27)

**Merged pull requests:**

- Fixes workaround, fixes \#27 [\#46](https://github.com/voxpupuli/puppet-selinux/pull/46) ([belminf](https://github.com/belminf))
- fix EL variant != 'RedHat' regression [\#44](https://github.com/voxpupuli/puppet-selinux/pull/44) ([jhoblitt](https://github.com/jhoblitt))
- fedora support [\#43](https://github.com/voxpupuli/puppet-selinux/pull/43) ([jhoblitt](https://github.com/jhoblitt))
- puppet 4 support [\#42](https://github.com/voxpupuli/puppet-selinux/pull/42) ([jhoblitt](https://github.com/jhoblitt))
- improve port match [\#41](https://github.com/voxpupuli/puppet-selinux/pull/41) ([kveerman](https://github.com/kveerman))
- Bug fix for declaring multiple selinux::module types [\#40](https://github.com/voxpupuli/puppet-selinux/pull/40) ([apatik](https://github.com/apatik))
- Use "defined" instead of "getvar" to protect against undefined variables when strict\_variables=yes [\#34](https://github.com/voxpupuli/puppet-selinux/pull/34) ([robinbowes](https://github.com/robinbowes))
- Workaround for RH 7 variants [\#33](https://github.com/voxpupuli/puppet-selinux/pull/33) ([robrankin](https://github.com/robrankin))
- Fix to work with strict\_variables=true [\#32](https://github.com/voxpupuli/puppet-selinux/pull/32) ([robinbowes](https://github.com/robinbowes))

## 2015-03-03 Rlease [v0.2.3](https://github.com/voxpupuli/puppet-selinux/tree/v0.2.3)
[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.2.2...v0.2.3)

**Merged pull requests:**

- add spec tests, update validations, cleanup [\#31](https://github.com/voxpupuli/puppet-selinux/pull/31) ([jlambert121](https://github.com/jlambert121))
- Better compatibility with CentOS 7 [\#29](https://github.com/voxpupuli/puppet-selinux/pull/29) ([djjudas21](https://github.com/djjudas21))
- fix change-selinux-status in case of selinux disabled [\#28](https://github.com/voxpupuli/puppet-selinux/pull/28) ([cristifalcas](https://github.com/cristifalcas))

## 2015-01-19 Release [v0.2.2](https://github.com/voxpupuli/puppet-selinux/tree/v0.2.2)
[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.2.0...v0.2.2)

**Merged pull requests:**

- reverting previous lint change [\#26](https://github.com/voxpupuli/puppet-selinux/pull/26) ([robrankin](https://github.com/robrankin))
- REPLACE config file route [\#25](https://github.com/voxpupuli/puppet-selinux/pull/25) ([rmacian](https://github.com/rmacian))
- Add OS compatibility data for Puppet Forge [\#24](https://github.com/voxpupuli/puppet-selinux/pull/24) ([djjudas21](https://github.com/djjudas21))
- Lint fixes [\#23](https://github.com/voxpupuli/puppet-selinux/pull/23) ([djjudas21](https://github.com/djjudas21))
- Switch to a more robust way of changing SELinux status [\#22](https://github.com/voxpupuli/puppet-selinux/pull/22) ([djjudas21](https://github.com/djjudas21))

## 2015-01-12 Release [v0.2.0](https://github.com/voxpupuli/puppet-selinux/tree/v0.2.0)
**Closed issues:**

- Release to Puppet Forge? [\#7](https://github.com/voxpupuli/puppet-selinux/issues/7)
- module installation doesn't check current status of modules [\#6](https://github.com/voxpupuli/puppet-selinux/issues/6)
- /etc/sysconfig/selinux symlink removed [\#2](https://github.com/voxpupuli/puppet-selinux/issues/2)

**Merged pull requests:**

- Added Support for defining file types in fcontext defined type [\#21](https://github.com/voxpupuli/puppet-selinux/pull/21) ([ghost](https://github.com/ghost))
- fix dependency name [\#20](https://github.com/voxpupuli/puppet-selinux/pull/20) ([vchepkov](https://github.com/vchepkov))
- Add missing quotes to exec statement [\#19](https://github.com/voxpupuli/puppet-selinux/pull/19) ([lattwood](https://github.com/lattwood))
- puppet 3.7 complaines about 'Error: Failed to apply catalog: Parameter c... [\#18](https://github.com/voxpupuli/puppet-selinux/pull/18) ([cristifalcas](https://github.com/cristifalcas))
- add metadata.json [\#17](https://github.com/voxpupuli/puppet-selinux/pull/17) ([cristifalcas](https://github.com/cristifalcas))
- allow packages to be upgraded [\#16](https://github.com/voxpupuli/puppet-selinux/pull/16) ([cristifalcas](https://github.com/cristifalcas))
- adds RHEL 7 support, fixes missing dependency on package [\#15](https://github.com/voxpupuli/puppet-selinux/pull/15) ([fuero](https://github.com/fuero))
- Linting fixes [\#14](https://github.com/voxpupuli/puppet-selinux/pull/14) ([steeef](https://github.com/steeef))
- support for restorecond and support for restorecond [\#12](https://github.com/voxpupuli/puppet-selinux/pull/12) ([franzs](https://github.com/franzs))
- Add semanage::port functionality [\#11](https://github.com/voxpupuli/puppet-selinux/pull/11) ([mattwillsher](https://github.com/mattwillsher))
- Puppet Lint/Style fixes [\#10](https://github.com/voxpupuli/puppet-selinux/pull/10) ([mattiasgeniar](https://github.com/mattiasgeniar))
- add option to build with the makefile [\#9](https://github.com/voxpupuli/puppet-selinux/pull/9) ([tjikkun](https://github.com/tjikkun))
- check if module is actually loaded [\#8](https://github.com/voxpupuli/puppet-selinux/pull/8) ([tjikkun](https://github.com/tjikkun))
- Updated to support different el versions [\#5](https://github.com/voxpupuli/puppet-selinux/pull/5) ([thoraxe](https://github.com/thoraxe))
- File context - added method for setting file contexts [\#4](https://github.com/voxpupuli/puppet-selinux/pull/4) ([thoraxe](https://github.com/thoraxe))
- Fix symlink being removed [\#3](https://github.com/voxpupuli/puppet-selinux/pull/3) ([lboynton](https://github.com/lboynton))
- Cleaned up lint errors. [\#1](https://github.com/voxpupuli/puppet-selinux/pull/1) ([eshamow](https://github.com/eshamow))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
