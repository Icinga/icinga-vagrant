# Change Log

## [v1.3.4](https://github.com/Icinga/puppet-icinga2/tree/v1.3.4) (2017-11-22)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v1.3.3...v1.3.4)

**Fixed bugs:**

- repository.d missing after install [\#403](https://github.com/Icinga/puppet-icinga2/issues/403)
- Boolean 'false' custom variables do not appear in configuration [\#400](https://github.com/Icinga/puppet-icinga2/issues/400)
- $bin\_dir path incorrect for FreeBSD in params.pp [\#396](https://github.com/Icinga/puppet-icinga2/issues/396)

**Closed issues:**

- missing /etc/pki directory [\#393](https://github.com/Icinga/puppet-icinga2/issues/393)

**Merged pull requests:**

- fix \#400 boolean false custom variables do not appear in configuration [\#406](https://github.com/Icinga/puppet-icinga2/pull/406) ([lbetz](https://github.com/lbetz))
- Bug/repository.d missing after install 403 [\#404](https://github.com/Icinga/puppet-icinga2/pull/404) ([lbetz](https://github.com/lbetz))
- fix \#396 incorrect bin\_dir path for FreeBSD [\#401](https://github.com/Icinga/puppet-icinga2/pull/401) ([lbetz](https://github.com/lbetz))

## [v1.3.3](https://github.com/Icinga/puppet-icinga2/tree/v1.3.3) (2017-10-24)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v1.3.2...v1.3.3)

**Fixed bugs:**

- Icinga2 binary not found on Redhat/Centos 6 family [\#390](https://github.com/Icinga/puppet-icinga2/issues/390)

**Merged pull requests:**

- fix \#390 icinga2 binary not found on rhel6 [\#391](https://github.com/Icinga/puppet-icinga2/pull/391) ([lbetz](https://github.com/lbetz))

## [v1.3.2](https://github.com/Icinga/puppet-icinga2/tree/v1.3.2) (2017-10-11)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v1.3.1...v1.3.2)

**Fixed bugs:**

- SLES should use service pack repository [\#386](https://github.com/Icinga/puppet-icinga2/issues/386)

**Closed issues:**

- Update docs how to pass package version [\#388](https://github.com/Icinga/puppet-icinga2/issues/388)

## [v1.3.1](https://github.com/Icinga/puppet-icinga2/tree/v1.3.1) (2017-10-05)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v1.3.0...v1.3.1)

**Implemented enhancements:**

- Fix small typos [\#358](https://github.com/Icinga/puppet-icinga2/issues/358)
- Review and update puppetlabs-concat dependency [\#351](https://github.com/Icinga/puppet-icinga2/issues/351)
- Documentation to set up mysql grants is incorrect. [\#347](https://github.com/Icinga/puppet-icinga2/issues/347)
- Check attributes of all objects [\#219](https://github.com/Icinga/puppet-icinga2/issues/219)
- Align documentation for duplicate repository [\#353](https://github.com/Icinga/puppet-icinga2/issues/353)
- Update documentation about += operator [\#352](https://github.com/Icinga/puppet-icinga2/issues/352)
- Example and documentation for syncing hiera data to icinga objects [\#342](https://github.com/Icinga/puppet-icinga2/issues/342)
- Add owner-, groupship and permissions to file resources [\#291](https://github.com/Icinga/puppet-icinga2/issues/291)
- Support Puppet 5 and test it in travis [\#330](https://github.com/Icinga/puppet-icinga2/pull/330) ([lazyfrosch](https://github.com/lazyfrosch))

**Fixed bugs:**

- Error: Could not find command 'icinga2' on SLES-11 [\#374](https://github.com/Icinga/puppet-icinga2/issues/374)
- When passing non-fqdn name for the NodeName the certificate is still generated with cn set to fqdn [\#328](https://github.com/Icinga/puppet-icinga2/issues/328)
- Install package before creating config files [\#378](https://github.com/Icinga/puppet-icinga2/issues/378)
- Icinga2 binary not found on Debian and FreeBSD [\#371](https://github.com/Icinga/puppet-icinga2/issues/371)
- Could not find command Icinga2 on windows [\#367](https://github.com/Icinga/puppet-icinga2/issues/367)
- Error: Parameter user failed on Exec\[icinga2 pki create key\]: Unable to execute commands as other users on Windows at manifestsfeature/api.pp:317 [\#366](https://github.com/Icinga/puppet-icinga2/issues/366)
- Unit tests broken for facter 2.5 [\#338](https://github.com/Icinga/puppet-icinga2/issues/338)
- protection of private classes is wrong [\#333](https://github.com/Icinga/puppet-icinga2/issues/333)
- ticketsalt only should be stored on ca nodes [\#325](https://github.com/Icinga/puppet-icinga2/issues/325)
- key and cert permissions on windows [\#282](https://github.com/Icinga/puppet-icinga2/issues/282)

**Closed issues:**

- Implement conditional statements/loops parameter for icinga2::object::\* [\#354](https://github.com/Icinga/puppet-icinga2/issues/354)
- document manage\_package with manage\_repo [\#381](https://github.com/Icinga/puppet-icinga2/issues/381)

**Merged pull requests:**

- Remove soft depedencies from metadata.json [\#385](https://github.com/Icinga/puppet-icinga2/pull/385) ([noqqe](https://github.com/noqqe))
- fix \#378 install package before creating config files [\#380](https://github.com/Icinga/puppet-icinga2/pull/380) ([lbetz](https://github.com/lbetz))
- fix \#371, add binary path to icinga2 for Debian, SuSE and FreeBSD [\#372](https://github.com/Icinga/puppet-icinga2/pull/372) ([lbetz](https://github.com/lbetz))
- fix \#325, ticket\_salt ist stored to api.conf only if pki = none|ca [\#370](https://github.com/Icinga/puppet-icinga2/pull/370) ([lbetz](https://github.com/lbetz))
- fix \#367, \#366 and remove management of conf\_dir [\#369](https://github.com/Icinga/puppet-icinga2/pull/369) ([lbetz](https://github.com/lbetz))
- Examples: Fix notification commands for 2.7 [\#368](https://github.com/Icinga/puppet-icinga2/pull/368) ([dnsmichi](https://github.com/dnsmichi))
- Fixed typos [\#357](https://github.com/Icinga/puppet-icinga2/pull/357) ([rgevaert](https://github.com/rgevaert))
- fix \#338 update facterdb dependency to 0.3.12 [\#349](https://github.com/Icinga/puppet-icinga2/pull/349) ([lbetz](https://github.com/lbetz))
- Update protection of private classes from direct use [\#336](https://github.com/Icinga/puppet-icinga2/pull/336) ([lbetz](https://github.com/lbetz))
- Update documentation examples for mysql::db [\#346](https://github.com/Icinga/puppet-icinga2/pull/346) ([rgevaert](https://github.com/rgevaert))

## [v1.3.0](https://github.com/Icinga/puppet-icinga2/tree/v1.3.0) (2017-06-26)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v1.2.1...v1.3.0)

**Implemented enhancements:**

- README.md: clarify meaning of `confd=\>true` [\#314](https://github.com/Icinga/puppet-icinga2/pull/314) ([sourcejedi](https://github.com/sourcejedi))

**Fixed bugs:**

- PR \#293 does not work correctly [\#304](https://github.com/Icinga/puppet-icinga2/issues/304)
- fix certname in api and pki::ca class to constant NodeName [\#319](https://github.com/Icinga/puppet-icinga2/issues/319)
- ordering-api-with-pki-after-package [\#311](https://github.com/Icinga/puppet-icinga2/issues/311)
- Only last empty hash is stored [\#308](https://github.com/Icinga/puppet-icinga2/issues/308)
- module requirements broken. [\#305](https://github.com/Icinga/puppet-icinga2/issues/305)
- ido-mysql install fails while using official icinga packages [\#302](https://github.com/Icinga/puppet-icinga2/issues/302)
- concat resource with tag does not trigger a refresh [\#300](https://github.com/Icinga/puppet-icinga2/issues/300)
- ido packages are managed before repository [\#299](https://github.com/Icinga/puppet-icinga2/issues/299)
- RSpec Puppetlabs modules incompatible to Puppet 3 [\#286](https://github.com/Icinga/puppet-icinga2/issues/286)
- Disable feature checker doesn't trigger a refresh [\#285](https://github.com/Icinga/puppet-icinga2/issues/285)
- SLES Lib directory is not architecture specific [\#283](https://github.com/Icinga/puppet-icinga2/issues/283)
- Fix examples/init\_confd.pp [\#313](https://github.com/Icinga/puppet-icinga2/pull/313) ([sourcejedi](https://github.com/sourcejedi))
- README.md: fix typo `notifiy` [\#312](https://github.com/Icinga/puppet-icinga2/pull/312) ([sourcejedi](https://github.com/sourcejedi))
- debian::dbconfig: Move to autoload location and lint it [\#322](https://github.com/Icinga/puppet-icinga2/pull/322) ([lazyfrosch](https://github.com/lazyfrosch))

**Merged pull requests:**

- Update checker.pp, arrow alignment [\#316](https://github.com/Icinga/puppet-icinga2/pull/316) ([rowanruseler](https://github.com/rowanruseler))
- Update fragment.pp [\#315](https://github.com/Icinga/puppet-icinga2/pull/315) ([rowanruseler](https://github.com/rowanruseler))
- Add GitHub issue template [\#310](https://github.com/Icinga/puppet-icinga2/pull/310) ([dnsmichi](https://github.com/dnsmichi))
- Specify older fixtures for Puppet 3 tests [\#287](https://github.com/Icinga/puppet-icinga2/pull/287) ([lazyfrosch](https://github.com/lazyfrosch))
- Update SLES lib directory [\#284](https://github.com/Icinga/puppet-icinga2/pull/284) ([dgoetz](https://github.com/dgoetz))
- Replace darin/zypprepo with puppet/zypprepo [\#306](https://github.com/Icinga/puppet-icinga2/pull/306) ([noqqe](https://github.com/noqqe))
- Remove deprecated apt options [\#293](https://github.com/Icinga/puppet-icinga2/pull/293) ([jkroepke](https://github.com/jkroepke))

## [v1.2.1](https://github.com/Icinga/puppet-icinga2/tree/v1.2.1) (2017-04-12)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v1.2.0...v1.2.1)

**Implemented enhancements:**

- Create integration tests for MySQL IDO feature [\#207](https://github.com/Icinga/puppet-icinga2/issues/207)
- Add condition to be sure that icinga2 base class is parsed first [\#280](https://github.com/Icinga/puppet-icinga2/issues/280)
- Remove checker feature from examples for agents [\#279](https://github.com/Icinga/puppet-icinga2/issues/279)
- Remove sles-12 reference from Gemfile [\#274](https://github.com/Icinga/puppet-icinga2/issues/274)
- Add tests for custom facts [\#273](https://github.com/Icinga/puppet-icinga2/issues/273)
- Create integration tests for API feature [\#206](https://github.com/Icinga/puppet-icinga2/issues/206)

**Fixed bugs:**

- Fix schema import for FreeBSD [\#277](https://github.com/Icinga/puppet-icinga2/issues/277)
- Fix ::icinga2::pki::ca for FreeBSD [\#276](https://github.com/Icinga/puppet-icinga2/issues/276)
- Fix arrow\_on\_right\_operand\_line lint [\#272](https://github.com/Icinga/puppet-icinga2/issues/272)
- case statement without default in feature api [\#266](https://github.com/Icinga/puppet-icinga2/issues/266)
- case statement without default in idomysql feature [\#265](https://github.com/Icinga/puppet-icinga2/issues/265)
- case statement without default in influx feature [\#264](https://github.com/Icinga/puppet-icinga2/issues/264)
- Fix strings containing only a variable [\#263](https://github.com/Icinga/puppet-icinga2/issues/263)
- Replace selectors inside resource blocks [\#262](https://github.com/Icinga/puppet-icinga2/issues/262)

**Merged pull requests:**

- fix time periods example [\#271](https://github.com/Icinga/puppet-icinga2/pull/271) ([deric](https://github.com/deric))
- Update icingamaster.yaml because yaml-lint failes [\#270](https://github.com/Icinga/puppet-icinga2/pull/270) ([matthiasritter](https://github.com/matthiasritter))

## [v1.2.0](https://github.com/Icinga/puppet-icinga2/tree/v1.2.0) (2017-03-16)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v1.1.1...v1.2.0)

**Implemented enhancements:**

- Add concurrent check parameter to checker object [\#260](https://github.com/Icinga/puppet-icinga2/issues/260)
- use a tag to disable parsing for a single attribute value [\#254](https://github.com/Icinga/puppet-icinga2/issues/254)
- replace service restart with reload [\#250](https://github.com/Icinga/puppet-icinga2/issues/250)
- Update docs of example4 with hint for Puppet 4 [\#234](https://github.com/Icinga/puppet-icinga2/issues/234)
- Add service name to service apply loops [\#227](https://github.com/Icinga/puppet-icinga2/issues/227)

**Fixed bugs:**

- consider-type-of-attribute [\#256](https://github.com/Icinga/puppet-icinga2/issues/256)

## [v1.1.1](https://github.com/Icinga/puppet-icinga2/tree/v1.1.1) (2017-03-08)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v1.1.0...v1.1.1)

**Implemented enhancements:**

- add example of the whole example config [\#252](https://github.com/Icinga/puppet-icinga2/issues/252)
- enable\_ha for notification feature [\#242](https://github.com/Icinga/puppet-icinga2/issues/242)
- Enhance docs on how to enable and use features [\#235](https://github.com/Icinga/puppet-icinga2/issues/235)

**Fixed bugs:**

- set groups default to undef for object servicegroup [\#251](https://github.com/Icinga/puppet-icinga2/issues/251)
- hash key with empty hash as value is parsed wrong [\#247](https://github.com/Icinga/puppet-icinga2/issues/247)
- attribute keys are missed for parsing [\#246](https://github.com/Icinga/puppet-icinga2/issues/246)
- Create signed certificate with custom CA [\#239](https://github.com/Icinga/puppet-icinga2/issues/239)
- Can't pass function via variable [\#238](https://github.com/Icinga/puppet-icinga2/issues/238)
- ido schema import dependency [\#237](https://github.com/Icinga/puppet-icinga2/issues/237)
- Using pki =\> "ca" can either cause incomplete deps or circular reference [\#236](https://github.com/Icinga/puppet-icinga2/issues/236)

**Merged pull requests:**

- enable setting of bind\_host and bind\_port for feature::api [\#243](https://github.com/Icinga/puppet-icinga2/pull/243) ([aschaber1](https://github.com/aschaber1))

## [v1.1.0](https://github.com/Icinga/puppet-icinga2/tree/v1.1.0) (2017-02-20)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v1.0.2...v1.1.0)

**Implemented enhancements:**

- Deploy to puppet forge via travis [\#43](https://github.com/Icinga/puppet-icinga2/issues/43)

**Fixed bugs:**

- Parse issue when attribute is a nested hash with an array value [\#223](https://github.com/Icinga/puppet-icinga2/issues/223)
- icinga2 feature api fails when pki=icinga2 and ca is the local node [\#218](https://github.com/Icinga/puppet-icinga2/issues/218)
- Error installing module from forge for non r10k users [\#217](https://github.com/Icinga/puppet-icinga2/issues/217)
- Apply Notification "users" and "user\_groups" as variable [\#208](https://github.com/Icinga/puppet-icinga2/issues/208)

**Merged pull requests:**

- Fix parse issues when attribute is a nested hash with an array value [\#225](https://github.com/Icinga/puppet-icinga2/pull/225) ([lbetz](https://github.com/lbetz))
- Remove Puppet 4 Warning - delete :undef symbols in attr hash [\#222](https://github.com/Icinga/puppet-icinga2/pull/222) ([Reamer](https://github.com/Reamer))
- Allow other time units in notification and scheduleddowntime [\#220](https://github.com/Icinga/puppet-icinga2/pull/220) ([jkroepke](https://github.com/jkroepke))
- Add initial FreeBSD support [\#210](https://github.com/Icinga/puppet-icinga2/pull/210) ([xaque208](https://github.com/xaque208))

## [v1.0.2](https://github.com/Icinga/puppet-icinga2/tree/v1.0.2) (2017-01-24)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v1.0.1...v1.0.2)

**Implemented enhancements:**

- Add Oracle Linux Support [\#216](https://github.com/Icinga/puppet-icinga2/issues/216)

**Fixed bugs:**

- add permission alter to idomysql docs [\#214](https://github.com/Icinga/puppet-icinga2/issues/214)
- Update serverspec vagrantfile to Debian 8.7 [\#212](https://github.com/Icinga/puppet-icinga2/issues/212)

**Merged pull requests:**

- Revert "Merge branch 'feature/workaround-for-puppetdb-14031'" [\#215](https://github.com/Icinga/puppet-icinga2/pull/215) ([bobapple](https://github.com/bobapple))
- travis: Enable deploy to Puppetforge [\#213](https://github.com/Icinga/puppet-icinga2/pull/213) ([lazyfrosch](https://github.com/lazyfrosch))
- Add support for OracleLinux [\#200](https://github.com/Icinga/puppet-icinga2/pull/200) ([TwizzyDizzy](https://github.com/TwizzyDizzy))

## [v1.0.1](https://github.com/Icinga/puppet-icinga2/tree/v1.0.1) (2017-01-19)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v0.8.1...v1.0.1)

**Implemented enhancements:**

- \[dev.icinga.com \#14031\] Workaround for PuppetDB [\#198](https://github.com/Icinga/puppet-icinga2/issues/198)
- \[dev.icinga.com \#13923\] Remove 'Icinga Development Team' as single author from header [\#197](https://github.com/Icinga/puppet-icinga2/issues/197)
- \[dev.icinga.com \#13921\] Add alternative example of exported resources [\#196](https://github.com/Icinga/puppet-icinga2/issues/196)
- \[dev.icinga.com \#12659\] Upload module to Puppet Forge [\#100](https://github.com/Icinga/puppet-icinga2/issues/100)
- Fix Puppet version requirement in metadata.json [\#205](https://github.com/Icinga/puppet-icinga2/issues/205)

**Merged pull requests:**

- Improve wording for a few parts of the README.md file [\#201](https://github.com/Icinga/puppet-icinga2/pull/201) ([gunnarbeutner](https://github.com/gunnarbeutner))
- Extended example 3 README to mention Puppet parser bug [\#45](https://github.com/Icinga/puppet-icinga2/pull/45) ([kwisatz](https://github.com/kwisatz))
- Improving README [\#44](https://github.com/Icinga/puppet-icinga2/pull/44) ([lazyfrosch](https://github.com/lazyfrosch))

## [v0.8.1](https://github.com/Icinga/puppet-icinga2/tree/v0.8.1) (2017-01-11)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v0.8.0...v0.8.1)

**Fixed bugs:**

- \[dev.icinga.com \#13919\] Fix imports object template [\#195](https://github.com/Icinga/puppet-icinga2/issues/195)
- \[dev.icinga.com \#13917\] Remove hash validation of vars attribut [\#194](https://github.com/Icinga/puppet-icinga2/issues/194)

**Merged pull requests:**

- Parallelisation problems with Travis on Ruby 2.1 [\#42](https://github.com/Icinga/puppet-icinga2/pull/42) ([lazyfrosch](https://github.com/lazyfrosch))

## [v0.8.0](https://github.com/Icinga/puppet-icinga2/tree/v0.8.0) (2017-01-04)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v0.7.2...v0.8.0)

**Implemented enhancements:**

- \[dev.icinga.com \#13875\] Add TLS options for api feature [\#191](https://github.com/Icinga/puppet-icinga2/issues/191)
- \[dev.icinga.com \#13873\] Get fixtures for specs from Puppet Forge [\#190](https://github.com/Icinga/puppet-icinga2/issues/190)
- \[dev.icinga.com \#13501\] Add support for Parallel Spec Tests [\#156](https://github.com/Icinga/puppet-icinga2/issues/156)

**Fixed bugs:**

- \[dev.icinga.com \#13877\] Fix SUSE repo [\#192](https://github.com/Icinga/puppet-icinga2/issues/192)
- \[dev.icinga.com \#13871\] Remove json, json\_pure dependency for Ruby \>= 2 [\#189](https://github.com/Icinga/puppet-icinga2/issues/189)
- \[dev.icinga.com \#13867\] Travis-CI test with Puppet \< 4 [\#188](https://github.com/Icinga/puppet-icinga2/issues/188)
- \[dev.icinga.com \#13863\] Make puppet lint happy [\#187](https://github.com/Icinga/puppet-icinga2/issues/187)
- \[dev.icinga.com \#13799\] change attribute checkcommand to checkcommand\_name in object checkcommand [\#176](https://github.com/Icinga/puppet-icinga2/issues/176)
- \[dev.icinga.com \#13797\] change attribute apiuser to apiuser\_name in object apiuser [\#175](https://github.com/Icinga/puppet-icinga2/issues/175)
- \[dev.icinga.com \#13795\] change attribute zone to zone\_name in object zone [\#174](https://github.com/Icinga/puppet-icinga2/issues/174)
- \[dev.icinga.com \#13793\] change attribute endpoint to endpoint\_name in object endpoint [\#173](https://github.com/Icinga/puppet-icinga2/issues/173)
- \[dev.icinga.com \#13791\] change attribute hostname to host\_name in object host [\#172](https://github.com/Icinga/puppet-icinga2/issues/172)

**Merged pull requests:**

- feature/api: Add TLS detail settings [\#41](https://github.com/Icinga/puppet-icinga2/pull/41) ([lazyfrosch](https://github.com/lazyfrosch))
- Rakefile: Add and enable parallel\_spec by default [\#40](https://github.com/Icinga/puppet-icinga2/pull/40) ([lazyfrosch](https://github.com/lazyfrosch))
- Make Puppet Lint happy [\#37](https://github.com/Icinga/puppet-icinga2/pull/37) ([lazyfrosch](https://github.com/lazyfrosch))
- Enabling Travis CI [\#36](https://github.com/Icinga/puppet-icinga2/pull/36) ([lazyfrosch](https://github.com/lazyfrosch))

## [v0.7.2](https://github.com/Icinga/puppet-icinga2/tree/v0.7.2) (2017-01-02)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v0.7.1...v0.7.2)

**Implemented enhancements:**

- \[dev.icinga.com \#13333\] Support collecting exported zones and endpoints [\#152](https://github.com/Icinga/puppet-icinga2/issues/152)
- \[dev.icinga.com \#13835\] Added an example that uses exported resources [\#186](https://github.com/Icinga/puppet-icinga2/issues/186)

**Fixed bugs:**

- \[dev.icinga.com \#13779\] add attribute notificationcommand\_name to object notificationcommand [\#166](https://github.com/Icinga/puppet-icinga2/issues/166)
- \[dev.icinga.com \#13833\] Add possibility to set command parameter as String. [\#185](https://github.com/Icinga/puppet-icinga2/issues/185)
- \[dev.icinga.com \#13831\] fix target as undef in several objects [\#184](https://github.com/Icinga/puppet-icinga2/issues/184)
- \[dev.icinga.com \#13829\] fix target as undef in several objects [\#183](https://github.com/Icinga/puppet-icinga2/issues/183)

**Merged pull requests:**

- Added an example that uses exported resources to create a master-agent set-up using exported resources. [\#32](https://github.com/Icinga/puppet-icinga2/pull/32) ([kwisatz](https://github.com/kwisatz))

## [v0.7.1](https://github.com/Icinga/puppet-icinga2/tree/v0.7.1) (2016-12-28)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v0.7.0...v0.7.1)

**Fixed bugs:**

- \[dev.icinga.com \#13821\] fix feature debuglog [\#182](https://github.com/Icinga/puppet-icinga2/issues/182)
- \[dev.icinga.com \#13819\] fix object checkcommand [\#181](https://github.com/Icinga/puppet-icinga2/issues/181)
- \[dev.icinga.com \#13817\] fix feature mainlog [\#180](https://github.com/Icinga/puppet-icinga2/issues/180)
- \[dev.icinga.com \#13815\] add  attribute notificationcommand\_name to object notificationcommand [\#179](https://github.com/Icinga/puppet-icinga2/issues/179)
- \[dev.icinga.com \#13803\] fix documentation of all objects [\#178](https://github.com/Icinga/puppet-icinga2/issues/178)
- \[dev.icinga.com \#13801\] change title of concat\_fragment in object to title [\#177](https://github.com/Icinga/puppet-icinga2/issues/177)
- \[dev.icinga.com \#13789\] add attribute usergroup\_name to object usergroup [\#171](https://github.com/Icinga/puppet-icinga2/issues/171)
- \[dev.icinga.com \#13787\] add attribute user\_name to object user [\#170](https://github.com/Icinga/puppet-icinga2/issues/170)
- \[dev.icinga.com \#13785\] add attribute timeperiod\_name to object timeperiod [\#169](https://github.com/Icinga/puppet-icinga2/issues/169)
- \[dev.icinga.com \#13783\] add attribute servicegroup\_name to object servicegroup [\#168](https://github.com/Icinga/puppet-icinga2/issues/168)
- \[dev.icinga.com \#13781\] add attribute scheduleddowntime\_name to object scheduleddowntime [\#167](https://github.com/Icinga/puppet-icinga2/issues/167)
- \[dev.icinga.com \#13777\] add attribute notification\_name to object notification [\#165](https://github.com/Icinga/puppet-icinga2/issues/165)
- \[dev.icinga.com \#13775\] add attribute eventcommand\_name to object eventcommand [\#164](https://github.com/Icinga/puppet-icinga2/issues/164)
- \[dev.icinga.com \#13773\] add attribute dependency\_name to object dependency  [\#163](https://github.com/Icinga/puppet-icinga2/issues/163)
- \[dev.icinga.com \#13771\] add attribute compatlogger\_name to object compatlogger [\#162](https://github.com/Icinga/puppet-icinga2/issues/162)
- \[dev.icinga.com \#13769\] add attribute checkresultreader\_name to object checkresultreader [\#161](https://github.com/Icinga/puppet-icinga2/issues/161)
- \[dev.icinga.com \#13767\] add attribute service\_name to object service [\#160](https://github.com/Icinga/puppet-icinga2/issues/160)
- \[dev.icinga.com \#13701\] Calling private method "Puppet.settings.preferred\_run\_mode=" in facter/icinga2\_puppet.rb breaks Puppet master [\#159](https://github.com/Icinga/puppet-icinga2/issues/159)

**Merged pull requests:**

- Add possibility to use ip or hostname. [\#31](https://github.com/Icinga/puppet-icinga2/pull/31) ([n00by](https://github.com/n00by))
- Fix non-breaking space. [\#30](https://github.com/Icinga/puppet-icinga2/pull/30) ([n00by](https://github.com/n00by))
- Don't call private method preferred\_run\_mode= in facts [\#29](https://github.com/Icinga/puppet-icinga2/pull/29) ([antaflos](https://github.com/antaflos))

## [v0.7.0](https://github.com/Icinga/puppet-icinga2/tree/v0.7.0) (2016-12-15)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v0.6.0...v0.7.0)

**Implemented enhancements:**

- \[dev.icinga.com \#12344\] CA handling using file ressource [\#50](https://github.com/Icinga/puppet-icinga2/issues/50)
- \[dev.icinga.com \#13513\] Rework default order values for all objects [\#158](https://github.com/Icinga/puppet-icinga2/issues/158)
- \[dev.icinga.com \#13511\] Add custom config fragment [\#157](https://github.com/Icinga/puppet-icinga2/issues/157)
- \[dev.icinga.com \#13495\] CA handling using the icinga2 CLI [\#155](https://github.com/Icinga/puppet-icinga2/issues/155)
- \[dev.icinga.com \#13385\] Add Travis CI Tests [\#154](https://github.com/Icinga/puppet-icinga2/issues/154)
- \[dev.icinga.com \#12653\] Add Support for SLES 12 [\#96](https://github.com/Icinga/puppet-icinga2/issues/96)
- \[dev.icinga.com \#12652\] CA handling using custom function from puppet-icinga2-legacy [\#95](https://github.com/Icinga/puppet-icinga2/issues/95)
- \[dev.icinga.com \#12651\] CA handling with base64 encoded string [\#94](https://github.com/Icinga/puppet-icinga2/issues/94)

**Fixed bugs:**

- \[dev.icinga.com \#13365\] Wrong MySQL user grants for schema import in docs [\#153](https://github.com/Icinga/puppet-icinga2/issues/153)

**Merged pull requests:**

- make service validation consistent with host validation [\#26](https://github.com/Icinga/puppet-icinga2/pull/26) ([deric](https://github.com/deric))
- update influxdb documentation [\#25](https://github.com/Icinga/puppet-icinga2/pull/25) ([deric](https://github.com/deric))
- \[OSMC Hackathon\] Adding initial SLES support [\#24](https://github.com/Icinga/puppet-icinga2/pull/24) ([jfryman](https://github.com/jfryman))
- Remove duplicate target parameter section in icinga2::object::timeper… [\#23](https://github.com/Icinga/puppet-icinga2/pull/23) ([kwisatz](https://github.com/kwisatz))
- fix small typos [\#22](https://github.com/Icinga/puppet-icinga2/pull/22) ([xorpaul](https://github.com/xorpaul))

## [v0.6.0](https://github.com/Icinga/puppet-icinga2/tree/v0.6.0) (2016-11-23)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v0.5.0...v0.6.0)

**Implemented enhancements:**

- \[dev.icinga.com \#12982\] Red Hat Satellite / Puppet 3.x compatibility [\#142](https://github.com/Icinga/puppet-icinga2/issues/142)
- \[dev.icinga.com \#12374\] Object Downtime [\#80](https://github.com/Icinga/puppet-icinga2/issues/80)
- \[dev.icinga.com \#12371\] Object Comment [\#77](https://github.com/Icinga/puppet-icinga2/issues/77)
- \[dev.icinga.com \#13219\] How attribute parsing works documentation [\#150](https://github.com/Icinga/puppet-icinga2/issues/150)
- \[dev.icinga.com \#13181\] Apply Rules Docs [\#147](https://github.com/Icinga/puppet-icinga2/issues/147)
- \[dev.icinga.com \#12960\] Consider function calls in attributes parsing [\#140](https://github.com/Icinga/puppet-icinga2/issues/140)
- \[dev.icinga.com \#12959\] Attribute function does not included adding value [\#139](https://github.com/Icinga/puppet-icinga2/issues/139)
- \[dev.icinga.com \#12958\] Add parsing of assign rules to attribute function [\#138](https://github.com/Icinga/puppet-icinga2/issues/138)
- \[dev.icinga.com \#12957\] Extend attributes Function [\#137](https://github.com/Icinga/puppet-icinga2/issues/137)
- \[dev.icinga.com \#12878\] Extend attributes fct to parse connected strings [\#136](https://github.com/Icinga/puppet-icinga2/issues/136)
- \[dev.icinga.com \#12839\] use-fct-attributes-for-other-configs [\#126](https://github.com/Icinga/puppet-icinga2/issues/126)
- \[dev.icinga.com \#12387\] Object UserGroup [\#92](https://github.com/Icinga/puppet-icinga2/issues/92)
- \[dev.icinga.com \#12385\] Object User [\#91](https://github.com/Icinga/puppet-icinga2/issues/91)
- \[dev.icinga.com \#12384\] Object TimePeriod [\#90](https://github.com/Icinga/puppet-icinga2/issues/90)
- \[dev.icinga.com \#12383\] Object ServiceGroup [\#89](https://github.com/Icinga/puppet-icinga2/issues/89)
- \[dev.icinga.com \#12382\] Object Service [\#88](https://github.com/Icinga/puppet-icinga2/issues/88)
- \[dev.icinga.com \#12381\] Object ScheduledDowntime [\#87](https://github.com/Icinga/puppet-icinga2/issues/87)
- \[dev.icinga.com \#12380\] Object NotificationCommand [\#86](https://github.com/Icinga/puppet-icinga2/issues/86)
- \[dev.icinga.com \#12379\] Object Notification [\#85](https://github.com/Icinga/puppet-icinga2/issues/85)
- \[dev.icinga.com \#12378\] Object HostGroup [\#84](https://github.com/Icinga/puppet-icinga2/issues/84)
- \[dev.icinga.com \#12377\] Object Host [\#83](https://github.com/Icinga/puppet-icinga2/issues/83)
- \[dev.icinga.com \#12376\] Object EventCommand [\#82](https://github.com/Icinga/puppet-icinga2/issues/82)
- \[dev.icinga.com \#12373\] Object Dependency [\#79](https://github.com/Icinga/puppet-icinga2/issues/79)
- \[dev.icinga.com \#12372\] Object CompatLogger [\#78](https://github.com/Icinga/puppet-icinga2/issues/78)
- \[dev.icinga.com \#12370\] Object CheckResultReader [\#76](https://github.com/Icinga/puppet-icinga2/issues/76)
- \[dev.icinga.com \#12369\] Object CheckCommand [\#75](https://github.com/Icinga/puppet-icinga2/issues/75)
- \[dev.icinga.com \#12349\] Apply Rules [\#55](https://github.com/Icinga/puppet-icinga2/issues/55)

**Fixed bugs:**

- \[dev.icinga.com \#13217\] Icinga Functions don't parse correctly [\#149](https://github.com/Icinga/puppet-icinga2/issues/149)
- \[dev.icinga.com \#13207\] Wrong config for attribute vars in level 3 hash [\#148](https://github.com/Icinga/puppet-icinga2/issues/148)
- \[dev.icinga.com \#13179\] Ruby 1.8 testing [\#146](https://github.com/Icinga/puppet-icinga2/issues/146)
- \[dev.icinga.com \#13149\] "in" is a keyword for assignment [\#145](https://github.com/Icinga/puppet-icinga2/issues/145)
- \[dev.icinga.com \#13123\] Objects with required parameters [\#144](https://github.com/Icinga/puppet-icinga2/issues/144)
- \[dev.icinga.com \#13035\] Wrong syntax of "apply" in object.conf.erb template \(afaik\) [\#143](https://github.com/Icinga/puppet-icinga2/issues/143)
- \[dev.icinga.com \#12980\] Symlinks in modules are not allowed in puppet modules [\#141](https://github.com/Icinga/puppet-icinga2/issues/141)

**Merged pull requests:**

- Proposal \(to be discussed\) for allowing function that USE context [\#20](https://github.com/Icinga/puppet-icinga2/pull/20) ([kwisatz](https://github.com/kwisatz))

## [v0.5.0](https://github.com/Icinga/puppet-icinga2/tree/v0.5.0) (2016-10-10)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v0.4.0...v0.5.0)

**Implemented enhancements:**

- \[dev.icinga.com \#12859\] Doc example for creating IDO database [\#129](https://github.com/Icinga/puppet-icinga2/issues/129)
- \[dev.icinga.com \#12836\] Write profile class examples [\#124](https://github.com/Icinga/puppet-icinga2/issues/124)
- \[dev.icinga.com \#12806\] Rework feature idopgsql [\#121](https://github.com/Icinga/puppet-icinga2/issues/121)
- \[dev.icinga.com \#12805\] Rework feature idomysql [\#120](https://github.com/Icinga/puppet-icinga2/issues/120)
- \[dev.icinga.com \#12804\] Rework feature influxdb [\#119](https://github.com/Icinga/puppet-icinga2/issues/119)
- \[dev.icinga.com \#12802\] Usage documentation [\#118](https://github.com/Icinga/puppet-icinga2/issues/118)
- \[dev.icinga.com \#12801\] Adjust SSL settings for features [\#117](https://github.com/Icinga/puppet-icinga2/issues/117)
- \[dev.icinga.com \#12771\] Add parameter ensure to objects [\#114](https://github.com/Icinga/puppet-icinga2/issues/114)
- \[dev.icinga.com \#12759\] Extend api feature with endpoints and zones parameter [\#113](https://github.com/Icinga/puppet-icinga2/issues/113)
- \[dev.icinga.com \#12754\] features-with-objects [\#112](https://github.com/Icinga/puppet-icinga2/issues/112)
- \[dev.icinga.com \#12388\] Object Zone [\#93](https://github.com/Icinga/puppet-icinga2/issues/93)
- \[dev.icinga.com \#12375\] Object Endpoint [\#81](https://github.com/Icinga/puppet-icinga2/issues/81)
- \[dev.icinga.com \#12368\] Object ApiUser [\#74](https://github.com/Icinga/puppet-icinga2/issues/74)
- \[dev.icinga.com \#12367\] Objects [\#73](https://github.com/Icinga/puppet-icinga2/issues/73)

**Fixed bugs:**

- \[dev.icinga.com \#12875\] Icinga2 does not start on Windows [\#135](https://github.com/Icinga/puppet-icinga2/issues/135)
- \[dev.icinga.com \#12871\] Please replace facts icinga2\_puppet\_\* by $::settings [\#133](https://github.com/Icinga/puppet-icinga2/issues/133)
- \[dev.icinga.com \#12872\] Add Requires to basic config for features and objects that need additional packages [\#134](https://github.com/Icinga/puppet-icinga2/issues/134)
- \[dev.icinga.com \#12867\] Feature-statusdata-update-interval-default [\#132](https://github.com/Icinga/puppet-icinga2/issues/132)
- \[dev.icinga.com \#12865\] Class scoping [\#131](https://github.com/Icinga/puppet-icinga2/issues/131)
- \[dev.icinga.com \#12864\] debian based system repo handling [\#130](https://github.com/Icinga/puppet-icinga2/issues/130)
- \[dev.icinga.com \#12858\] Doc example class icinga2 [\#128](https://github.com/Icinga/puppet-icinga2/issues/128)
- \[dev.icinga.com \#12857\] Default owner of config dir [\#127](https://github.com/Icinga/puppet-icinga2/issues/127)
- \[dev.icinga.com \#12837\] File permission on windows [\#125](https://github.com/Icinga/puppet-icinga2/issues/125)
- \[dev.icinga.com \#12821\] Unify windows unit tests [\#123](https://github.com/Icinga/puppet-icinga2/issues/123)
- \[dev.icinga.com \#12809\] Path of Puppet keys and certs broken [\#122](https://github.com/Icinga/puppet-icinga2/issues/122)
- \[dev.icinga.com \#12797\] windows line-breaks for objects [\#116](https://github.com/Icinga/puppet-icinga2/issues/116)
- \[dev.icinga.com \#12775\] Api feature unit tests fail for windows [\#115](https://github.com/Icinga/puppet-icinga2/issues/115)

## [v0.4.0](https://github.com/Icinga/puppet-icinga2/tree/v0.4.0) (2016-09-22)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v0.3.1...v0.4.0)

**Implemented enhancements:**

- \[dev.icinga.com \#12720\] Feature ido-pgsql [\#108](https://github.com/Icinga/puppet-icinga2/issues/108)
- \[dev.icinga.com \#12706\] Implement host\_format\_template and service\_format\_template for perfdata feature [\#105](https://github.com/Icinga/puppet-icinga2/issues/105)
- \[dev.icinga.com \#12363\] Feature ido-mysql [\#69](https://github.com/Icinga/puppet-icinga2/issues/69)

**Fixed bugs:**

- \[dev.icinga.com \#12743\] paths in api feature must be quoted [\#111](https://github.com/Icinga/puppet-icinga2/issues/111)

## [v0.3.1](https://github.com/Icinga/puppet-icinga2/tree/v0.3.1) (2016-09-16)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v0.2.0...v0.3.1)

**Implemented enhancements:**

- \[dev.icinga.com \#12693\] Fix fixtures.yaml [\#102](https://github.com/Icinga/puppet-icinga2/issues/102)
- \[dev.icinga.com \#12366\] Feature notification [\#72](https://github.com/Icinga/puppet-icinga2/issues/72)
- \[dev.icinga.com \#12365\] Feature mainlog  [\#71](https://github.com/Icinga/puppet-icinga2/issues/71)
- \[dev.icinga.com \#12364\] Feature influxdb  [\#70](https://github.com/Icinga/puppet-icinga2/issues/70)
- \[dev.icinga.com \#12362\] Feature graphite  [\#68](https://github.com/Icinga/puppet-icinga2/issues/68)
- \[dev.icinga.com \#12361\] Feature checker  [\#67](https://github.com/Icinga/puppet-icinga2/issues/67)
- \[dev.icinga.com \#12360\] Feature syslog [\#66](https://github.com/Icinga/puppet-icinga2/issues/66)
- \[dev.icinga.com \#12359\] Feature statusdata  [\#65](https://github.com/Icinga/puppet-icinga2/issues/65)
- \[dev.icinga.com \#12358\] Feature perfdata  [\#64](https://github.com/Icinga/puppet-icinga2/issues/64)
- \[dev.icinga.com \#12357\] Feature opentsdb  [\#63](https://github.com/Icinga/puppet-icinga2/issues/63)
- \[dev.icinga.com \#12356\] Feature livestatus  [\#62](https://github.com/Icinga/puppet-icinga2/issues/62)
- \[dev.icinga.com \#12355\] Feature gelf  [\#61](https://github.com/Icinga/puppet-icinga2/issues/61)
- \[dev.icinga.com \#12354\] Feature debuglog  [\#60](https://github.com/Icinga/puppet-icinga2/issues/60)
- \[dev.icinga.com \#12353\] Feature compatlog  [\#59](https://github.com/Icinga/puppet-icinga2/issues/59)
- \[dev.icinga.com \#12352\] Feature command  [\#58](https://github.com/Icinga/puppet-icinga2/issues/58)
- \[dev.icinga.com \#12351\] Feature api  [\#57](https://github.com/Icinga/puppet-icinga2/issues/57)
- \[dev.icinga.com \#12350\] Features [\#56](https://github.com/Icinga/puppet-icinga2/issues/56)
- \[dev.icinga.com \#12343\] Use certificates generated by Puppet [\#49](https://github.com/Icinga/puppet-icinga2/issues/49)

**Fixed bugs:**

- \[dev.icinga.com \#12724\] RSpec tests without effect [\#109](https://github.com/Icinga/puppet-icinga2/issues/109)
- \[dev.icinga.com \#12714\] 32bit for Windows [\#107](https://github.com/Icinga/puppet-icinga2/issues/107)
- \[dev.icinga.com \#12713\] unit test for all defaults in feature mainlog [\#106](https://github.com/Icinga/puppet-icinga2/issues/106)
- \[dev.icinga.com \#12698\] Params inheritance in features [\#104](https://github.com/Icinga/puppet-icinga2/issues/104)
- \[dev.icinga.com \#12696\] Notify service when features-available/feature.conf is created [\#103](https://github.com/Icinga/puppet-icinga2/issues/103)
- \[dev.icinga.com \#12692\] Fix mlodule depency Typo for module puppetlabs/chocolaty [\#101](https://github.com/Icinga/puppet-icinga2/issues/101)
- \[dev.icinga.com \#12738\] Duplicate declaration File\[/etc/icinga2/pki\] [\#110](https://github.com/Icinga/puppet-icinga2/issues/110)

## [v0.2.0](https://github.com/Icinga/puppet-icinga2/tree/v0.2.0) (2016-09-09)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v0.1.0...v0.2.0)

**Implemented enhancements:**

- \[dev.icinga.com \#12658\] Decide whether or not to drop support for Puppet 3.x and below [\#99](https://github.com/Icinga/puppet-icinga2/issues/99)
- \[dev.icinga.com \#12657\] Unit tests should cover every supported OS/Distro instead of just one [\#98](https://github.com/Icinga/puppet-icinga2/issues/98)
- \[dev.icinga.com \#12346\] Add Support for Ubuntu 14.04, 16.04 [\#52](https://github.com/Icinga/puppet-icinga2/issues/52)
- \[dev.icinga.com \#12341\] Config handling [\#47](https://github.com/Icinga/puppet-icinga2/issues/47)

**Fixed bugs:**

- \[dev.icinga.com \#12656\] Inheritance [\#97](https://github.com/Icinga/puppet-icinga2/issues/97)

## [v0.1.0](https://github.com/Icinga/puppet-icinga2/tree/v0.1.0) (2016-09-06)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v0.6.2...v0.1.0)

**Implemented enhancements:**

- \[dev.icinga.com \#12348\] Add Support for Windows [\#54](https://github.com/Icinga/puppet-icinga2/issues/54)
- \[dev.icinga.com \#12347\] Add Support for CentOS 6, 7 [\#53](https://github.com/Icinga/puppet-icinga2/issues/53)
- \[dev.icinga.com \#12345\] Add Support for Debian 7, 8 [\#51](https://github.com/Icinga/puppet-icinga2/issues/51)
- \[dev.icinga.com \#12342\] Repo management [\#48](https://github.com/Icinga/puppet-icinga2/issues/48)
- \[dev.icinga.com \#12340\] Installation [\#46](https://github.com/Icinga/puppet-icinga2/issues/46)

## [v0.6.2](https://github.com/Icinga/puppet-icinga2/tree/v0.6.2) (2015-01-30)
[Full Changelog](https://github.com/Icinga/puppet-icinga2/compare/v0.6.1...v0.6.2)

## [v0.6.1](https://github.com/Icinga/puppet-icinga2/tree/v0.6.1) (2014-12-03)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*