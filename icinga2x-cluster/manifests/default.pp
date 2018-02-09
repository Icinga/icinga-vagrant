####################################
# Global configuration
####################################

# Icinga
$directorVersion = 'v1.4.1'

$nodeName = "${hostname}" # TODO: Hiera.
$hostOnlyFQDN = "${hostname}.icinga2x-cluster.vagrant.demo.icinga.com"

$ticketSalt = '4e866494498b763639e56eb86c5bb6ca'

case $hostname {
  'icinga2-master1': {
    $hostOnlyIP = '192.168.33.101'

    $zoneName = 'master'

    $has_ca = true
    $ticket_salt = $ticketSalt # master constants.conf

    $zones = {
      'master' => {
        'endpoints' => [ 'icinga2-master1' ]
      },
      'satellite' => {
        'endpoints' => [ 'icinga2-satellite1' ],
        'parent'    => 'master'
      }
    }

    $endpoints = {
      'icinga2-master1' => {},
      'icinga2-satellite1' => {
        host => '192.168.33.102',
      }
    }
  }
  'icinga2-satellite1': {
    $hostOnlyIP = '192.168.33.102'

    $zoneName = 'checker'

    $has_ca = false
    $api_ticket_salt = $ticketSalt # satellite ticket generation
    $api_ca_host = '192.168.33.101'
    $api_pki = 'icinga2' # use the built-in CSR auto-signing method

    $zones = {
      'master' => {
        'endpoints' => [ 'icinga2-master1' ]
      },
      'satellite' => {
        'endpoints' => [ 'icinga2-satellite1' ],
        'parent'    => 'master'
      }
    }

    $endpoints = {
      'icinga2-master1' => {},
      'icinga2-satellite1' => {
        host => '192.168.33.102',
      }
    }
  }
}

####################################
# Setup
####################################

class { '::profiles::base::system': }
->
class { '::profiles::base::mysql': }
->
class { '::profiles::base::apache': }
->
class { '::profiles::icinga::icinga2':
  node_name       => $nodeName,
  zone_name       => $zoneName,
  ticket_salt     => $ticket_salt,
  zones           => $zones,
  endpoints       => $endpoints,
  has_ca          => $has_ca,
  api_pki         => $api_pki,
  api_ca_host     => $api_ca_host,
  api_ticket_salt => $api_ticket_salt,
  features        => { }
}
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN,
  node_name => $nodeName,
  modules => {
    "map" => {},
  }
}

