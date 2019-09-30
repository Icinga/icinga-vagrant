##2019-??-?? - Release ?.?.?
###Summary
- Add support for Puppet v4.x, v5.x, & v6.x.

##2016-10-24 - Release 4.0.0
###Summary
- Official support for influxdb 1.0.0

##2016-06-06 - Release 3.1.1
###Summary
- metadata updates (quality score update)

##2016-06-05 - Release 3.1.0
###Summary
- Fix compatibility requirements

##2016-06-05 - Release 3.1.0
###Summary
- Added support for external repositories
- Fix in the udp template
- autodetect service provider

##2016-03-13 - Release 3.0.1
###Summary
processing sorted hash sets for predictable template results

##2016-03-05 - Release 3.0.0
###Summary
Install influxdb from the official influxdata repository

####Backwards-incompatible changes

- Influxdata repository has only the latest 0.10.X version available. To manage version prior to 0.9.6 use previous
modules, which install influxdb from the AWS S3 repository. I raised an issue https://github.com/influxdata/influxdb/issues/5913
asking influxdb maintainer to stop removing previous versions from the repos
- Now by default the module will install the latest version. To modify that overwrite version parameters

Special tnx to andyroyle for the 0.10.X fixes

##2015-12-11 - Release 2.2.0
###Summary
- add meta_dir as a parameter
- adding INFLUXD_OPTS to /etc/default/influxdb. This is needed in setting up raft clusters.

##2015-12-11 - Release 2.1.1
###Summary
Explicitly import variables to make avoid compile error in puppet 4

##2015-11-26 - Release 2.1.0
###Summary
This release include support to manage install.
 - add new parameter manage_install

##2015-11-05 - Release 2.0.0
###Summary
This release includes support for multiple UDP channels.

####Backwards-incompatible changes

Adding support for multiple UDP per database means we had to replace *udp_enabled*, *udp_bind_address*,
*udp_database*, *udp_batch_size* and *udp_batch_timeout* with a more generic array of hashes (*udp_options*).
For all the users not using UDP listener (disabled by default) won't have any problem upgrading the module to
v2.0.0.

####Features
- Adds support for multiple UDP (tnx to bovy89)

####Bugfixes
- Fix documentation for proper use of collectd_database (tnx to Philipp Borgers)

##2015-10-23 - Release 1.1.1
###Summary
- template fix for the UDP support

##2015-09-13 - Release 1.1.0
###Summary
- Add support for 0.9.3 influxdb new config parameters
- Fix graphite template bug
- Default install version 0.9.3 - (we can't use latest version due to how influxdb is packaged)

Special tnx to Pedro González Serrano - NITEMAN for the graphite and 0.9.3 config template fix

##2015-08-25 - Release 1.0.1
###Summary
Improved the documentation and the module description

##2015-08-25 - Release 1.0.0
###Summary
Major module rewrite to support influxdb 0.9.X. For more info please check the README.md

##2015-01-25 - Release 0.1.2
###Summary

- bugfix: specify the correct config file, because looks like the global settings
are defined in /opt/influxdb/shared/config.toml
- bugfix: added missing RedHat/CentOS params to make it work properly (TODO: add system spec tests)

##2015-01-25 - Release 0.1.1
###Summary

bugfix: correct package_source for RedHat osfamily

##2015-01-25 - Release 0.1.0
###Summary

First public release.
