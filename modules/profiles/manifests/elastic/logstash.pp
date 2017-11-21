# == Class: profiles::elastic::logstash
#
class profiles::elastic::logstash {
  class { 'logstash':
    manage_repo => true
  }

  # Logstash needs java in order to succesfully install, but this is managed by
  # the profile::base::java profile. We put the hard dependency here to make
  # 100% sure Java will be installed prior to attempting to use logstash
  Package['java'] -> Exec['logstash-system-install']

  logstash::configfile { '00_input_beats':
    content => epp('profiles/elastic/input_beats.epp', {}),
  }

  logstash::configfile { '10_filter':
    content => epp('profiles/elastic/filter.epp', {}),
  }

  logstash::configfile { '20_output_header':
    content => epp('profiles/elastic/output_header.epp', {}),
  }

  logstash::configfile { '21_output_elasticsearch':
    content => epp('profiles/elastic/output_elasticsearch.epp', {}),
  }

  logstash::configfile { '99_output_footer':
    content => epp('profiles/elastic/output_footer.epp', {}),
  }
}
