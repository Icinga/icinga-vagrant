require 'spec_helper'

describe 'grafana' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "grafana class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('grafana::params') }
        it { should contain_class('grafana::install').that_comes_before('grafana::config') }
        it { should contain_class('grafana::config') }
        it { should contain_class('grafana::service').that_subscribes_to('grafana::config') }

        it { should contain_service('grafana-server').with_ensure('running').with_enable(true) }
        it { should contain_package('grafana').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'grafana class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('grafana') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end

  context 'package install method' do
    context 'debian' do
      let(:facts) {{
        :osfamily => 'Debian'
      }}

      download_location = '/tmp/grafana.deb'

      describe 'use wget to fetch the package to a temporary location' do
        it { should contain_wget__fetch('grafana').with_destination(download_location) }
        it { should contain_wget__fetch('grafana').that_comes_before('Package[grafana]') }
      end

      describe 'install dependencies first' do
        it { should contain_package('libfontconfig1').with_ensure('present').that_comes_before('Package[grafana]') }
      end

      describe 'install the package' do
        it { should contain_package('grafana').with_provider('dpkg') }
        it { should contain_package('grafana').with_source(download_location) }
      end
    end

    context 'redhat' do
      let(:facts) {{
        :osfamily => 'RedHat'
      }}

      describe 'install dependencies first' do
        it { should contain_package('fontconfig').with_ensure('present').that_comes_before('Package[grafana]') }
      end

      describe 'install the package' do
        it { should contain_package('grafana').with_provider('rpm') }
      end
    end
  end

  context 'repo install method' do
    let(:params) {{
      :install_method => 'repo',
      :manage_package_repo => true
    }}

    context 'debian' do
      let(:facts) {{
        :osfamily => 'Debian',
        :lsbdistid => 'Ubuntu'
      }}

      describe 'install apt repo dependencies first' do
        it { should contain_class('apt') }
        it { should contain_apt__source('grafana').with(:release => 'wheezy', :repos => 'main', :location => 'https://packagecloud.io/grafana/stable/debian') }
        it { should contain_apt__source('grafana').that_comes_before('Package[grafana]') }
      end

      describe 'install dependencies first' do
        it { should contain_package('libfontconfig1').with_ensure('present').that_comes_before('Package[grafana]') }
      end

      describe 'install the package' do
        it { should contain_package('grafana').with_ensure('2.5.0') }
      end
    end

    context 'redhat' do
      let(:facts) {{
        :osfamily => 'RedHat'
      }}

      describe 'yum repo dependencies first' do
        it { should contain_yumrepo('grafana').with(:baseurl => 'https://packagecloud.io/grafana/stable/el/6/$basearch', :gpgkey => 'https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana', :enabled => 1) }
        it { should contain_yumrepo('grafana').that_comes_before('Package[grafana]') }
      end

      describe 'install dependencies first' do
        it { should contain_package('fontconfig').with_ensure('present').that_comes_before('Package[grafana]') }
      end

      describe 'install the package' do
        it { should contain_package('grafana').with_ensure('2.5.0-1') }
      end
    end
  end

  context 'repo install method without managing the package repo' do
    let(:params) {{
      :install_method => 'repo',
      :manage_package_repo => false,
      :version => 'present'
    }}

    context 'debian' do
      let(:facts) {{
        :osfamily => 'Debian',
        :lsbdistid => 'Ubuntu'
      }}

      it { should compile.with_all_deps }

      describe 'install dependencies first' do
        it { should contain_package('libfontconfig1').with_ensure('present').that_comes_before('Package[grafana]') }
      end

      describe 'install the package' do
        it { should contain_package('grafana').with_ensure('present') }
      end
    end
  end

  context 'archive install method' do
    let(:params) {{
      :install_method => 'archive'
    }}

    install_dir    = '/usr/share/grafana'
    service_config = '/usr/share/grafana/conf/custom.ini'

    describe 'extract archive to install_dir' do
      it { should contain_archive('grafana').with_ensure('present') }
      it { should contain_archive('grafana').with_target(install_dir) }
      it { should contain_archive('grafana').with_strip_components(1) }
      it { should contain_archive('grafana').that_comes_before('User[grafana]') }
    end

    describe 'create grafana user' do
      it { should contain_user('grafana').with_ensure('present').with_home(install_dir) }
      it { should contain_user('grafana').that_comes_before('File[/usr/share/grafana]') }
    end

    describe 'manage install_dir' do
      it { should contain_file(install_dir).with_ensure('directory') }
      it { should contain_file(install_dir).with_group('grafana').with_owner('grafana') }
      it { should contain_file(install_dir).with_recurse(true).with_recurselimit(3) }
    end

    describe 'configure grafana' do
      it { should contain_file(service_config).with_ensure('present') }
    end

    describe 'run grafana as service' do
      it { should contain_service('grafana-server').with_ensure('running').with_provider('base') }
      it { should contain_service('grafana-server').with_hasrestart(false).with_hasstatus(false) }
    end

    context 'when user already defined' do
      let(:pre_condition) {
        'user{"grafana":
          ensure => present,
        }'
      }
      describe 'do NOT create grafana user' do
        it { should_not contain_user('grafana').with_ensure('present').with_home(install_dir) }
      end
    end

    context 'when service already defined' do
      let(:pre_condition) {
        'service{"grafana-server":
          ensure     => running,
          hasrestart => true,
          hasstatus  => true,
        }'
      }
      # let(:params) {{ :service_name => 'grafana-server'}}
      describe 'do NOT run service' do
        it { should_not contain_service('grafana-server').with_hasrestart(false).with_hasstatus(false) }
      end
    end
  end

  context 'invalid parameters' do
    context 'cfg' do
      let(:facts) {{
        :osfamily => 'Debian',
      }}

      describe 'should raise an error when cfg parameter is not a hash' do
        let(:params) {{
          :cfg => [],
        }}

        it { expect { should contain_package('grafana') }.to raise_error(Puppet::Error, /cfg parameter must be a hash/) }
      end

      describe 'should not raise an error when cfg parameter is a hash' do
        let(:params) {{
          :cfg => {},
        }}

        it { should contain_package('grafana') }
      end
    end
  end

  context 'configuration file' do
    let(:facts) {{
      :osfamily => 'Debian',
    }}

    describe 'should not contain any configuration when cfg param is empty' do
      it { should contain_file('/etc/grafana/grafana.ini').with_content("# This file is managed by Puppet, any changes will be overwritten\n\n") }
    end

    describe 'should correctly transform cfg param entries to Grafana configuration' do
      let(:params) {{
        :cfg => {
          'app_mode' => 'production',
          'section' => {
            'string' => 'production',
            'number' => 8080,
            'boolean' => false,
            'empty' => '',
          },
        },
        :ldap_cfg => {
          'servers' => [
            { 'host' => 'server1',
              'use_ssl' => true,
              'search_filter' => '(sAMAccountName=%s)',
              'search_base_dns' => [ 'dc=domain1,dc=com' ],
            },
            { 'host' => 'server2',
              'use_ssl' => true,
              'search_filter' => '(sAMAccountName=%s)',
              'search_base_dns' => [ 'dc=domain2,dc=com' ],
            },
          ],
          'servers.attributes' => {
            'name' => 'givenName',
            'surname' => 'sn',
            'username' => 'sAMAccountName',
            'member_of' => 'memberOf',
            'email' => 'email',
          }
        },
      }}

      expected = "# This file is managed by Puppet, any changes will be overwritten\n\n"\
                 "app_mode = production\n\n"\
                 "[section]\n"\
                 "boolean = false\n"\
                 "empty = \n"\
                 "number = 8080\n"\
                 "string = production\n"

      it { should contain_file('/etc/grafana/grafana.ini').with_content(expected) }

      ldap_expected = "\n[[servers]]\n"\
                       "host = \"server1\"\n"\
                       "search_base_dns = [\"dc=domain1,dc=com\"]\n"\
                       "search_filter = \"(sAMAccountName=%s)\"\n"\
                       "use_ssl = true\n"\
                       "\n"\
                      "[[servers]]\n"\
                       "host = \"server2\"\n"\
                       "search_base_dns = [\"dc=domain2,dc=com\"]\n"\
                       "search_filter = \"(sAMAccountName=%s)\"\n"\
                       "use_ssl = true\n"\
                       "\n"\
                       "[servers.attributes]\n"\
                       "email = \"email\"\n"\
                       "member_of = \"memberOf\"\n"\
                       "name = \"givenName\"\n"\
                       "surname = \"sn\"\n"\
                       "username = \"sAMAccountName\"\n"\
                       "\n"

      it { should contain_file('/etc/grafana/ldap.toml').with_content(ldap_expected) }
    end
  end
end
