# puppet-php

## Overview

Install PHP packages and configure PHP INI files, for using PHP from the CLI,
the Apache httpd module or FastCGI.

The module is very Red Hat Enterprise Linux focused, as the defaults try to
change everything in ways which are typical for RHEL, but it also works on
Debian based distributions (such as Ubuntu), and support for others should
be easy to add.

* `php::cli` : Simple class to install PHP's Command Line Interface
* `php::fpm::daemon` : Simple class to install PHP's FastCGI Process Manager
* `php::fpm::conf` : PHP FPM pool configuration definition
* `php::ini` : Definition to create php.ini files
* `php::mod_php5` : Simple class to install PHP's Apache httpd module
* `php::module` : Definition to manage separately packaged PHP modules
* `php::module::ini` : Definition to manage the ini files of separate modules

## Examples

Create `php.ini` files for different uses, but based on the same template :

```puppet
php::ini { '/etc/php.ini':
  display_errors => 'On',
  memory_limit   => '256M',
}
php::ini { '/etc/httpd/conf/php.ini':
  mail_add_x_header => 'Off',
  # For the parent directory
  require           => Package['httpd'],
}
```

Install the latest version of the PHP command line interface in your OS's
package manager (e.g. Yum for RHEL):

```puppet
include '::php::cli'
```

Install version 5.3.3 of the PHP command line interface :

```puppet
class { 'php::cli': ensure => '5.3.3' }
```

Install the PHP Apache httpd module, using its own php configuration file
(you will need mod_env in apache for this to work) :

```puppet
class { 'php::mod_php5': inifile => '/etc/httpd/conf/php.ini' }
```

Install PHP modules which don't have any configuration :

```puppet
php::module { [ 'ldap', 'mcrypt' ]: }
```

Configure PHP modules, which must be installed with php::module first :

```puppet
php::module { [ 'pecl-apc', 'xml' ]: }
php::module::ini { 'pecl-apc':
  settings => {
    'apc.enabled'      => '1',
    'apc.shm_segments' => '1',
    'apc.shm_size'     => '64',
  }
}
php::module::ini { 'xmlreader': pkgname => 'xml' }
php::module::ini { 'xmlwriter': ensure => 'absent' }
```

Install PHP FastCGI Process Manager with a single pool to be used with nginx.
Note that we reuse the 'www' name to overwrite the example configuration :

```puppet
include '::php::fpm::daemon'
php::fpm::conf { 'www':
  listen  => '127.0.0.1:9001',
  user    => 'nginx',
  # For the user to exist
  require => Package['nginx'],
}
```

Then from the nginx configuration :

```
# PHP FastCGI backend
upstream wwwbackend {
  server 127.0.0.1:9001;
}
# Proxy PHP requests to the FastCGI backend
location ~ \.php$ {
  # Don't bother PHP if the file doesn't exist, return the built in
  # 404 page (this also avoids "No input file specified" error pages)
  if (!-f $request_filename) { return 404; }
  include /etc/nginx/fastcgi.conf;
  fastcgi_pass wwwbackend;
}
# Try to send all non-existing files to the main /index.php
# (typically if you have a PHP framework requiring this)
location @indexphp {
  if (-f $document_root/index.php) { rewrite .* /index.php last; }
}
try_files $uri @indexphp;
```

