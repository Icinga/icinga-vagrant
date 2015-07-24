#### 2015-04-01 - 1.1.1
* Fix php-fpm notification for php::module::ini when prefix was set.

#### 2015-03-09 - 1.1.0
* Rebase php-fpm.conf and pool.conf with files from 5.5.22.
* Add syslog and rlimit related parameters to fpm.
* Fix security_limit_extensions being disabled even when set.
* Add session php_values to fpm pool template.
* Remove clear_env, no longer included in the original fpm pool file.
* Allow overriding fpm error_log (useful for syslog).
* Allow override of php_package_name in mod_php5 class (#35, @jeffsheltren).
* Notify fpm service on conf and module changes (#41, @khaefeli).
* Add cgi_fix_pathinfo parameter (#43, @mark0n).
* Rename fpm_package parameter to just package in fpm::conf for consistency.
* Allow fpm_service name override in fpm::conf (#49).
* Fix php.ini CLI default location for Debian (#50, @joshuaspence).
* Add always_populate_raw_post_data parameter (#58, @nomoresecrets).
* Default to full fpm restart on Debian OS family (#55).

#### 2014-09-09 - 1.0.0
* Allow override of package names (#29, #30, #31, @jeffsheltren).
* Support prefix in module ini files, for recent Fedora/EL packages.
* Support $zend = true for module::ini, for PHP 5.6.
* Fix user_ini.cache_ttl which was always disabled (#39, @3flex).

#### 2014-04-14 - 0.3.12
* Fix process_priority fpm parameter (#26, @Nyholm).

#### 2014-04-01 - 0.3.11
* Add process_priority fpm parameter (#25, @Nyholm).
* Add process_max fpm parameter.
* Update the fpm templates with upstream changes.
* Add priority and process_idle_timeout parameters for fpm pools.
* Add clear_env and security_limit_extensions parameters for fpm pools.
* Allow specifying full package name for module::ini (#21, @jeffsheltren).
* Allow overriding cli_package_name (#20, @jeffsheltren).

#### 2014-03-14 - 0.3.10
* Ensure /var/log/php-fpm directory exists (#24, @stevenyeung).
* Add support for listen_allowed_clients == 'any' (#22, @damonconway).

#### 2014-01-20 - 0.3.9
* Update the el6 ini to add max_input_vars and max_file_uploads.
* Allow specifying php version as the 'ensure' parameter (#17, MasonM).
* Cosmetic updates and fixes in the manifests.

#### 2013-12-20 - 0.3.8
* Fix the package name for APC on RHEL (Pan Luo).
* Fix the regsubst flag for 'pecl-' prefix removal (Pan Luo).

#### 2013-10-01 - 0.3.7
* Manage the incorrectly named php-apc package under Debian (Jeroen Moors).

#### 2013-09-30 - 0.3.6
* Enable using a custom template for php.ini (Nick Schuch).

#### 2013-09-05 - 0.3.5
* Add upload_tmp_dir php.ini option support (Andy Shinn).
* Add soap related php.ini options support (Flavien Binet).

#### 2013-08-30 - 0.3.3
* Use @varname syntax in fpm templates too.
* Fix php::module::ini when ensure is absent.
* Fix directory create for FPM (Erik Webb).
* Fix conf.d directory location for Debian (Erik Webb).

#### 2013-06-13 - 0.3.2
* Add phar.readonly php.ini option support.
* Use undef for parameter defaults when not being used in php.ini.
* Remove the commented out defaults in php.ini for parameters being set.

#### 2013-05-30 - 0.3.1
* Update mod_php support to also work with Debian OS family.

#### 2013-05-30 - 0.3.0
* Add support for Debian OS family (Scott Lewis).

#### 2013-04-19 - 0.2.5
* Stop ugly group/mode thing for php-fpm log, use $log_dir_mode instead.
* Use @varname syntax in templates to silence puppet 3.2 warnings.

#### 2013-03-06 - 0.2.4
* Minor clean ups.
* Make /var/log/php-fpm group read-only when group is different from owner.

#### 2012-12-18 - 0.2.3
* Add support for zend extensions.

#### 2012-09-19 - 0.2.2
* Fix session_auto_start in the php.ini template.
* Fix ASP-style tags being processed as ERB in the php.ini template.
* Allow passing a file path for each fpm pool error_log.
* Add php_value/php_flag and php_admin_value/php_admin_flag in fpm pools.

#### 2012-04-26 - 0.2.1
* Force sorting of module ini option hash to fix template with puppet 2.7+.

#### 2012-04-26 - 0.2.0
* Clean up the module to match current puppetlabs guidelines.
* Fix all broken smoke tests.
* Major documentation update, adding more useful examples.

