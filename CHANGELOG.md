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
