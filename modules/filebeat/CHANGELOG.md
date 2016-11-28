Changelog
=========

## Unreleased
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.6...HEAD)

## [v0.8.6](https://github.com/pcfens/puppet-filebeat/tree/v0.8.6)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.5...v0.8.6)

- Sort field keys [\#55](https://github.com/pcfens/puppet-filebeat/pull/55),
[\#57](https://github.com/pcfens/puppet-filebeat/issues/57)
- Refresh the filebeat service when packages are updated [\#56](https://github.com/pcfens/puppet-filebeat/issues/56)


## [v0.8.5](https://github.com/pcfens/puppet-filebeat/tree/v0.8.5)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.4...v0.8.5)

- Check the kafka partition hash before checking for sub-hashes [\#54](https://github.com/pcfens/puppet-filebeat/pull/54)

## [v0.8.4](https://github.com/pcfens/puppet-filebeat/tree/v0.8.4)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.3...v0.8.4)

- Fix regression: Add the SSL label to the filebeat 5 template. [\#53](https://github.com/pcfens/puppet-filebeat/pull/53)

## [v0.8.3](https://github.com/pcfens/puppet-filebeat/tree/v0.8.3)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.2...v0.8.3)

- Don't use a possibly undefined array's length to determine if it should be
  iterated over [\#52](https://github.com/pcfens/puppet-filebeat/pull/52)

## [v0.8.2](https://github.com/pcfens/puppet-filebeat/tree/v0.8.2)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.1...v0.8.2)

- Correctly set document type for v5 prospectors [\#51](https://github.com/pcfens/puppet-filebeat/pull/51)

## [v0.8.1](https://github.com/pcfens/puppet-filebeat/tree/v0.8.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.0...v0.8.1)

- Don't manage the apt-transport-https package on Debian systems [\#49](https://github.com/pcfens/puppet-filebeat/pull/49)
- undefined values shouldn't be rendered by the filebeat5 template [\#50](https://github.com/pcfens/puppet-filebeat/pull/50)

## [v0.8.0](https://github.com/pcfens/puppet-filebeat/tree/v0.8.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.7.4...v0.8.0)

**Enhancements**
- Add support for Filebeat v5.

If you use this module on a system with filebeat 1.x installed, and you keep your current parameters
nothing will change. Setting `major_version` to '5' will modify the configuration template and update
package repositories, but won't update the package itself. To update the package set the
`package_ensure` parameter to at least 5.0.0.

- Add a parameter `use_generic_template` that uses a more generic version of the configuration
  template. The generic template is more future proof (if types are correct), but looks
  very different than the example file.


## [v0.7.4](https://github.com/pcfens/puppet-filebeat/tree/v0.7.4)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.7.2...v0.7.4)

Version 0.7.3 was never released even though it is tagged.

- Fixed some testing issues that were caused by changes to external resources

**Fixed Bugs**
- Some redis configuration options were not generated as integers [\#38](https://github.com/pcfens/puppet-filebeat/issues/38)

## [v0.7.2](https://github.com/pcfens/puppet-filebeat/tree/v0.7.2)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.7.1...v0.7.2)

- Wrap regular expressions in single quotes [\#31](https://github.com/pcfens/puppet-filebeat/pull/31) and [\#35](https://github.com/pcfens/puppet-filebeat/pull/35)
- Use the default Windows temporary folder (C:\Windows\Temp) by default [\#33](https://github.com/pcfens/puppet-filebeat/pull/33)

## [v0.7.1](https://github.com/pcfens/puppet-filebeat/tree/v0.7.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.7.0...v0.7.1)

- Allow the config file to be written to an alternate location. Be sure and read limitations before you use this.

**Fixed Bugs**
- Add elasticsearch and logstash port setting to Ruby 1.8 template
  [\#29](https://github.com/pcfens/puppet-filebeat/issues/29)

## [v0.7.0](https://github.com/pcfens/puppet-filebeat/tree/v0.7.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.6.3...v0.7.0)

- Setting the `prospectors_merge` parameter to true will create prospectors across multiple hiera levels
  using `hiera_hash()` [\#25](https://github.com/pcfens/puppet-filebeat/pull/25)
- No longer manage the windows temp directory where the Filebeat download is kept. The assumption is made
  that the directory exists and is writable by puppet.
- Update the default windows download to Filebeat version 1.2.3
- Add redis output to the Ruby 1.8 template
- Wrap include_lines and exclude_lines array elements in quotes [\#28](https://github.com/pcfens/puppet-filebeat/issues/28)

**Fixed Bugs**
- SLES repository and metaparameters didn't match [\#25](https://github.com/pcfens/puppet-filebeat/pull/25)

## [v0.6.3](https://github.com/pcfens/puppet-filebeat/tree/v0.6.3)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.6.2...v0.6.3)

**Fixed Bugs**
- Spool size default should match upstream [\#24](https://github.com/pcfens/puppet-filebeat/pull/24)
- Repository names now match notification parameters Part of [\#25](https://github.com/pcfens/puppet-filebeat/pull/25)

## [v0.6.2](https://github.com/pcfens/puppet-filebeat/tree/v0.6.2)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.6.1...v0.6.2)

**Fixed Bugs**
- Fix the other certificate_key typo in Ruby 1.8 template
[\#23](https://github.com/pcfens/puppet-filebeat/issues/23)


## [v0.6.1](https://github.com/pcfens/puppet-filebeat/tree/v0.6.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.6.0...v0.6.1)

**Fixed Bugs**
- Fix typo in Ruby 1.8 template [\#23](https://github.com/pcfens/puppet-filebeat/issues/23)


## [v0.6.0](https://github.com/pcfens/puppet-filebeat/tree/v0.6.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.8...v0.6.0)

- Add the `close_older` parameter to support the option of the same name in filebeat 1.2.0
- Add support for the `publish_async` parameter.

**Fixed Bugs**
- Added limited, but improved support for Ruby versions pre-1.9.1 by fixing the hash sort issue
[\#20](https://github.com/pcfens/puppet-filebeat/issues/20)

## [v0.5.8](https://github.com/pcfens/puppet-filebeat/tree/v0.5.8)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.7...v0.5.8)

**Fixed Bugs**
- `doc_type` is now used in the documentation instead of the deprecated `log_type`
  [\#17](https://github.com/pcfens/puppet-filebeat/pull/17)
- RedHat based systems should be using the redhat service provider.
  [\#18](https://github.com/pcfens/puppet-filebeat/pull/18)


## [v0.5.7](https://github.com/pcfens/puppet-filebeat/tree/v0.5.7)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.6...v0.5.7)

**Fixed Bugs**
- Some configuration parameters should be rendered as integers, not strings
  [\#15](https://github.com/pcfens/puppet-filebeat/pull/15)


## [v0.5.6](https://github.com/pcfens/puppet-filebeat/tree/v0.5.6)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.5...v0.5.6)

**Fixed Bugs**
- Configuration files should use the `conf_template` parameter [\#14](https://github.com/pcfens/puppet-filebeat/pull/14)

## [v0.5.5](https://github.com/pcfens/puppet-filebeat/tree/v0.5.5)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.4...v0.5.5)

**Fixed Bugs**
- `rotate_every_kb` and `number_of_files` parameters in file outputs should be
  explicitly integers to keep filebeat happy. [\#13](https://github.com/pcfens/puppet-filebeat/issues/13)

## [v0.5.4](https://github.com/pcfens/puppet-filebeat/tree/v0.5.4)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.2...v0.5.4)

**Fixed Bugs**
- Fix template regression in v0.5.3

## [v0.5.2](https://github.com/pcfens/puppet-filebeat/tree/v0.5.2)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.1...v0.5.2)

- Use the anchor pattern instead of contain so that older versions of puppet
  are supported [\#12](https://github.com/pcfens/puppet-filebeat/pull/12)

## [v0.5.1](https://github.com/pcfens/puppet-filebeat/tree/v0.5.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.0...v0.5.1)

- Update metadata to reflect which versions of puppet are supported.

## [v0.5.0](https://github.com/pcfens/puppet-filebeat/tree/v0.5.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.4.1...v0.5.0)

- For prospectors, deprecate `log_type` in favor of `doc_type` to better
  match the actual configuration parameter. `document_type` is not used because
  it causes errors when running with a puppet master. `log_type` will be fully
  removed before module version 1.0.
  [\#9](https://github.com/pcfens/puppet-filebeat/issues/9)

**New Features**
- Add support for `exclude_files`, `exclude_lines`, `include_lines`, and `multiline`.
  Use of the new parameters requires a filebeat version >= 1.1
  ([\#10](https://github.com/pcfens/puppet-filebeat/issues/10), [\#11](https://github.com/pcfens/puppet-filebeat/issues/11))

## [v0.4.1](https://github.com/pcfens/puppet-filebeat/tree/v0.4.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.4.0...v0.4.1)

**Fixed Bugs**
- Fix links in documentation to match the updated documentation

**New Features**
- Change repository resource names to beats (e.g. apt::source['beats'], etc.),
  and only declare them if they haven't already been declared. This way we only
  have one module for all beats modules managed through puppet.

## [v0.4.0](https://github.com/pcfens/puppet-filebeat/tree/v0.4.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.3.1...v0.4.0)

This is the first release that includes changelog. Since v0.3.1:

**Fixed Bugs**
- 'fields' parse error in prospector.yml template [\#7](https://github.com/pcfens/puppet-filebeat/pull/7)

**New Features**
- Windows support [\#3](https://github.com/pcfens/puppet-filebeat/pull/3)
  - Requires the [`puppetlabs/powershell`](https://forge.puppetlabs.com/puppetlabs/powershell)
  and [`lwf/remote_file`](https://forge.puppetlabs.com/lwf/remote_file) modules.
- Config file and folder permissions can be managed [\#8](https://github.com/pcfens/puppet-filebeat/pull/8)
