# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v3.0.0](https://github.com/voxpupuli/puppet-selinux/tree/v3.0.0) (2019-06-17)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v2.0.0...v3.0.0)

**Breaking changes:**

- Python 3 semanage is named python3-libsemanage; Drop Fedora 26/27 support [\#287](https://github.com/voxpupuli/puppet-selinux/pull/287) ([ehelms](https://github.com/ehelms))

**Fixed bugs:**

- Load system policy contexts [\#290](https://github.com/voxpupuli/puppet-selinux/pull/290) ([ekohl](https://github.com/ekohl))

**Closed issues:**

- Fcontext fails on re-run on newer platforms [\#288](https://github.com/voxpupuli/puppet-selinux/issues/288)

## [v2.0.0](https://github.com/voxpupuli/puppet-selinux/tree/v2.0.0) (2019-05-15)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v1.6.1...v2.0.0)

**Breaking changes:**

- modulesync 2.5.1 and drop Puppet 4 [\#282](https://github.com/voxpupuli/puppet-selinux/pull/282) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Allow `puppetlabs/stdlib` 6.x [\#284](https://github.com/voxpupuli/puppet-selinux/pull/284) ([alexjfisher](https://github.com/alexjfisher))
- Builder improvements and acceptance tests [\#281](https://github.com/voxpupuli/puppet-selinux/pull/281) ([ekohl](https://github.com/ekohl))
- Simplify parameter handling [\#280](https://github.com/voxpupuli/puppet-selinux/pull/280) ([ekohl](https://github.com/ekohl))

**Fixed bugs:**

- fix syntax of config\_mode fact example [\#275](https://github.com/voxpupuli/puppet-selinux/pull/275) ([evgeni](https://github.com/evgeni))

**Merged pull requests:**

- Update puppet strings and use assert\_private [\#279](https://github.com/voxpupuli/puppet-selinux/pull/279) ([ekohl](https://github.com/ekohl))

## [v1.6.1](https://github.com/voxpupuli/puppet-selinux/tree/v1.6.1) (2018-10-05)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v1.6.0...v1.6.1)

**Merged pull requests:**

- modulesync 2.1.0 & add puppet 6 support [\#271](https://github.com/voxpupuli/puppet-selinux/pull/271) ([bastelfreak](https://github.com/bastelfreak))

## [v1.6.0](https://github.com/voxpupuli/puppet-selinux/tree/v1.6.0) (2018-09-11)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v1.5.3...v1.6.0)

**Implemented enhancements:**

- Add support for installing pre-compiled policy packages [\#253](https://github.com/voxpupuli/puppet-selinux/pull/253) ([oranenj](https://github.com/oranenj))

**Closed issues:**

- New release [\#265](https://github.com/voxpupuli/puppet-selinux/issues/265)

**Merged pull requests:**

- add initial REFERENCE.md [\#268](https://github.com/voxpupuli/puppet-selinux/pull/268) ([bastelfreak](https://github.com/bastelfreak))

## [v1.5.3](https://github.com/voxpupuli/puppet-selinux/tree/v1.5.3) (2018-08-31)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v1.5.2...v1.5.3)

**Closed issues:**

- Puppet change for each selinux module for every Puppet run [\#261](https://github.com/voxpupuli/puppet-selinux/issues/261)
- Calls to $::selinux facts should use the $facts hash [\#258](https://github.com/voxpupuli/puppet-selinux/issues/258)

**Merged pull requests:**

- allow puppetlabs/stdlib 5.x [\#264](https://github.com/voxpupuli/puppet-selinux/pull/264) ([bastelfreak](https://github.com/bastelfreak))
- Switch to "facts" hash for SELinux facts [\#259](https://github.com/voxpupuli/puppet-selinux/pull/259) ([trevor-vaughan](https://github.com/trevor-vaughan))
- Remove docker nodesets [\#257](https://github.com/voxpupuli/puppet-selinux/pull/257) ([bastelfreak](https://github.com/bastelfreak))
- drop EOL OSs; fix puppet version range [\#256](https://github.com/voxpupuli/puppet-selinux/pull/256) ([bastelfreak](https://github.com/bastelfreak))

## [v1.5.2](https://github.com/voxpupuli/puppet-selinux/tree/v1.5.2) (2018-01-20)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v1.5.1...v1.5.2)

**Fixed bugs:**

- Update and check runtime SELinux status correcty [\#249](https://github.com/voxpupuli/puppet-selinux/pull/249) ([weaselshit](https://github.com/weaselshit))

**Closed issues:**

- Skip exec "change-selinux-status-to-disabled" when current mode is enforcing or permissive [\#245](https://github.com/voxpupuli/puppet-selinux/issues/245)
- Module uses deprecated hiera\_hash\(\) function  [\#238](https://github.com/voxpupuli/puppet-selinux/issues/238)

**Merged pull requests:**

- Extend enforcing to disabled tests [\#250](https://github.com/voxpupuli/puppet-selinux/pull/250) ([vinzent](https://github.com/vinzent))

## [v1.5.1](https://github.com/voxpupuli/puppet-selinux/tree/v1.5.1) (2018-01-04)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v1.5.0...v1.5.1)

**Fixed bugs:**

- Fixing change-selinux-status-to-disabled exec [\#246](https://github.com/voxpupuli/puppet-selinux/pull/246) ([bjvrielink](https://github.com/bjvrielink))

**Merged pull requests:**

- Release 1.5.1 [\#248](https://github.com/voxpupuli/puppet-selinux/pull/248) ([bastelfreak](https://github.com/bastelfreak))

## [v1.5.0](https://github.com/voxpupuli/puppet-selinux/tree/v1.5.0) (2017-12-15)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v1.4.0...v1.5.0)

**Merged pull requests:**

- Release 1.5.0 [\#244](https://github.com/voxpupuli/puppet-selinux/pull/244) ([vinzent](https://github.com/vinzent))
- Add exec\_restorecon to hiera calls [\#243](https://github.com/voxpupuli/puppet-selinux/pull/243) ([FStelzer](https://github.com/FStelzer))

## [v1.4.0](https://github.com/voxpupuli/puppet-selinux/tree/v1.4.0) (2017-11-19)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v1.3.0...v1.4.0)

**Implemented enhancements:**

- Add Fedora 26 and 27 to supported distros [\#240](https://github.com/voxpupuli/puppet-selinux/pull/240) ([vinzent](https://github.com/vinzent))

**Merged pull requests:**

- release 1.4.0 [\#242](https://github.com/voxpupuli/puppet-selinux/pull/242) ([bastelfreak](https://github.com/bastelfreak))
- bump puppet version dependency to \>= 4.7.1 \< 6.0.0 [\#241](https://github.com/voxpupuli/puppet-selinux/pull/241) ([bastelfreak](https://github.com/bastelfreak))
- Remove Fedora 24 support statement [\#239](https://github.com/voxpupuli/puppet-selinux/pull/239) ([vinzent](https://github.com/vinzent))

## [v1.3.0](https://github.com/voxpupuli/puppet-selinux/tree/v1.3.0) (2017-09-17)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v1.2.0...v1.3.0)

**Implemented enhancements:**

- Implement use of force option for restorecon [\#229](https://github.com/voxpupuli/puppet-selinux/pull/229) ([slconley](https://github.com/slconley))

**Closed issues:**

- Amazon Linux support [\#230](https://github.com/voxpupuli/puppet-selinux/issues/230)
- Tests fail:  Could not parse for environment rp\_env: Illegal variable name [\#225](https://github.com/voxpupuli/puppet-selinux/issues/225)

**Merged pull requests:**

- release 1.3.0 [\#236](https://github.com/voxpupuli/puppet-selinux/pull/236) ([bastelfreak](https://github.com/bastelfreak))
- Test disabling of SELinux [\#233](https://github.com/voxpupuli/puppet-selinux/pull/233) ([vinzent](https://github.com/vinzent))
- Add Amazon Linux support [\#231](https://github.com/voxpupuli/puppet-selinux/pull/231) ([clinty](https://github.com/clinty))
- Re-enable restorecon spec test [\#228](https://github.com/voxpupuli/puppet-selinux/pull/228) ([vinzent](https://github.com/vinzent))

## [v1.2.0](https://github.com/voxpupuli/puppet-selinux/tree/v1.2.0) (2017-07-02)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v1.1.0...v1.2.0)

**Implemented enhancements:**

- Declare Puppet 5 compatability [\#226](https://github.com/voxpupuli/puppet-selinux/pull/226) ([vinzent](https://github.com/vinzent))

**Merged pull requests:**

- Release 1.2.0 [\#227](https://github.com/voxpupuli/puppet-selinux/pull/227) ([vinzent](https://github.com/vinzent))

## [v1.1.0](https://github.com/voxpupuli/puppet-selinux/tree/v1.1.0) (2017-05-11)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v1.0.0...v1.1.0)

**Implemented enhancements:**

- Make use of the stdlib puppet\_vardir fact instead of a custom one [\#217](https://github.com/voxpupuli/puppet-selinux/pull/217) ([oranenj](https://github.com/oranenj))
- Allow specifying module content inline [\#214](https://github.com/voxpupuli/puppet-selinux/pull/214) ([lightoze](https://github.com/lightoze))

**Fixed bugs:**

- config.pp creates tmp as file but selinux\_build\_module\_simple.sh wants to create a dir [\#215](https://github.com/voxpupuli/puppet-selinux/issues/215)

**Merged pull requests:**

- Release 1.1.0 [\#219](https://github.com/voxpupuli/puppet-selinux/pull/219) ([oranenj](https://github.com/oranenj))
- Fedora 26 uses the same package\_name as Fedora 25 [\#218](https://github.com/voxpupuli/puppet-selinux/pull/218) ([logic](https://github.com/logic))
- Ensure the module build tmp/ directory is actually a directory [\#216](https://github.com/voxpupuli/puppet-selinux/pull/216) ([oranenj](https://github.com/oranenj))

## [v1.0.0](https://github.com/voxpupuli/puppet-selinux/tree/v1.0.0) (2017-04-02)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.8.0...v1.0.0)

**Breaking changes:**

- Remove CentOS 5 support [\#190](https://github.com/voxpupuli/puppet-selinux/issues/190)
- BREAKING: Redesign selinux::module parameters [\#178](https://github.com/voxpupuli/puppet-selinux/issues/178)
- BREAKING: Remove restorecond management support [\#206](https://github.com/voxpupuli/puppet-selinux/pull/206) ([oranenj](https://github.com/oranenj))
- BREAKING: Remove Amazon Linux support [\#193](https://github.com/voxpupuli/puppet-selinux/pull/193) ([vinzent](https://github.com/vinzent))
- BREAKING: Remove support for EL5 and Fedora \< 24 [\#192](https://github.com/voxpupuli/puppet-selinux/pull/192) ([vinzent](https://github.com/vinzent))
- BREAKING: Selinux permissive type [\#183](https://github.com/voxpupuli/puppet-selinux/pull/183) ([oranenj](https://github.com/oranenj))
- BREAKING: Add selinux\_fcontext and selinux\_fcontext\_equivalence types [\#177](https://github.com/voxpupuli/puppet-selinux/pull/177) ([oranenj](https://github.com/oranenj))
- BREAKING: Downgrade enforcing to permissive configuration when SELinux is disabled [\#175](https://github.com/voxpupuli/puppet-selinux/pull/175) ([oranenj](https://github.com/oranenj))
- BREAKING: Add a selinux\_port type and provider [\#174](https://github.com/voxpupuli/puppet-selinux/pull/174) ([oranenj](https://github.com/oranenj))

**Implemented enhancements:**

- Automatically order resources to not produce runtime failures [\#147](https://github.com/voxpupuli/puppet-selinux/issues/147)
- selinux::module should not manage files in /usr [\#146](https://github.com/voxpupuli/puppet-selinux/issues/146)
- Remove dependency on make and selinux-policy-devel in selinux::module [\#141](https://github.com/voxpupuli/puppet-selinux/issues/141)
- Add a convenience wrapper for restorecon execs [\#205](https://github.com/voxpupuli/puppet-selinux/pull/205) ([oranenj](https://github.com/oranenj))
- Replace all validate functions with datatypes [\#201](https://github.com/voxpupuli/puppet-selinux/pull/201) ([bastelfreak](https://github.com/bastelfreak))
- Convert selinux::boolean to puppet types [\#198](https://github.com/voxpupuli/puppet-selinux/pull/198) ([oranenj](https://github.com/oranenj))
- Document known problems / limitations [\#171](https://github.com/voxpupuli/puppet-selinux/pull/171) ([vinzent](https://github.com/vinzent))

**Fixed bugs:**

- Can't remove permissive domain [\#165](https://github.com/voxpupuli/puppet-selinux/issues/165)
- Silently doesn't remove port context [\#164](https://github.com/voxpupuli/puppet-selinux/issues/164)
- selinux class parameters boolean, fcontext, module, permissive and port are ignored [\#148](https://github.com/voxpupuli/puppet-selinux/issues/148)
- This module accepts invalid config for port [\#119](https://github.com/voxpupuli/puppet-selinux/issues/119)
- Actually pass ensure to the wrapped selinux\_fcontext resource [\#210](https://github.com/voxpupuli/puppet-selinux/pull/210) ([oranenj](https://github.com/oranenj))
- Fix new puppet-lint complaints about ordering arrows [\#208](https://github.com/voxpupuli/puppet-selinux/pull/208) ([oranenj](https://github.com/oranenj))
- Don't accept udp6 and tcp6 as protocol name with selinux::port [\#181](https://github.com/voxpupuli/puppet-selinux/pull/181) ([vinzent](https://github.com/vinzent))
- Use declared parameters [\#180](https://github.com/voxpupuli/puppet-selinux/pull/180) ([vinzent](https://github.com/vinzent))

**Closed issues:**

- Release 1.0.0 [\#184](https://github.com/voxpupuli/puppet-selinux/issues/184)
- order of file contexts [\#121](https://github.com/voxpupuli/puppet-selinux/issues/121)
- selinux::module fails when module contains more than .te file [\#118](https://github.com/voxpupuli/puppet-selinux/issues/118)
- Looking for Maintainer [\#106](https://github.com/voxpupuli/puppet-selinux/issues/106)
- Puppet Agent 1.5 \(Puppet 4.5 Error\) [\#97](https://github.com/voxpupuli/puppet-selinux/issues/97)
- Unable to modify port via port.pp [\#93](https://github.com/voxpupuli/puppet-selinux/issues/93)
- When using 'module' to install selinux-module the selinux-mode is set to disabled. [\#64](https://github.com/voxpupuli/puppet-selinux/issues/64)
- Problem with undef from left operand of 'in' at module.pp:38 [\#61](https://github.com/voxpupuli/puppet-selinux/issues/61)
- Adding a port gets an error the first time [\#38](https://github.com/voxpupuli/puppet-selinux/issues/38)

**Merged pull requests:**

- Prepare 1.0.0 [\#211](https://github.com/voxpupuli/puppet-selinux/pull/211) ([oranenj](https://github.com/oranenj))
- Fix resource reference issue when removing fcontexts [\#209](https://github.com/voxpupuli/puppet-selinux/pull/209) ([oranenj](https://github.com/oranenj))
- Doc fixes [\#204](https://github.com/voxpupuli/puppet-selinux/pull/204) ([oranenj](https://github.com/oranenj))
- Fix spelling for supported type in README [\#203](https://github.com/voxpupuli/puppet-selinux/pull/203) ([ardrigh](https://github.com/ardrigh))
- Update strings docs [\#197](https://github.com/voxpupuli/puppet-selinux/pull/197) ([vinzent](https://github.com/vinzent))
- Remove tests for Fedora 19-23 and CentOS 5 [\#194](https://github.com/voxpupuli/puppet-selinux/pull/194) ([vinzent](https://github.com/vinzent))
- Fix puppet strings warnings and minor README.md update [\#191](https://github.com/voxpupuli/puppet-selinux/pull/191) ([vinzent](https://github.com/vinzent))
- Rubocop config fixes [\#182](https://github.com/voxpupuli/puppet-selinux/pull/182) ([vinzent](https://github.com/vinzent))
- modulesync 0.19.0 [\#176](https://github.com/voxpupuli/puppet-selinux/pull/176) ([bastelfreak](https://github.com/bastelfreak))
- Fix broken link to puppet strings documentation [\#173](https://github.com/voxpupuli/puppet-selinux/pull/173) ([vinzent](https://github.com/vinzent))
- Update inline doc to puppet-strings [\#172](https://github.com/voxpupuli/puppet-selinux/pull/172) ([vinzent](https://github.com/vinzent))
- Modulesync 0.18.0 [\#170](https://github.com/voxpupuli/puppet-selinux/pull/170) ([bastelfreak](https://github.com/bastelfreak))
- \(GH-147\) Add ordering of resources [\#167](https://github.com/voxpupuli/puppet-selinux/pull/167) ([vinzent](https://github.com/vinzent))

## [v0.8.0](https://github.com/voxpupuli/puppet-selinux/tree/v0.8.0) (2017-01-12)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.7.1...v0.8.0)

**Closed issues:**

- Acceptance test fails for /tmp/test\_selinux\_fcontext on Fedora 24 [\#157](https://github.com/voxpupuli/puppet-selinux/issues/157)
- define selinux::module broken in CentOS 7.3 [\#142](https://github.com/voxpupuli/puppet-selinux/issues/142)
- Module in the Puppet forge is not up to date [\#135](https://github.com/voxpupuli/puppet-selinux/issues/135)

**Merged pull requests:**

- release 0.8.0 [\#168](https://github.com/voxpupuli/puppet-selinux/pull/168) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 0.16.7 [\#163](https://github.com/voxpupuli/puppet-selinux/pull/163) ([bastelfreak](https://github.com/bastelfreak))

## [v0.7.1](https://github.com/voxpupuli/puppet-selinux/tree/v0.7.1) (2016-12-28)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.7.0...v0.7.1)

**Closed issues:**

- prefix causes repeated module reinstalls [\#129](https://github.com/voxpupuli/puppet-selinux/issues/129)

**Merged pull requests:**

- Release 0.7.1 [\#160](https://github.com/voxpupuli/puppet-selinux/pull/160) ([vinzent](https://github.com/vinzent))
- Fix usage of non-existent $::selinux\_enabled fact [\#159](https://github.com/voxpupuli/puppet-selinux/pull/159) ([vinzent](https://github.com/vinzent))
- Default to undef for syncversion parameter in selinux::module  [\#158](https://github.com/voxpupuli/puppet-selinux/pull/158) ([vinzent](https://github.com/vinzent))
- Remove mentions of Ruby requirements in README [\#156](https://github.com/voxpupuli/puppet-selinux/pull/156) ([juniorsysadmin](https://github.com/juniorsysadmin))

## [v0.7.0](https://github.com/voxpupuli/puppet-selinux/tree/v0.7.0) (2016-12-24)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.6.0...v0.7.0)

**Merged pull requests:**

- release 0.7.0 [\#155](https://github.com/voxpupuli/puppet-selinux/pull/155) ([bastelfreak](https://github.com/bastelfreak))
- Remove custom fact selinux\_custom\_policy [\#154](https://github.com/voxpupuli/puppet-selinux/pull/154) ([vinzent](https://github.com/vinzent))
- Default module prefix now '' [\#140](https://github.com/voxpupuli/puppet-selinux/pull/140) ([traylenator](https://github.com/traylenator))
- Fix type doc [\#134](https://github.com/voxpupuli/puppet-selinux/pull/134) ([kausar007](https://github.com/kausar007))

## [v0.6.0](https://github.com/voxpupuli/puppet-selinux/tree/v0.6.0) (2016-12-24)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.5.0...v0.6.0)

**Closed issues:**

- Ensure a complete relabeling when switching from disabled to permissive or enforcing [\#149](https://github.com/voxpupuli/puppet-selinux/issues/149)
- selinux::fcontext runs "semanage .. -f a" by default - not supported on RHEL6 [\#133](https://github.com/voxpupuli/puppet-selinux/issues/133)
- Missing spec test for permissive defined type [\#130](https://github.com/voxpupuli/puppet-selinux/issues/130)
- No Hiera support [\#104](https://github.com/voxpupuli/puppet-selinux/issues/104)
- selinux\_current\_mode core fact no longer exists [\#74](https://github.com/voxpupuli/puppet-selinux/issues/74)
- Amazon Linux \( CentOS \) is not supported [\#58](https://github.com/voxpupuli/puppet-selinux/issues/58)

**Merged pull requests:**

- Modulesync 0.16.6 & Release 0.6.0 [\#152](https://github.com/voxpupuli/puppet-selinux/pull/152) ([bastelfreak](https://github.com/bastelfreak))
- Create /.autorelabel when switching from disabled [\#151](https://github.com/voxpupuli/puppet-selinux/pull/151) ([vinzent](https://github.com/vinzent))
- Update to puppet-strings doc in selinux class [\#150](https://github.com/voxpupuli/puppet-selinux/pull/150) ([vinzent](https://github.com/vinzent))
- Add acceptance tests [\#145](https://github.com/voxpupuli/puppet-selinux/pull/145) ([vinzent](https://github.com/vinzent))
- Set puppet minimum version\_requirement to 3.8.7 [\#144](https://github.com/voxpupuli/puppet-selinux/pull/144) ([juniorsysadmin](https://github.com/juniorsysadmin))
- modulesync 0.16.4 [\#143](https://github.com/voxpupuli/puppet-selinux/pull/143) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 0.16.3 [\#139](https://github.com/voxpupuli/puppet-selinux/pull/139) ([bastelfreak](https://github.com/bastelfreak))
- Fixes \#133 Use semange -f 'all files' on RHEL6 [\#138](https://github.com/voxpupuli/puppet-selinux/pull/138) ([traylenator](https://github.com/traylenator))
- Use rspec-puppet-facts in all places [\#137](https://github.com/voxpupuli/puppet-selinux/pull/137) ([traylenator](https://github.com/traylenator))
- Update README with ruby 1.8 status [\#136](https://github.com/voxpupuli/puppet-selinux/pull/136) ([alexjfisher](https://github.com/alexjfisher))
- add argument variable for selinux::port [\#132](https://github.com/voxpupuli/puppet-selinux/pull/132) ([jodast](https://github.com/jodast))
- Fixes Issue-130 - No rspec for permissive [\#131](https://github.com/voxpupuli/puppet-selinux/pull/131) ([ryayon](https://github.com/ryayon))
- Fixes Issue-104 - No Hiera support [\#128](https://github.com/voxpupuli/puppet-selinux/pull/128) ([ryayon](https://github.com/ryayon))
- modulesync 0.15.0 [\#127](https://github.com/voxpupuli/puppet-selinux/pull/127) ([bastelfreak](https://github.com/bastelfreak))
- params.pp needs to know about Fedora 25 [\#126](https://github.com/voxpupuli/puppet-selinux/pull/126) ([logic](https://github.com/logic))
- Rubocop fixes [\#125](https://github.com/voxpupuli/puppet-selinux/pull/125) ([alexjfisher](https://github.com/alexjfisher))
- Add missing badges [\#124](https://github.com/voxpupuli/puppet-selinux/pull/124) ([dhoppe](https://github.com/dhoppe))
- Update based on voxpupuli/modulesync\_config 0.14.1 [\#123](https://github.com/voxpupuli/puppet-selinux/pull/123) ([dhoppe](https://github.com/dhoppe))
- modulesync 0.13.0 [\#122](https://github.com/voxpupuli/puppet-selinux/pull/122) ([bbriggs](https://github.com/bbriggs))

## [v0.5.0](https://github.com/voxpupuli/puppet-selinux/tree/v0.5.0) (2016-09-08)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.4.1...v0.5.0)

**Merged pull requests:**

- Release 0.5.0 [\#120](https://github.com/voxpupuli/puppet-selinux/pull/120) ([bastelfreak](https://github.com/bastelfreak))
- Cleanups and dangling issues [\#117](https://github.com/voxpupuli/puppet-selinux/pull/117) ([maage](https://github.com/maage))
- Fixing operatingsystem for Amazon Linux [\#111](https://github.com/voxpupuli/puppet-selinux/pull/111) ([bleiva](https://github.com/bleiva))

## [v0.4.1](https://github.com/voxpupuli/puppet-selinux/tree/v0.4.1) (2016-09-02)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.4.0...v0.4.1)

**Closed issues:**

- missing package dependency in ::module \(RHEL\) [\#112](https://github.com/voxpupuli/puppet-selinux/issues/112)
- fcontext should check for the existence of $filepath before running restorecon [\#108](https://github.com/voxpupuli/puppet-selinux/issues/108)
- Should not be running restorecon like this [\#107](https://github.com/voxpupuli/puppet-selinux/issues/107)
- fcontext detection fails if pattern contains square brackets [\#105](https://github.com/voxpupuli/puppet-selinux/issues/105)
- Duplicate test? [\#102](https://github.com/voxpupuli/puppet-selinux/issues/102)
- Tag a new release [\#96](https://github.com/voxpupuli/puppet-selinux/issues/96)

**Merged pull requests:**

- modulesync 0.12.5 [\#116](https://github.com/voxpupuli/puppet-selinux/pull/116) ([bastelfreak](https://github.com/bastelfreak))
- Release checks fixes [\#113](https://github.com/voxpupuli/puppet-selinux/pull/113) ([maage](https://github.com/maage))
- Removes duplicate package test [\#103](https://github.com/voxpupuli/puppet-selinux/pull/103) ([jfryman](https://github.com/jfryman))

## [v0.4.0](https://github.com/voxpupuli/puppet-selinux/tree/v0.4.0) (2016-06-02)

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

## [v0.3.1](https://github.com/voxpupuli/puppet-selinux/tree/v0.3.1) (2016-03-08)

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

## [v0.3.0](https://github.com/voxpupuli/puppet-selinux/tree/v0.3.0) (2015-12-13)

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

## [v0.2.6](https://github.com/voxpupuli/puppet-selinux/tree/v0.2.6) (2015-10-20)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.2.5...v0.2.6)

**Closed issues:**

- Custom Module's reload on every puppet run. [\#56](https://github.com/voxpupuli/puppet-selinux/issues/56)
- no tag for 0.2.5 [\#51](https://github.com/voxpupuli/puppet-selinux/issues/51)

**Merged pull requests:**

- Fix for selinux::module absent case failed notify [\#59](https://github.com/voxpupuli/puppet-selinux/pull/59) ([ps-jay](https://github.com/ps-jay))
- Fallback to lsbmajdistrelease, if puppet version is \< 3.0 [\#54](https://github.com/voxpupuli/puppet-selinux/pull/54) ([jkroepke](https://github.com/jkroepke))
- Add Permissive to puppet-selinux module [\#53](https://github.com/voxpupuli/puppet-selinux/pull/53) ([jewnix](https://github.com/jewnix))

## [v0.2.5](https://github.com/voxpupuli/puppet-selinux/tree/v0.2.5) (2015-08-05)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.2.3...v0.2.5)

**Closed issues:**

- port match is not correct enough [\#39](https://github.com/voxpupuli/puppet-selinux/issues/39)
- "checkloaded" exec always schedules build/install on RHEL7 / CentOS 7 [\#27](https://github.com/voxpupuli/puppet-selinux/issues/27)

**Merged pull requests:**

- Fixes workaround, fixes \#27 [\#46](https://github.com/voxpupuli/puppet-selinux/pull/46) ([belminf](https://github.com/belminf))
- fix EL variant != 'RedHat' regression [\#44](https://github.com/voxpupuli/puppet-selinux/pull/44) ([jhoblitt](https://github.com/jhoblitt))
- fedora support [\#43](https://github.com/voxpupuli/puppet-selinux/pull/43) ([jhoblitt](https://github.com/jhoblitt))
- puppet 4 support [\#42](https://github.com/voxpupuli/puppet-selinux/pull/42) ([jhoblitt](https://github.com/jhoblitt))
- improve port match [\#41](https://github.com/voxpupuli/puppet-selinux/pull/41) ([ghost](https://github.com/ghost))
- Bug fix for declaring multiple selinux::module types [\#40](https://github.com/voxpupuli/puppet-selinux/pull/40) ([apatik](https://github.com/apatik))
- Use "defined" instead of "getvar" to protect against undefined variables when strict\_variables=yes [\#34](https://github.com/voxpupuli/puppet-selinux/pull/34) ([robinbowes](https://github.com/robinbowes))
- Workaround for RH 7 variants [\#33](https://github.com/voxpupuli/puppet-selinux/pull/33) ([robrankin](https://github.com/robrankin))
- Fix to work with strict\_variables=true [\#32](https://github.com/voxpupuli/puppet-selinux/pull/32) ([robinbowes](https://github.com/robinbowes))

## [v0.2.3](https://github.com/voxpupuli/puppet-selinux/tree/v0.2.3) (2015-03-03)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.2.2...v0.2.3)

**Merged pull requests:**

- add spec tests, update validations, cleanup [\#31](https://github.com/voxpupuli/puppet-selinux/pull/31) ([jlambert121](https://github.com/jlambert121))
- Better compatibility with CentOS 7 [\#29](https://github.com/voxpupuli/puppet-selinux/pull/29) ([djjudas21](https://github.com/djjudas21))
- fix change-selinux-status in case of selinux disabled [\#28](https://github.com/voxpupuli/puppet-selinux/pull/28) ([cristifalcas](https://github.com/cristifalcas))

## [v0.2.2](https://github.com/voxpupuli/puppet-selinux/tree/v0.2.2) (2015-01-19)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/v0.2.0...v0.2.2)

**Merged pull requests:**

- reverting previous lint change [\#26](https://github.com/voxpupuli/puppet-selinux/pull/26) ([robrankin](https://github.com/robrankin))
- REPLACE config file route [\#25](https://github.com/voxpupuli/puppet-selinux/pull/25) ([rmacian](https://github.com/rmacian))
- Add OS compatibility data for Puppet Forge [\#24](https://github.com/voxpupuli/puppet-selinux/pull/24) ([djjudas21](https://github.com/djjudas21))
- Lint fixes [\#23](https://github.com/voxpupuli/puppet-selinux/pull/23) ([djjudas21](https://github.com/djjudas21))
- Switch to a more robust way of changing SELinux status [\#22](https://github.com/voxpupuli/puppet-selinux/pull/22) ([djjudas21](https://github.com/djjudas21))

## [v0.2.0](https://github.com/voxpupuli/puppet-selinux/tree/v0.2.0) (2015-01-12)

[Full Changelog](https://github.com/voxpupuli/puppet-selinux/compare/66b941f2e79857b5deb9604435063043ff14a490...v0.2.0)

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



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
