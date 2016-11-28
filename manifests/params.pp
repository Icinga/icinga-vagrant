# == Class: logstash::params
#
# This class exists to
# 1. Declutter the default value assignment for class parameters.
# 2. Manage internally used module variables in a central place.
#
# Therefore, many operating system dependent differences (names, paths, ...)
# are addressed in here.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class is not intended to be used directly.
#
#
# === Links
#
# * {Puppet Docs: Using Parameterized Classes}[http://j.mp/nVpyWY]
#
#
# === Authors
#
# https://github.com/elastic/puppet-logstash/graphs/contributors
#
class logstash::params {
  # Default values for the parameters of the main module class, init.pp.
  $package_name = 'logstash'
  $ensure = 'present'
  $status = 'enabled'
  $logstash_user  = 'logstash'
  $logstash_group = 'logstash'

  $configdir = '/etc/logstash'
  $patterndir = "${configdir}/patterns"
  $plugindir = "${configdir}/plugins"
  $purge_configdir = false

  $repo_version = '5.x'
  $autoupgrade = false
  $download_tool = 'wget --no-check-certificate -O'
  $download_timeout = 600  # Exec[] timeout default is 300.

  # restart on configuration change?
  $restart_on_change = true
}
