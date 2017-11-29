include icingaweb2

class { 'icingaweb2::module::generictts':
  git_revision  => 'v2.0.0',
  ticketsystems => {
    'my-ticket-system' => {
      pattern => '/#([0-9]{4,6})/',
      url     => 'https://my.ticket.system/tickets/id=$1',
    },
    'TTS'              => {
      pattern => '/this-wont-match/',
      url     => 'https://icinga.com/tickets/id=$1'
    }
  }
}