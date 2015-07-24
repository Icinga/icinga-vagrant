# Parameters class.
#
class php::params {
  case $::osfamily {
    'Debian': {
      $php_package_name = 'php5'
      $php_apc_package_name = 'php-apc'
      $common_package_name = 'php5-common'
      $cli_package_name = 'php5-cli'
      $cli_inifile = '/etc/php5/cli/php.ini'
      $php_conf_dir = '/etc/php5/conf.d'
      $fpm_package_name = 'php5-fpm'
      $fpm_service_name = 'php5-fpm'
      $fpm_service_restart = 'restart'
      $fpm_pool_dir = '/etc/php5/fpm/pool.d'
      $fpm_conf_dir = '/etc/php5/fpm'
      $fpm_error_log = '/var/log/php5-fpm.log'
      $fpm_pid = '/var/run/php5-fpm.pid'
      $httpd_package_name = 'apache2'
      $httpd_service_name = 'apache2'
      $httpd_conf_dir = '/etc/apache2/conf.d'
    }
    default: {
      $php_package_name = 'php'
      $php_apc_package_name = 'php-pecl-apc'
      $common_package_name = 'php-common'
      $cli_package_name = 'php-cli'
      $cli_inifile = '/etc/php.ini'
      $php_conf_dir = '/etc/php.d'
      $fpm_package_name = 'php-fpm'
      $fpm_service_name = 'php-fpm'
      $fpm_service_restart = 'reload'
      $fpm_pool_dir = '/etc/php-fpm.d'
      $fpm_conf_dir = '/etc'
      $fpm_error_log = '/var/log/php-fpm/error.log'
      $fpm_pid = '/var/run/php-fpm/php-fpm.pid'
      $httpd_package_name = 'httpd'
      $httpd_service_name = 'httpd'
      $httpd_conf_dir = '/etc/httpd/conf.d'
    }
  }
}
