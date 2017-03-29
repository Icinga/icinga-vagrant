# This class manages package repositories for Logstash.
#
# It is usually used only by the top-level `logstash` class. It's unlikely
# that you will need to declare this class yourself.
#
# @example Include this class to ensure its resources are available.
#   include logstash::repo
#
# @author https://github.com/elastic/puppet-logstash/graphs/contributors
#
class logstash::repo {
  $version = $logstash::repo_version
  $repo_name = "elastic-${version}"
  $url_root = "https://artifacts.elastic.co/packages/${version}"
  $gpg_key_url = 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
  $gpg_key_id = '46095ACC8548582C1A2699A9D27D666CD88E42B4'

  Exec {
    path      => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd       => '/',
  }

  case $::osfamily {
    'Debian': {
      include apt

      apt::source { $repo_name:
        location => "${url_root}/apt",
        release  => 'stable',
        repos    => 'main',
        key      => {
          'id'     => $gpg_key_id,
          'source' => $gpg_key_url,
        },
        include  => {
          'src' => false,
        },
        notify   => [
          Class['apt::update'],
          Exec['apt_update'],
        ],
      }
    }
    'RedHat': {
      yumrepo { $repo_name:
        descr    => 'Logstash Centos Repo',
        baseurl  => "${url_root}/yum",
        gpgcheck => 1,
        gpgkey   => $gpg_key_url,
        enabled  => 1,
      }

      Yumrepo[$repo_name] -> Package<|tag == 'logstash'|>
    }
    'Suse' : {
      zypprepo { $repo_name:
        baseurl     => "${url_root}/yum",
        enabled     => 1,
        autorefresh => 1,
        name        => 'logstash',
        gpgcheck    => 1,
        gpgkey      => $gpg_key_url,
        type        => 'yum',
      }

      # Workaround until zypprepo allows the adding of the keys
      # https://github.com/deadpoint/puppet-zypprepo/issues/4
      exec { 'logstash_suse_import_gpg':
        command => "wget -q -O /tmp/RPM-GPG-KEY-elasticsearch ${gpg_key_url}; \
                    rpm --import /tmp/RPM-GPG-KEY-elasticsearch; \
                    rm /tmp/RPM-GPG-KEY-elasticsearch",
        unless  => "test $(rpm -qa gpg-pubkey | grep -i \"${gpg_key_id}\" | wc -l) -eq 1 ",
      }

      Exec['logstash_suse_import_gpg'] ~> Zypprepo['logstash'] -> Package<|tag == 'logstash'|>
    }
    default: {
      fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
    }
  }
}
