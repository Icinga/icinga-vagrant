<?php
require_once '/vagrant/icingaweb2/library/Icinga/Application/Web.php';
use Icinga\Application\Web;
Web::start('/etc/icingaweb')->dispatch();
