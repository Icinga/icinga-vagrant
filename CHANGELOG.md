# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v4.1.0](https://github.com/voxpupuli/puppet-snmp/tree/v4.1.0) (2018-11-23)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/v4.0.0...v4.1.0)

**Implemented enhancements:**

- Implement snmpv3\_user fact and snmp::snmpv3\_usm\_hash function [\#157](https://github.com/voxpupuli/puppet-snmp/pull/157) ([smoeding](https://github.com/smoeding))

**Fixed bugs:**

- fix snmptrapd on ubuntu and debian [\#168](https://github.com/voxpupuli/puppet-snmp/pull/168) ([amateo](https://github.com/amateo))

**Merged pull requests:**

- use puppet strings format for reference [\#167](https://github.com/voxpupuli/puppet-snmp/pull/167) ([Dan33l](https://github.com/Dan33l))
- add acceptance tests with beaker [\#166](https://github.com/voxpupuli/puppet-snmp/pull/166) ([Dan33l](https://github.com/Dan33l))

## [v4.0.0](https://github.com/voxpupuli/puppet-snmp/tree/v4.0.0) (2018-11-08)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/3.9.0...v4.0.0)

This is the first release in VoxPupuli's `puppet` namespace.

Earlier versions of the module (razorsedge/snmp) stated that traditional access control and its parameters were deprecated and would be removed in version 4.0.0.  Removing this feature has been deferred until at least version 5.

**Breaking changes:**

- Remove the use of global variables [\#145](https://github.com/voxpupuli/puppet-snmp/pull/145) ([ekohl](https://github.com/ekohl))
- Remove `validate\_numeric` and `validate\_string` [\#144](https://github.com/voxpupuli/puppet-snmp/pull/144) ([alexjfisher](https://github.com/alexjfisher))
- Remove deprecated `install\_client` parameter [\#143](https://github.com/voxpupuli/puppet-snmp/pull/143) ([alexjfisher](https://github.com/alexjfisher))
- Migrate stuff to Vox Pupuli; Drop Puppet 2/3 support; require stdlib 4.13.1 or newer [\#135](https://github.com/voxpupuli/puppet-snmp/pull/135) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Debian Stretch \(new stable\) use a different user for snmpd [\#108](https://github.com/voxpupuli/puppet-snmp/issues/108)
- Add $snmpv2\_enable parameter [\#136](https://github.com/voxpupuli/puppet-snmp/pull/136) ([hdep](https://github.com/hdep))
- Add ubuntu 18.04 support [\#130](https://github.com/voxpupuli/puppet-snmp/pull/130) ([cliff-wakefield](https://github.com/cliff-wakefield))

**Fixed bugs:**

- validate\_numeric\(\) and friends are deprecated in stdlib [\#111](https://github.com/voxpupuli/puppet-snmp/issues/111)
- Unknown variable: '::snmp\_agentaddress' error [\#65](https://github.com/voxpupuli/puppet-snmp/issues/65)
- Fix typo in snmp::params: s/extemds/extends/ [\#133](https://github.com/voxpupuli/puppet-snmp/pull/133) ([chundaoc](https://github.com/chundaoc))

**Closed issues:**

- Needs to be updated to support Ubuntu 18 [\#151](https://github.com/voxpupuli/puppet-snmp/issues/151)
- Release the current version on the forge [\#138](https://github.com/voxpupuli/puppet-snmp/issues/138)
- Test cases are broken [\#132](https://github.com/voxpupuli/puppet-snmp/issues/132)
- cannot disable VACM [\#129](https://github.com/voxpupuli/puppet-snmp/issues/129)
- `extemds` variable typo [\#123](https://github.com/voxpupuli/puppet-snmp/issues/123)

**Merged pull requests:**

- update deprecation notice [\#161](https://github.com/voxpupuli/puppet-snmp/pull/161) ([Dan33l](https://github.com/Dan33l))
- update CONTRIBUTING.md copied from .github/CONTRIBUTING.md [\#160](https://github.com/voxpupuli/puppet-snmp/pull/160) ([Dan33l](https://github.com/Dan33l))
- cleanup about OSes in README [\#159](https://github.com/voxpupuli/puppet-snmp/pull/159) ([Dan33l](https://github.com/Dan33l))
- move copyright notice from manifests to updated Development section in README [\#158](https://github.com/voxpupuli/puppet-snmp/pull/158) ([Dan33l](https://github.com/Dan33l))
- Use rspec-puppet-facts [\#155](https://github.com/voxpupuli/puppet-snmp/pull/155) ([Dan33l](https://github.com/Dan33l))
- use structured facts [\#154](https://github.com/voxpupuli/puppet-snmp/pull/154) ([Dan33l](https://github.com/Dan33l))
- modulesync 2.2.0 and allow puppet 6.x [\#150](https://github.com/voxpupuli/puppet-snmp/pull/150) ([bastelfreak](https://github.com/bastelfreak))
- Various refactoring to improve code readability [\#149](https://github.com/voxpupuli/puppet-snmp/pull/149) ([alexjfisher](https://github.com/alexjfisher))
- Replace validation logic for \*service\_ensure. [\#148](https://github.com/voxpupuli/puppet-snmp/pull/148) ([vStone](https://github.com/vStone))
- Replace validate\_array with proper data types [\#147](https://github.com/voxpupuli/puppet-snmp/pull/147) ([vStone](https://github.com/vStone))
- Replace instances of validate\_re with Enum type [\#146](https://github.com/voxpupuli/puppet-snmp/pull/146) ([alexjfisher](https://github.com/alexjfisher))
- Replace `validate\_bool` with `Boolean` data type [\#142](https://github.com/voxpupuli/puppet-snmp/pull/142) ([alexjfisher](https://github.com/alexjfisher))
- Unpin stdlib in fixtures.yml [\#141](https://github.com/voxpupuli/puppet-snmp/pull/141) ([alexjfisher](https://github.com/alexjfisher))
- Include full Apache 2.0 license text and add badge [\#140](https://github.com/voxpupuli/puppet-snmp/pull/140) ([alexjfisher](https://github.com/alexjfisher))

## [3.9.0](https://github.com/voxpupuli/puppet-snmp/tree/3.9.0) (2018-01-07)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/3.8.1...3.9.0)

**Implemented enhancements:**

- adding possibility to configure extend-slines in snmpd.conf [\#118](https://github.com/voxpupuli/puppet-snmp/pull/118) ([tjungbauer](https://github.com/tjungbauer))
- Added extra logic to handle Debian 9 \(Stretch\) [\#113](https://github.com/voxpupuli/puppet-snmp/pull/113) ([Pavulon007](https://github.com/Pavulon007))

**Fixed bugs:**

- Using an array for ro\_community breaks snmptrapd [\#106](https://github.com/voxpupuli/puppet-snmp/issues/106)

## [3.8.1](https://github.com/voxpupuli/puppet-snmp/tree/3.8.1) (2017-06-15)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/3.8.0...3.8.1)

**Fixed bugs:**

- Problem with puppet v4 [\#103](https://github.com/voxpupuli/puppet-snmp/issues/103)
- Fix snmptrapd community string configuration [\#107](https://github.com/voxpupuli/puppet-snmp/pull/107) ([djschaap](https://github.com/djschaap))

## [3.8.0](https://github.com/voxpupuli/puppet-snmp/tree/3.8.0) (2017-05-28)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/3.7.0...3.8.0)

**Implemented enhancements:**

- Add master options to snmpd.conf [\#104](https://github.com/voxpupuli/puppet-snmp/pull/104) ([coreone](https://github.com/coreone))
- Fix strict variables [\#102](https://github.com/voxpupuli/puppet-snmp/pull/102) ([coreone](https://github.com/coreone))

**Fixed bugs:**

- Change - Update requirements for the snmp::client class [\#98](https://github.com/voxpupuli/puppet-snmp/pull/98) ([blackknight36](https://github.com/blackknight36))

**Merged pull requests:**

- Update requirements for the snmp client class [\#105](https://github.com/voxpupuli/puppet-snmp/pull/105) ([blackknight36](https://github.com/blackknight36))

## [3.7.0](https://github.com/voxpupuli/puppet-snmp/tree/3.7.0) (2017-04-23)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/3.6.0...3.7.0)

**Implemented enhancements:**

- Support service\_config\_dir\_group class parameter [\#93](https://github.com/voxpupuli/puppet-snmp/pull/93) ([adepretis](https://github.com/adepretis))
- Add Dell OpenManage StorageServices smux OID [\#90](https://github.com/voxpupuli/puppet-snmp/pull/90) ([vide](https://github.com/vide))
- Add OpenBSD to the supported operating systems, similar to FreeBSD [\#74](https://github.com/voxpupuli/puppet-snmp/pull/74) ([buzzdeee](https://github.com/buzzdeee))
- Create Parameters for template files. [\#73](https://github.com/voxpupuli/puppet-snmp/pull/73) ([aschaber1](https://github.com/aschaber1))

**Fixed bugs:**

- CI failing, Module sync out of date. [\#75](https://github.com/voxpupuli/puppet-snmp/issues/75)

**Closed issues:**

- File permissions do not match the ones of the net-snmp  [\#81](https://github.com/voxpupuli/puppet-snmp/issues/81)

## [3.6.0](https://github.com/voxpupuli/puppet-snmp/tree/3.6.0) (2015-12-20)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/3.5.0...3.6.0)

**Implemented enhancements:**

- Multiple rocommunity,rwcommunity [\#57](https://github.com/voxpupuli/puppet-snmp/issues/57)
- Conglomerate of PRs with tests [\#62](https://github.com/voxpupuli/puppet-snmp/pull/62) ([jrwesolo](https://github.com/jrwesolo))

**Fixed bugs:**

- creating snmpv3 users fails with passphrases containing spaces [\#33](https://github.com/voxpupuli/puppet-snmp/issues/33)

## [3.5.0](https://github.com/voxpupuli/puppet-snmp/tree/3.5.0) (2015-10-15)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/3.4.0...3.5.0)

**Implemented enhancements:**

- Add the ability pass multiple networks for the community string [\#55](https://github.com/voxpupuli/puppet-snmp/pull/55) ([rdrgmnzs](https://github.com/rdrgmnzs))

**Fixed bugs:**

- quote snmpv3 passphrases to cope with weird characters and spaces [\#42](https://github.com/voxpupuli/puppet-snmp/pull/42) ([Seegras](https://github.com/Seegras))

## [3.4.0](https://github.com/voxpupuli/puppet-snmp/tree/3.4.0) (2015-07-07)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/3.3.1...3.4.0)

**Implemented enhancements:**

- Creating snmpv3 users on loaded system fails [\#46](https://github.com/voxpupuli/puppet-snmp/issues/46)
- snmpd\_options and other /etc/defaults/snmpd options is not in docs [\#30](https://github.com/voxpupuli/puppet-snmp/issues/30)
- rocommunity commented out [\#10](https://github.com/voxpupuli/puppet-snmp/issues/10)

**Fixed bugs:**

- ro\_community cannot be set to 'undef' to remove from ERB template [\#36](https://github.com/voxpupuli/puppet-snmp/issues/36)
- skip zero length strings in ERB template output [\#41](https://github.com/voxpupuli/puppet-snmp/pull/41) ([bdellegrazie](https://github.com/bdellegrazie))

**Closed issues:**

- Not possible to not start snmptrapd service [\#52](https://github.com/voxpupuli/puppet-snmp/issues/52)
- No support for syslocation/syscontact [\#45](https://github.com/voxpupuli/puppet-snmp/issues/45)
- CentOS 7.1 breaks params.rb [\#44](https://github.com/voxpupuli/puppet-snmp/issues/44)

## [3.3.1](https://github.com/voxpupuli/puppet-snmp/tree/3.3.1) (2015-01-03)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/3.3.0...3.3.1)

## [3.3.0](https://github.com/voxpupuli/puppet-snmp/tree/3.3.0) (2014-12-29)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/3.2.0...3.3.0)

**Implemented enhancements:**

- `ensure =\> absent` fails on el5/el6 if net-snmp-utils is installed [\#20](https://github.com/voxpupuli/puppet-snmp/issues/20)
- Add support for Dell's OpenManage [\#28](https://github.com/voxpupuli/puppet-snmp/pull/28) ([erinn](https://github.com/erinn))
- Disable logging from tcpwrappers in snmpd.conf [\#27](https://github.com/voxpupuli/puppet-snmp/pull/27) ([erinn](https://github.com/erinn))
- IPv6 support round 2 [\#26](https://github.com/voxpupuli/puppet-snmp/pull/26) ([erinn](https://github.com/erinn))

## [3.2.0](https://github.com/voxpupuli/puppet-snmp/tree/3.2.0) (2014-10-07)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/3.1.0...3.2.0)

**Implemented enhancements:**

- dynamic sysname? [\#14](https://github.com/voxpupuli/puppet-snmp/issues/14)

**Fixed bugs:**

- Future parser and puppet-snmp [\#23](https://github.com/voxpupuli/puppet-snmp/issues/23)

**Merged pull requests:**

- Lowercase variable names [\#22](https://github.com/voxpupuli/puppet-snmp/pull/22) ([invliD](https://github.com/invliD))

## [3.1.0](https://github.com/voxpupuli/puppet-snmp/tree/3.1.0) (2014-05-25)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/3.0.0...3.1.0)

**Closed issues:**

- The documentation for init.pp incorrectly suggests that the snmp class takes a 'services' parameter [\#11](https://github.com/voxpupuli/puppet-snmp/issues/11)

## [3.0.0](https://github.com/voxpupuli/puppet-snmp/tree/3.0.0) (2013-07-13)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/2.0.0...3.0.0)

**Implemented enhancements:**

- Trapd extended [\#7](https://github.com/voxpupuli/puppet-snmp/pull/7) ([ghost](https://github.com/ghost))

## [2.0.0](https://github.com/voxpupuli/puppet-snmp/tree/2.0.0) (2013-06-23)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/1.0.1...2.0.0)

**Merged pull requests:**

- modified templates to dereference class parameters [\#2](https://github.com/voxpupuli/puppet-snmp/pull/2) ([hakamadare](https://github.com/hakamadare))

## [1.0.1](https://github.com/voxpupuli/puppet-snmp/tree/1.0.1) (2012-05-26)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/1.0.0...1.0.1)

## [1.0.0](https://github.com/voxpupuli/puppet-snmp/tree/1.0.0) (2012-05-07)

[Full Changelog](https://github.com/voxpupuli/puppet-snmp/compare/d4a4953f4c20ceef5c9b538645e602e498663aec...1.0.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
