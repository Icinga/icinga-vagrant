#### 2016-02-05 - 1.0.6
* Revert previous incorrect change, more work is needed to cover all cases.

#### 2016-02-05 - 1.0.5
* Fix enforcing for values with spaces (#37, @mattpascoe).

#### 2016-02-02 - 1.0.4
* Convert numerical value to string to work around shellquote() failure (#35).

#### 2016-02-02 - 1.0.3
* Update project_page and source in metadata.json file (#25).
* Add default value to hiera_hash call (#30, @tedivm).
* Prevent spaces in file names (#31, @jokajak).
* Add support for Debian 8 (same symlink99 as RedHat 7).
* Enforce values on each run by default (#23, @jjneely).
* Remove incorrectly advertised FreeBSD support (#27, @b4ldr).

#### 2014-12-22 - 1.0.2
* Fix metadata.json file (#18).

#### 2014-12-16 - 1.0.1
* Replace Modulefile with metadata.json.

#### 2014-09-05 - 1.0.0
* Keep the 99-sysctl.conf symlink on RHEL7.
* Add support for hiera defined sysctl values (#14, @emahags).
* Add support for source, content and configurable file suffix.
* Allow comment to be any of string (even multi-line) or array (#12).
* Start adding support for setting sysctl_dir to false.

#### 2014-07-19 - 0.3.2
* Use a different separator for sed to allow values with '/' (#11, @rubenk).

#### 2014-03-17 - 0.3.1
* Fix ensure => 'absent' (#9).

#### 2014-01-20 - 0.3.0
* Add optional comment inside the sysctl.d file.
* Use sysctl -p with the created/modified file instead of sysctl -w (#3).
* Fix purge and set its default to false (#7, tehmaspc).

#### 2013-10-02 - 0.2.0
* Add optional prefix to the sysctl.d file name, to force ordering.

#### 2013-06-25 - 0.1.1
* Make purge optional, still enabled by default.
* Add rspec tests (Justin Lambert).
* Minor fix for values with spaces (needs more changes to be robust).

#### 2013-03-06 - 0.1.0
* Update README to markdown.
* Change to recommended 2 space indent.

#### 2012-12-18 - 0.0.3
* Add feature to update existing values in /etc/sysctl.conf.
* Apply setting on each run if needed (hakamadare).
* Make sure $ensure => absent still works with the above change.

#### 2012-09-19 - 0.0.2
* Fix deprecation warnings.
* Fix README markup.

#### 2012-07-19 - 0.0.1
* Initial module release.

