# Define: php::ini
#
# Definition to create a php.ini file. Typically used once per node where php
# will be used, to configure the content of the main /etc/php.ini file.
#
# Sample Usage:
#  Php::Ini {
#      expose_php => 'Off',
#  }
#  php::ini { '/etc/php.ini':
#      display_errors => 'On',
#  }
#
define php::ini (
  $ensure                     = undef,
  $template                   = 'php/php.ini-el6.erb',
  # php.ini options in the order they appear in the original file
  $user_ini_filename          = '.user.ini',
  $user_ini_cache_ttl         = '300',
  $engine                     = 'On',
  $short_open_tag             = 'Off',
  $asp_tags                   = 'Off',
  $precision                  = '14',
  $output_buffering           = '4096',
  $zlib_output_compression    = 'Off',
  $implicit_flush             = 'Off',
  $serialize_precision        = '100',
  $allow_call_time_pass_reference = 'Off',
  $safe_mode                  = 'Off',
  $safe_mode_gid              = 'Off',
  $safe_mode_include_dir      = '',
  $safe_mode_exec_dir         = '',
  $safe_mode_allowed_env_vars = 'PHP_',
  $safe_mode_protected_env_vars = 'LD_LIBRARY_PATH',
  $disable_functions          = '',
  $disable_classes            = '',
  $ignore_user_abort          = undef,
  $expose_php                 = 'On',
  $max_execution_time         = '30',
  $max_input_time             = '60',
  $max_input_vars             = '1000',
  $memory_limit               = '128M',
  $error_reporting            = 'E_ALL & ~E_DEPRECATED',
  $display_errors             = 'Off',
  $display_startup_errors     = 'Off',
  $log_errors                 = 'On',
  $log_errors_max_len         = '1024',
  $ignore_repeated_errors     = 'Off',
  $ignore_repeated_source     = 'Off',
  $report_memleaks            = 'On',
  $track_errors               = 'Off',
  $html_errors                = 'Off',
  $error_log                  = undef,
  $variables_order            = 'GPCS',
  $request_order              = 'GP',
  $register_globals           = 'Off',
  $register_long_arrays       = 'Off',
  $register_argc_argv         = 'Off',
  $auto_globals_jit           = 'On',
  $post_max_size              = '8M',
  $magic_quotes_gpc           = 'Off',
  $magic_quotes_runtime       = 'Off',
  $magic_quotes_sybase        = 'Off',
  $auto_prepend_file          = '',
  $auto_append_file           = '',
  $default_mimetype           = 'text/html',
  $default_charset            = undef,
  $always_populate_raw_post_data = undef,
  $include_path               = undef,
  $doc_root                   = '',
  $user_dir                   = '',
  $enable_dl                  = 'Off',
  $cgi_fix_pathinfo           = undef,
  $file_uploads               = 'On',
  $upload_tmp_dir             = undef,
  $upload_max_filesize        = '2M',
  $max_file_uploads           = '20',
  $allow_url_fopen            = 'On',
  $allow_url_include          = 'Off',
  $default_socket_timeout     = '60',
  $date_timezone              = undef,
  $phar_readonly              = undef,
  $sendmail_path              = '/usr/sbin/sendmail -t -i',
  $mail_add_x_header          = 'On',
  $sql_safe_mode              = 'Off',
  $browscap                   = undef,
  $session_save_handler       = 'files',
  $session_save_path          = '/var/lib/php/session',
  $session_use_cookies        = '1',
  $session_use_only_cookies   = '1',
  $session_name               = 'PHPSESSID',
  $session_auto_start         = '0',
  $session_cookie_lifetime    = '0',
  $session_cookie_path        = '/',
  $session_cookie_domain      = '',
  $session_cookie_httponly    = '',
  $session_serialize_handler  = 'php',
  $session_gc_probability     = '1',
  $session_gc_divisor         = '1000',
  $session_gc_maxlifetime     = '1440',
  $session_bug_compat_42      = 'Off',
  $session_bug_compat_warn    = 'Off',
  $session_referer_check      = '',
  $session_hash_function      = '0',
  $session_hash_bits_per_character = '5',
  $url_rewriter_tags          = 'a=href,area=href,frame=src,input=src,form=fakeentry',
  $soap_wsdl_cache_enabled    = '1',
  $soap_wsdl_cache_dir        = '/tmp',
  $soap_wsdl_cache_ttl        = '86400',
) {

  include '::php::common'

  file { $title:
    ensure  => $ensure,
    content => template($template),
  }

  # Reload FPM if present
  if defined(Class['::php::fpm::daemon']) {
    File[$title] ~> Service[$php::params::fpm_service_name]
  }

}

