php::ini { '/etc/php-httpd.ini': }
service { 'httpd': }
package { 'httpd': ensure => installed }
class { 'php::mod_php5': inifile => '/etc/php-httpd.ini' }
