class filebeat::repo {
  $debian_repo_url = $filebeat::real_version ? {
    '1' => 'http://packages.elastic.co/beats/apt',
    '5' => 'https://artifacts.elastic.co/packages/5.x/apt',
  }

  $yum_repo_url = $filebeat::real_version ? {
    '1' => 'https://packages.elastic.co/beats/yum/el/$basearch',
    '5' => 'https://artifacts.elastic.co/packages/5.x/yum',
  }

  case $::osfamily {
    'Debian': {
      include ::apt

      Class['apt::update'] -> Package['filebeat']

      if !defined(Apt::Source['beats']){
        apt::source { 'beats':
          location => $debian_repo_url,
          release  => 'stable',
          repos    => 'main',
          key      => {
            id     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
            source => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          },
        }
      }
    }
    'RedHat', 'Linux': {
      if !defined(Yumrepo['beats']){
        yumrepo { 'beats':
          descr    => 'elastic beats repo',
          baseurl  => $yum_repo_url,
          gpgcheck => 1,
          gpgkey   => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          enabled  => 1,
        }
      }
    }
    'Suse': {
      exec { 'topbeat_suse_import_gpg':
        command => 'rpmkeys --import https://artifacts.elastic.co/GPG-KEY-elasticsearch',
        unless  => 'test $(rpm -qa gpg-pubkey | grep -i "D88E42B4" | wc -l) -eq 1 ',
        notify  => [ Zypprepo['beats'] ],
      }
      if !defined(Zypprepo['beats']){
        zypprepo { 'beats':
          baseurl     => $yum_repo_url,
          enabled     => 1,
          autorefresh => 1,
          name        => 'beats',
          gpgcheck    => 1,
          gpgkey      => 'http://packages.elastic.co/GPG-KEY-elasticsearch',
          type        => 'yum',
        }
      }
    }
    default: {
      fail($filebeat::kernel_fail_message)
    }
  }
}
