<?php

use Icinga\Application\EmbeddedWeb;
use Icinga\Web\JavaScript;

require_once '/vagrant/icingaweb2/library/Icinga/Application/EmbeddedWeb.php';
$app = EmbeddedWeb::start('/etc/icingaweb');
JavaScript::sendMinified();
