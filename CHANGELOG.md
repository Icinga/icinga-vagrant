# Change Log

## [v2.1.0](https://github.com/Icinga/puppet-icingaweb2/tree/v2.1.0) (2018-01-23)
[Full Changelog](https://github.com/Icinga/puppet-icingaweb2/compare/v2.0.1...v2.1.0)

**Implemented enhancements:**

- missing domain attribute for icingaweb2::config::authmethod [\#203](https://github.com/Icinga/puppet-icingaweb2/issues/203)
- Add elasticsearch module [\#193](https://github.com/Icinga/puppet-icingaweb2/issues/193)
- Add graphite module [\#192](https://github.com/Icinga/puppet-icingaweb2/issues/192)
- Update apache2 example [\#191](https://github.com/Icinga/puppet-icingaweb2/issues/191)
- Add default backend in groups.ini [\#188](https://github.com/Icinga/puppet-icingaweb2/issues/188)
- Add vSphere module [\#183](https://github.com/Icinga/puppet-icingaweb2/issues/183)
- Add fileshipper module [\#182](https://github.com/Icinga/puppet-icingaweb2/issues/182)

**Fixed bugs:**

- protected\_customvars handled incorrectly? [\#206](https://github.com/Icinga/puppet-icingaweb2/issues/206)
- puppetdb: issue if host does not resolve to puppetdb [\#197](https://github.com/Icinga/puppet-icingaweb2/issues/197)
- Setting up icingaweb2 with postgresql on a different port than 5432 leads to an error [\#195](https://github.com/Icinga/puppet-icingaweb2/issues/195)

**Merged pull requests:**

- added domain attribute to icingaweb2::config::groupbackend [\#205](https://github.com/Icinga/puppet-icingaweb2/pull/205) ([spaolo](https://github.com/spaolo))
- added domain attribute to icingaweb2::config::authmethod [\#204](https://github.com/Icinga/puppet-icingaweb2/pull/204) ([spaolo](https://github.com/spaolo))

## [v2.0.1](https://github.com/Icinga/puppet-icingaweb2/tree/v2.0.1) (2017-12-28)
[Full Changelog](https://github.com/Icinga/puppet-icingaweb2/compare/v2.0.0...v2.0.1)

**Implemented enhancements:**

- Support fcgi as example for apache [\#201](https://github.com/Icinga/puppet-icingaweb2/issues/201)
- Links to apache2 and nginx examples doesn't work [\#185](https://github.com/Icinga/puppet-icingaweb2/issues/185)

**Merged pull requests:**

- fix \#201 Suppoet fcgi as example for apache [\#202](https://github.com/Icinga/puppet-icingaweb2/pull/202) ([lbetz](https://github.com/lbetz))
- Provide specific port to mysql and postgresql [\#196](https://github.com/Icinga/puppet-icingaweb2/pull/196) ([Faffnir](https://github.com/Faffnir))
- Rename default administrative user to 'icingaadmin' [\#194](https://github.com/Icinga/puppet-icingaweb2/pull/194) ([dnsmichi](https://github.com/dnsmichi))
- Add missing curly bracket and trailing commas [\#189](https://github.com/Icinga/puppet-icingaweb2/pull/189) ([rgevaert](https://github.com/rgevaert))
- Fix protected\_customvars bugs and papercuts [\#186](https://github.com/Icinga/puppet-icingaweb2/pull/186) ([olasd](https://github.com/olasd))
- Fix typos on README.md [\#184](https://github.com/Icinga/puppet-icingaweb2/pull/184) ([Tokynet](https://github.com/Tokynet))

## [v2.0.0](https://github.com/Icinga/puppet-icingaweb2/tree/v2.0.0) (2017-10-11)
[Full Changelog](https://github.com/Icinga/puppet-icingaweb2/compare/1.0.6...v2.0.0)

**Implemented enhancements:**

- Store preferences in database [\#166](https://github.com/Icinga/puppet-icingaweb2/issues/166)
- Support icinga2 API command transport [\#74](https://github.com/Icinga/puppet-icingaweb2/issues/74)
- Use RSpec helper rspec-puppet-facts [\#70](https://github.com/Icinga/puppet-icingaweb2/issues/70)
- Support LDAP auth\_backend [\#69](https://github.com/Icinga/puppet-icingaweb2/issues/69)
- Manage icingaweb2 user [\#68](https://github.com/Icinga/puppet-icingaweb2/issues/68)
- Updating graphite with more config [\#66](https://github.com/Icinga/puppet-icingaweb2/issues/66)
- Adding monitoring module [\#65](https://github.com/Icinga/puppet-icingaweb2/issues/65)
- \[dev.icinga.com \#9243\] add ldaps to resource\_ldap.pp [\#56](https://github.com/Icinga/puppet-icingaweb2/issues/56)
- \[dev.icinga.com \#9155\] Add module generictts [\#54](https://github.com/Icinga/puppet-icingaweb2/issues/54)
- Update Docs Install Icinga Web icinga2 vs icingaweb2  [\#174](https://github.com/Icinga/puppet-icingaweb2/issues/174)
- Add translation module [\#169](https://github.com/Icinga/puppet-icingaweb2/issues/169)
- Parameterize conf\_user [\#145](https://github.com/Icinga/puppet-icingaweb2/issues/145)
- Update version in Puppet Forge [\#141](https://github.com/Icinga/puppet-icingaweb2/issues/141)
- Add changelog [\#128](https://github.com/Icinga/puppet-icingaweb2/issues/128)
- Add Cube module [\#127](https://github.com/Icinga/puppet-icingaweb2/issues/127)
- Add Director module [\#126](https://github.com/Icinga/puppet-icingaweb2/issues/126)
- Add business process module [\#125](https://github.com/Icinga/puppet-icingaweb2/issues/125)
- Refactor monitoring module class [\#124](https://github.com/Icinga/puppet-icingaweb2/issues/124)
- Add defined type to generally handle module installations and configuration [\#122](https://github.com/Icinga/puppet-icingaweb2/issues/122)
- Rename classes to icingaweb2::module::modulename [\#121](https://github.com/Icinga/puppet-icingaweb2/issues/121)
- Remove unsupported modules [\#120](https://github.com/Icinga/puppet-icingaweb2/issues/120)
- Default auth mechanism [\#119](https://github.com/Icinga/puppet-icingaweb2/issues/119)
- Add defined type for roles [\#118](https://github.com/Icinga/puppet-icingaweb2/issues/118)
- Add defined type to handle config.ini [\#117](https://github.com/Icinga/puppet-icingaweb2/issues/117)
- Add defined type to handle groups.ini [\#116](https://github.com/Icinga/puppet-icingaweb2/issues/116)
- Add defined type to handle authentication.ini [\#115](https://github.com/Icinga/puppet-icingaweb2/issues/115)
- Add type to handle resources.ini [\#114](https://github.com/Icinga/puppet-icingaweb2/issues/114)
- Add defined type that handles Ini configurations [\#113](https://github.com/Icinga/puppet-icingaweb2/issues/113)
- Update basic specs [\#112](https://github.com/Icinga/puppet-icingaweb2/issues/112)
- Add release guide [\#111](https://github.com/Icinga/puppet-icingaweb2/issues/111)
- Add testing guide [\#110](https://github.com/Icinga/puppet-icingaweb2/issues/110)
- Add contributing guide [\#109](https://github.com/Icinga/puppet-icingaweb2/issues/109)
- Add some basic examples [\#108](https://github.com/Icinga/puppet-icingaweb2/issues/108)
- Basic Apache configuration with example [\#107](https://github.com/Icinga/puppet-icingaweb2/issues/107)
- Add reference documentation [\#106](https://github.com/Icinga/puppet-icingaweb2/issues/106)
- Update general documentation [\#105](https://github.com/Icinga/puppet-icingaweb2/issues/105)
- Create parameter manage\_package [\#104](https://github.com/Icinga/puppet-icingaweb2/issues/104)
- Remove deprecated parameters [\#103](https://github.com/Icinga/puppet-icingaweb2/issues/103)
- General configuration [\#102](https://github.com/Icinga/puppet-icingaweb2/issues/102)
- Remove git installation method for Icinga Web 2 [\#101](https://github.com/Icinga/puppet-icingaweb2/issues/101)
- Ensure support for certain operating systems [\#100](https://github.com/Icinga/puppet-icingaweb2/issues/100)
- Add header with inline documentation to all files [\#99](https://github.com/Icinga/puppet-icingaweb2/issues/99)
- Support initialize for PostgreSQL [\#82](https://github.com/Icinga/puppet-icingaweb2/issues/82)
- Acceptance tests [\#78](https://github.com/Icinga/puppet-icingaweb2/issues/78)
- Adding database initialization [\#64](https://github.com/Icinga/puppet-icingaweb2/issues/64)
- Updating monitoring transports [\#75](https://github.com/Icinga/puppet-icingaweb2/pull/75) ([lazyfrosch](https://github.com/lazyfrosch))
- Update module base [\#73](https://github.com/Icinga/puppet-icingaweb2/pull/73) ([lazyfrosch](https://github.com/lazyfrosch))
- Refactoring repository management [\#72](https://github.com/Icinga/puppet-icingaweb2/pull/72) ([lazyfrosch](https://github.com/lazyfrosch))
- Using rspec-puppet-facts for new spec [\#71](https://github.com/Icinga/puppet-icingaweb2/pull/71) ([lazyfrosch](https://github.com/lazyfrosch))

**Fixed bugs:**

- Dependency puppetlabs/concat conflicts with puppet-icinga2 [\#165](https://github.com/Icinga/puppet-icingaweb2/issues/165)
- rspec tests broken due to unintepreted facts [\#161](https://github.com/Icinga/puppet-icingaweb2/issues/161)
- Can't manage multiple \[config\] sections because of duplicate resource [\#146](https://github.com/Icinga/puppet-icingaweb2/issues/146)
- Fixing config files permissions [\#67](https://github.com/Icinga/puppet-icingaweb2/issues/67)
- \[dev.icinga.com \#12142\] Why does initialize.pp require /root/.my.cnf on RedHat/CentOS, not Debian/Ubuntu? [\#61](https://github.com/Icinga/puppet-icingaweb2/issues/61)
- \[dev.icinga.com \#11876\] Path for mysql-command is missing [\#60](https://github.com/Icinga/puppet-icingaweb2/issues/60)
- \[dev.icinga.com \#11719\] Missing packages if APT::Install-Recommends "false"; [\#59](https://github.com/Icinga/puppet-icingaweb2/issues/59)
- \[dev.icinga.com \#11584\] what is the standard password set by initialize.pp? [\#58](https://github.com/Icinga/puppet-icingaweb2/issues/58)
- \[dev.icinga.com \#11507\] installing icinga web2  [\#57](https://github.com/Icinga/puppet-icingaweb2/issues/57)
- Install dependencies by default [\#176](https://github.com/Icinga/puppet-icingaweb2/issues/176)
- Logging directory is not created by module [\#172](https://github.com/Icinga/puppet-icingaweb2/issues/172)
- Incorrect config directory access mode on Debian [\#85](https://github.com/Icinga/puppet-icingaweb2/issues/85)
- Package managers handle dependencies. [\#87](https://github.com/Icinga/puppet-icingaweb2/pull/87) ([tdb](https://github.com/tdb))
- deployment: Correct directory management [\#76](https://github.com/Icinga/puppet-icingaweb2/pull/76) ([lazyfrosch](https://github.com/lazyfrosch))

**Closed issues:**

- /etc/icingaweb2/modules isn't created [\#158](https://github.com/Icinga/puppet-icingaweb2/issues/158)
- Allow muliple API Host for icingaweb2::module::monitoring [\#155](https://github.com/Icinga/puppet-icingaweb2/issues/155)
- icingaweb2::module::module\_dir parameter default value should probably not be undef [\#147](https://github.com/Icinga/puppet-icingaweb2/issues/147)
- Missing Configuration [\#138](https://github.com/Icinga/puppet-icingaweb2/issues/138)
- Syntax error at 'resource\_name'; expected '}' [\#136](https://github.com/Icinga/puppet-icingaweb2/issues/136)
- Please move development to master [\#134](https://github.com/Icinga/puppet-icingaweb2/issues/134)
- Git install method is missing minified assets [\#129](https://github.com/Icinga/puppet-icingaweb2/issues/129)
- Add default modules [\#123](https://github.com/Icinga/puppet-icingaweb2/issues/123)
- How to enable module monitoring Via Puppet [\#95](https://github.com/Icinga/puppet-icingaweb2/issues/95)
- It would be nice to have possibility to change certain file/directory permissions [\#94](https://github.com/Icinga/puppet-icingaweb2/issues/94)
- Could not find declared class icingaweb2::mod::monitoring [\#93](https://github.com/Icinga/puppet-icingaweb2/issues/93)
- The parameter 'ido\_db\_host' is declared more than once [\#92](https://github.com/Icinga/puppet-icingaweb2/issues/92)
- missing groups.ini [\#91](https://github.com/Icinga/puppet-icingaweb2/issues/91)
- Add Debian Stretch to the compatibility list? [\#89](https://github.com/Icinga/puppet-icingaweb2/issues/89)
- Dependencies incorrect on Ubuntu 16.04+ [\#88](https://github.com/Icinga/puppet-icingaweb2/issues/88)
- Improve Apache integration and document it [\#83](https://github.com/Icinga/puppet-icingaweb2/issues/83)
- Default credentials for login [\#80](https://github.com/Icinga/puppet-icingaweb2/issues/80)
- Deprecate default install method [\#77](https://github.com/Icinga/puppet-icingaweb2/issues/77)
- \[dev.icinga.com \#9154\] Add module pnp4nagios [\#53](https://github.com/Icinga/puppet-icingaweb2/issues/53)
- Icingaweb2::Module::Monitoring doesn't actually install the module [\#160](https://github.com/Icinga/puppet-icingaweb2/issues/160)
- Add generictts module [\#154](https://github.com/Icinga/puppet-icingaweb2/issues/154)
- add icingaweb2::module::puppetdb [\#152](https://github.com/Icinga/puppet-icingaweb2/issues/152)
- add icingaweb2::module::doc [\#150](https://github.com/Icinga/puppet-icingaweb2/issues/150)
- Icingaweb2 schema only created on second run when configured along with icinga2 [\#144](https://github.com/Icinga/puppet-icingaweb2/issues/144)
- Correct documentation for authentication configuration [\#143](https://github.com/Icinga/puppet-icingaweb2/issues/143)
- Align documentation for duplicate repository [\#131](https://github.com/Icinga/puppet-icingaweb2/issues/131)
- Non compatible dependencies between icinga2 and Icingaweb2 latest releases [\#98](https://github.com/Icinga/puppet-icingaweb2/issues/98)
- Roles setting is not up to date and is not supporting businessprocess-prefix [\#96](https://github.com/Icinga/puppet-icingaweb2/issues/96)
- Resources.ini should not be world-readable [\#90](https://github.com/Icinga/puppet-icingaweb2/issues/90)
- Documentation updates [\#79](https://github.com/Icinga/puppet-icingaweb2/issues/79)

**Merged pull requests:**

- Add example manifest for Grafana module [\#181](https://github.com/Icinga/puppet-icingaweb2/pull/181) ([druchoo](https://github.com/druchoo))
- Add 'LDAP Base DN' to 'User Backends' [\#180](https://github.com/Icinga/puppet-icingaweb2/pull/180) ([druchoo](https://github.com/druchoo))
- Removed puppetlabs-apache from dependencies [\#178](https://github.com/Icinga/puppet-icingaweb2/pull/178) ([noqqe](https://github.com/noqqe))
- Manage logging directory and file [\#173](https://github.com/Icinga/puppet-icingaweb2/pull/173) ([baurmatt](https://github.com/baurmatt))
- Add translation module [\#170](https://github.com/Icinga/puppet-icingaweb2/pull/170) ([baurmatt](https://github.com/baurmatt))
- Allow preferences to be stored in db [\#168](https://github.com/Icinga/puppet-icingaweb2/pull/168) ([baurmatt](https://github.com/baurmatt))
- Add git repository config [\#167](https://github.com/Icinga/puppet-icingaweb2/pull/167) ([tdukaric](https://github.com/tdukaric))
- Add a context per operating system [\#162](https://github.com/Icinga/puppet-icingaweb2/pull/162) ([baurmatt](https://github.com/baurmatt))
- Add modules directory [\#159](https://github.com/Icinga/puppet-icingaweb2/pull/159) ([baurmatt](https://github.com/baurmatt))
- Loosen concat version restrictions [\#156](https://github.com/Icinga/puppet-icingaweb2/pull/156) ([quixoten](https://github.com/quixoten))
- Implement puppetdb module [\#153](https://github.com/Icinga/puppet-icingaweb2/pull/153) ([rgevaert](https://github.com/rgevaert))
- Implement icingaweb2::module::doc [\#151](https://github.com/Icinga/puppet-icingaweb2/pull/151) ([rgevaert](https://github.com/rgevaert))
- Prevent duplicate resources errors [\#149](https://github.com/Icinga/puppet-icingaweb2/pull/149) ([rgevaert](https://github.com/rgevaert))
- Correct authentication configuration documentation [\#142](https://github.com/Icinga/puppet-icingaweb2/pull/142) ([rgevaert](https://github.com/rgevaert))
- Add GitHub issue template [\#137](https://github.com/Icinga/puppet-icingaweb2/pull/137) ([dnsmichi](https://github.com/dnsmichi))
- Add nginx example [\#84](https://github.com/Icinga/puppet-icingaweb2/pull/84) ([prozach](https://github.com/prozach))
- Fixing testing issues [\#81](https://github.com/Icinga/puppet-icingaweb2/pull/81) ([lazyfrosch](https://github.com/lazyfrosch))
- Update URLs to GitHub [\#62](https://github.com/Icinga/puppet-icingaweb2/pull/62) ([bobapple](https://github.com/bobapple))
- testing: Updating travis settings [\#51](https://github.com/Icinga/puppet-icingaweb2/pull/51) ([lazyfrosch](https://github.com/lazyfrosch))
- remove dependency on concat module [\#50](https://github.com/Icinga/puppet-icingaweb2/pull/50) ([lbischof](https://github.com/lbischof))
- substituting non existing parameter [\#49](https://github.com/Icinga/puppet-icingaweb2/pull/49) ([attachmentgenie](https://github.com/attachmentgenie))
- Fix permissions [\#30](https://github.com/Icinga/puppet-icingaweb2/pull/30) ([petems](https://github.com/petems))
- Change sql\_schema\_location if using git [\#29](https://github.com/Icinga/puppet-icingaweb2/pull/29) ([petems](https://github.com/petems))
- Allow multiple commandtransports [\#157](https://github.com/Icinga/puppet-icingaweb2/pull/157) ([baurmatt](https://github.com/baurmatt))

## [1.0.6](https://github.com/Icinga/puppet-icingaweb2/tree/1.0.6) (2015-11-10)
[Full Changelog](https://github.com/Icinga/puppet-icingaweb2/compare/1.0.5...1.0.6)

## [1.0.5](https://github.com/Icinga/puppet-icingaweb2/tree/1.0.5) (2015-08-04)
[Full Changelog](https://github.com/Icinga/puppet-icingaweb2/compare/1.0.4...1.0.5)

## [1.0.4](https://github.com/Icinga/puppet-icingaweb2/tree/1.0.4) (2015-06-24)
[Full Changelog](https://github.com/Icinga/puppet-icingaweb2/compare/1.0.3...1.0.4)

**Merged pull requests:**

- Add support for Scientific Linux in Yum repo [\#16](https://github.com/Icinga/puppet-icingaweb2/pull/16) ([joshbeard](https://github.com/joshbeard))

## [1.0.3](https://github.com/Icinga/puppet-icingaweb2/tree/1.0.3) (2015-05-07)
[Full Changelog](https://github.com/Icinga/puppet-icingaweb2/compare/1.0.2...1.0.3)

## [1.0.2](https://github.com/Icinga/puppet-icingaweb2/tree/1.0.2) (2015-05-07)
[Full Changelog](https://github.com/Icinga/puppet-icingaweb2/compare/1.0.1...1.0.2)

## [1.0.1](https://github.com/Icinga/puppet-icingaweb2/tree/1.0.1) (2015-05-07)
[Full Changelog](https://github.com/Icinga/puppet-icingaweb2/compare/1.0.0...1.0.1)

## [1.0.0](https://github.com/Icinga/puppet-icingaweb2/tree/1.0.0) (2015-05-07)
**Implemented enhancements:**

- \[dev.icinga.com \#9158\] Add module graphite [\#55](https://github.com/Icinga/puppet-icingaweb2/issues/55)
- \[dev.icinga.com \#9153\] Add module businessprocess [\#52](https://github.com/Icinga/puppet-icingaweb2/issues/52)
- Fix authentication configuration [\#8](https://github.com/Icinga/puppet-icingaweb2/pull/8) ([lazyfrosch](https://github.com/lazyfrosch))

**Merged pull requests:**

- Don't put blank host/service filters in roles.ini [\#13](https://github.com/Icinga/puppet-icingaweb2/pull/13) ([jamesweakley](https://github.com/jamesweakley))
- Moving away from templates to usign inifile from Puppetlabs/inifile [\#7](https://github.com/Icinga/puppet-icingaweb2/pull/7) ([smbambling](https://github.com/smbambling))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*