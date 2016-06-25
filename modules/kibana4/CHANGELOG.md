#1.0.17 (2016-09-05)

**Deprecation**
 - Deprecated archive installation method

**Enhancements**
 - Enabled systemd on EL7.

#1.0.13 (2016-21-03)

**Enhancements**
 - Bug fix for Ubuntu

#1.0.12 (2016-08-03)

**Enhancements**
 - More Beaker tests
 - Readme improvements 
 - Plugin ordering fix

#1.0.11 (2016-08-03)

**Enhancements**
 - plugins install dir was incorrect
 - manage_user default is now false 

#1.0.9 (2016-07-03)

**Enhancements**
 - init bug fix
 - simple plugin support - does not allow plugin updating. 

**Documentation**
 - plugins simple support

#1.0.7 (2016-06-03)

**Enhancements**
 - Beaker tests
 - Parameters refactoring
 - use updated init script from elastic.co packages
 - archive_dl_timeout feature - thanks to alexharv074
 - log directory improvements - thanks to alexharv074
 - updated scope.lookupvar syntax - thanks to alexharv074
 - template conditions fixes - thanks to mklette
 - better handling of pid file - - thanks to alexharv074
 - disabled verbose mode for camptocamp/archive - thanks to alexharv074 

**Documentation**
 - Several updates

#1.0.6 (2015-23-12)

**Enhancements**
 - config file key sorting.

#1.0.5 (2015-18-12)

**Enhancements**
 - Replaced download url
 - Update default version to 4.3.1

**Documentation**
 - Fixes some typos and linting

#1.0.4 (2015-09-12)

**Enhancements**
 - Replaced config file templating with custom file creation from key/values.

**Documentation**
 - Update with yaml config file examples 

#1.0.3 (2015-03-12)

**Enhancements**
 - Make kibana 4.2 the default deployed version.
 - manage babel_cache_path.
 - fix erb template name.
 - fix ownership of extracted dir.
 - fix nil value detection in yaml template.
 - support for alternate puppet archive module.

**Documentation**
 - Minor documentation updates

#1.0.2 (2015-01-10)

**Enhancements**
 - support for official elactic.co repositories. Thanks to Andrew Stangl.
 - OS package installation improvements.
 - Elasticsearch authentication support.

**Documentation**
 - Installation from offical repos example.

#1.0.1 (2015-08-06)

**Documentation**
 - Typo in Changelog
 

#1.0.0 (2015-08-06)

**Enhancements**
 - pid file improvements
 - proxy server support on archive downloading
 - Default version bump from 4.0.0 to 4.1.1

**Documentation**
 - Document package_proxy_server parameter

#0.0.9 (2015-03-19)

**Documentation**
 - Adding tags to ease up search in puppet forge.

#0.0.7 (2015-03-01)

**Enhancements**
 - Run kibana service as kibana4 user by default. Thanks to Andreas Ntaflos.
 - User creation defaults to true.

**Documentation**
 - Documentation changes to reflect kibana4 user creation.

#0.0.6 (2015-03-01)

**Enhancements**
 - All around style refactoring. Thanks to Andreas Ntaflos.

**Documentation**
 - Documentation changes to reflect style refactoring.

#0.0.5 (2015-02-28)

**Documentation**
 - Some readme changes to clarify ES requirements. Thanks to Andreas Ntaflos.

# 0.0.4 (2015-02-25)

**Documentation**
 - Some readme changes and typos were fixed.

**Enhancements**
 - Default service behaviour is now "ensure => true" and "enable => true"

# 0.0.3 (2015-02-24)

First release on the Puppet Forge
