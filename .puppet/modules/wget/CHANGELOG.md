## 1.3.4 (June 10, 2019)

Improvements:

- Updated minimum `puppet` version to 5.5.10.
- Updated os support matrix.

## 1.3.3 (April 29, 2019)

Improvements:

- Updated `pdk` templates.

## 1.3.2 (January 1, 2019)

Improvements:

- Updated `pdk` templates.

## 1.3.1 (December 9, 2018)

Improvements:

- Updated `pdk` templates.
- Updated os support matrix.

## 1.3.0 (October 14, 2018)

Improvements:

- Updated `pdk` templates.
- Added support for `puppet` version 6.

## 1.2.3 (August 31, 2018)

Improvements:

- Updated `pdk` templates.
- Added tests for Debian 9 release.
- Updated `puppetlabs-stdlib` dependency version.
- Fixed minor documentation issues.

## 1.2.2 (June 30, 2018)

Improvements:

- Updated `pdk` templates.
- Added tests for Ubuntu 18.04 release.
- Fixed minor documentation issues.

## 1.2.1 (May 6, 2018)

Improvements:

- Updated `pdk` templates.
- Updated minimum required `puppet` version to `4.10.0`.

## 1.2.0 (April 18, 2018)

Improvements:

  - Updated module to be `pdk` compliant.

## 1.1.7 (February 12, 2018)

Improvements:

  - Updated module data to `hiera 5`.
  - Added support for newer OS releases.

## 1.1.6 (November 24, 2017)

Improvements:

  - Implemented Puppet 4 module data pattern using `hiera` for module defaults and removed `params.pp`.
  - Added support for Puppet 5.

## 1.1.5 (June 30, 2017)

Bugfixes:

  - Fixed the type in retrievals hiera name.
  - Fixed the missing wget::package warning in retrieve.

## 1.1.4 (June 11, 2017)

Improvements:

  - Replace deprecated `hiera_hash` to `lookup`.
  - Update minimum puppet version required is set to `4.7.0`.

Bugfixes:

  - Fix the style issues in chaining arrows.

## 1.1.3 (March 26, 2017)

Bugfixes:

  - Fix broken default values from params.pp.

## 1.1.2 (March 25, 2017)

Bugfixes:

  - Minor correction of date in changelog.

## 1.1.1 (March 25, 2017)

Bugfixes:

  - Restore `params.pp` file to avoid test failures in down stream modules.

## 1.1.0 (December 27, 2016)

Improvements:

  - Implemented Puppet 4 module data pattern using `hiera` for module defaults and removed `params.pp`.
  - Improved tests using `rspec-puppet-facts` to cover all supported platforms.

## 1.0.1 (December 26, 2016)

Bugfixes:

  - Fix minor documentation errors.

## 1.0.0 (December 25, 2016)

Features:

  - Initial release
