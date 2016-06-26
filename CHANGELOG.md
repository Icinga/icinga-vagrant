## 2016-05-30 - Release 0.9.8

YUM group commands can set exec. timeout and respect hidden groups.
Fix yum plugins on RHEL 5.x. At least puppetlabs/stdlib 4.2.0 is
required. New resource yum::install for installing of local/remote
packages.

#### Features

- Tunable exec. timeout for YUM group management commands.
- New defined resource yum::install for local or remote (URL) packages install.

#### Bugfixes

- Properly detect YUM plugins prefixes on RHEL 5.x
- Increased requirements on puppetlabs/stdlib to 4.2.0
- Yum group management respects hidden groups

## 2015-05-29 - Release 0.9.6

Fixed check for installed YUM group on RHEL 7.

#### Bugfixes

- Fixed check for installed YUM group on RHEL/CentOS 7

## 2015-04-07 - Release 0.9.5

New class yum, defined resource yum::config. Trigger old kernels purge.

#### Features

- New defined resource yum::config to allow changes in /etc/yum.conf.
- New class yum to set common global parameters
- If installonly\_limit is changed, old kernels above the limit are purged.

## 2014-12-08 - Release 0.9.4

Fix file/directory permissions.

#### Bugfixes

- Fix PF module archive file/directory permissions.

## 2014-11-06 - Release 0.9.3

Enable yum.conf plugins if disabled.

#### Bugfixes

- Enable yum.conf plugins (if disabled) when we
  install plugin via yum::plugin.

## 2014-09-02 - Release 0.9.2

Fix metadata.json

#### Bugfixes

- Fix metadata.json module dependencies

## 2014-08-20 - Release 0.9.1

### Summary

Fix GPG key import check when key is specified in $content.

#### Bugfixes

- Fix GPG key import check when key is specified in $content.

## 2014-08-07 - Release 0.9.0

### Summary

Initial release.
