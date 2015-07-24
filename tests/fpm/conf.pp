include php::fpm::daemon
php::fpm::conf { 'www': ensure => absent }
php::fpm::conf { 'customer1':
    listen => '127.0.0.1:9001',
    user   => 'customer1',
}
