<?php

use Icinga\Application\EmbeddedWeb;
use Icinga\Web\StyleSheet;

require_once '/vagrant/icingaweb2/library/Icinga/Application/EmbeddedWeb.php';
EmbeddedWeb::start('/etc/icingaweb');
Stylesheet::send();
