require 'spec_helper'

describe 'grafana' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let :service_name do
        case facts[:osfamily]
        when 'Archlinux'
          'grafana'
        else
          'grafana-server'
        end
      end

      let :config_path do
        case facts[:osfamily]
        when 'Archlinux'
          '/etc/grafana.ini'
        else
          '/etc/grafana/grafana.ini'
        end
      end

      context 'with default values' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('grafana') }
        it { is_expected.to contain_class('grafana::params') }
        it { is_expected.to contain_class('grafana::install').that_comes_before('Class[grafana::config]') }
        it { is_expected.to contain_class('grafana::config').that_notifies('Class[grafana::service]') }
        it { is_expected.to contain_class('grafana::service') }
      end

      context 'with parameter install_method is set to package' do
        let(:params) do
          {
            install_method: 'package',
            version: '4.5.1'
          }
        end

        case facts[:osfamily]
        when 'Debian'
          download_location = '/tmp/grafana.deb'

          describe 'use archive to fetch the package to a temporary location' do
            it do
              is_expected.to contain_archive('/tmp/grafana.deb').with_source(
                'https://s3-us-west-2.amazonaws.com/grafana-releases/release/builds/grafana_4.5.1_amd64.deb'
              )
            end
            it { is_expected.to contain_archive('/tmp/grafana.deb').that_comes_before('Package[grafana]') }
          end

          describe 'install dependencies first' do
            it { is_expected.to contain_package('libfontconfig1').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_provider('dpkg') }
            it { is_expected.to contain_package('grafana').with_source(download_location) }
          end
        when 'RedHat'
          describe 'install dependencies first' do
            it { is_expected.to contain_package('fontconfig').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_provider('rpm') }
          end
        end
      end

      context 'with some plugins passed in' do
        let(:params) do
          {
            plugins:
            {
              'grafana-wizzle' => { 'ensure' => 'present' },
              'grafana-woozle' => { 'ensure' => 'absent' },
              'grafana-plugin' => { 'ensure' => 'present', 'repo' => 'https://nexus.company.com/grafana/plugins' }
            }
          }
        end

        it { is_expected.to contain_grafana_plugin('grafana-wizzle').with(ensure: 'present') }
        it { is_expected.to contain_grafana_plugin('grafana-woozle').with(ensure: 'absent').that_notifies('Class[grafana::service]') }

        describe 'install plugin with pluginurl' do
          it { is_expected.to contain_grafana_plugin('grafana-plugin').with(ensure: 'present', repo: 'https://nexus.company.com/grafana/plugins') }
        end
      end

      context 'with parameter install_method is set to repo' do
        let(:params) do
          {
            install_method: 'repo'
          }
        end

        case facts[:osfamily]
        when 'Debian'
          describe 'install apt repo dependencies first' do
            it { is_expected.to contain_class('apt') }
            it { is_expected.to contain_apt__source('grafana').with(release: 'stable', repos: 'main', location: 'https://packages.grafana.com/oss/deb') }
            it { is_expected.to contain_apt__source('grafana').that_comes_before('Package[grafana]') }
          end

          describe 'install dependencies first' do
            it { is_expected.to contain_package('libfontconfig1').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('installed') }
          end
        when 'RedHat'
          describe 'yum repo dependencies first' do
            it { is_expected.to contain_yumrepo('grafana').with(baseurl: 'https://packages.grafana.com/oss/rpm', gpgkey: 'https://packages.grafana.com/gpg.key', enabled: 1) }
            it { is_expected.to contain_yumrepo('grafana').that_comes_before('Package[grafana]') }
          end

          describe 'install dependencies first' do
            it { is_expected.to contain_package('fontconfig').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('installed') }
          end
        end
      end

      context 'with parameter install_method is set to repo and manage_package_repo is set to false' do
        let(:params) do
          {
            install_method: 'repo',
            manage_package_repo: false,
            version: 'present'
          }
        end

        case facts[:osfamily]
        when 'Debian'
          describe 'install dependencies first' do
            it { is_expected.to contain_package('libfontconfig1').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('present') }
          end
        when 'RedHat'
          describe 'install dependencies first' do
            it { is_expected.to contain_package('fontconfig').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('present') }
          end
        when 'Archlinux'
          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('present') }
          end
        end
      end

      context 'with parameter install_method is set to archive' do
        let(:params) do
          {
            install_method: 'archive',
            version: '4.5.1'
          }
        end

        install_dir    = '/usr/share/grafana'
        service_config = '/usr/share/grafana/conf/custom.ini'
        archive_source = 'https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.5.1.linux-x64.tar.gz'

        describe 'extract archive to install_dir' do
          it { is_expected.to contain_archive('/tmp/grafana.tar.gz').with_ensure('present') }
          it { is_expected.to contain_archive('/tmp/grafana.tar.gz').with_source(archive_source) }
          it { is_expected.to contain_archive('/tmp/grafana.tar.gz').with_extract_path(install_dir) }
        end

        describe 'create grafana user' do
          it { is_expected.to contain_user('grafana').with_ensure('present').with_home(install_dir) }
          it { is_expected.to contain_user('grafana').that_comes_before('File[/usr/share/grafana]') }
        end

        describe 'create data_dir' do
          it { is_expected.to contain_file('/var/lib/grafana').with_ensure('directory') }
        end

        describe 'manage install_dir' do
          it { is_expected.to contain_file(install_dir).with_ensure('directory') }
          it { is_expected.to contain_file(install_dir).with_group('grafana').with_owner('grafana') }
        end

        describe 'configure grafana' do
          it { is_expected.to contain_file(service_config).with_ensure('file') }
        end

        describe 'run grafana as service' do
          it { is_expected.to contain_service(service_name).with_ensure('running').with_provider('base') }
          it { is_expected.to contain_service(service_name).with_hasrestart(false).with_hasstatus(false) }
        end

        context 'when user already defined' do
          let(:pre_condition) do
            'user{"grafana":
              ensure => present,
            }'
          end

          describe 'do NOT create grafana user' do
            it { is_expected.not_to contain_user('grafana').with_ensure('present').with_home(install_dir) }
          end
        end

        context 'when service already defined' do
          let(:pre_condition) do
            'service{"grafana-server":
              ensure     => running,
              hasrestart => true,
              hasstatus  => true,
            }'
          end

          # let(:params) {{ :service_name => 'grafana-server'}}
          describe 'do NOT run service' do
            it { is_expected.not_to contain_service('grafana-server').with_hasrestart(false).with_hasstatus(false) }
          end
        end
      end

      context 'invalid parameters' do
        context 'cfg' do
          describe 'should not raise an error when cfg parameter is a hash' do
            let(:params) do
              {
                cfg: {}
              }
            end

            it { is_expected.to contain_package('grafana') }
          end
        end
      end

      context 'configuration file' do
        describe 'should not contain any configuration when cfg param is empty' do
          it { is_expected.to contain_file(config_path).with_content("# This file is managed by Puppet, any changes will be overwritten\n\n") }
        end

        describe 'should correctly transform cfg param entries to Grafana configuration' do
          let(:params) do
            {
              cfg: {
                'app_mode' => 'production',
                'section'  => {
                  'string'  => 'production',
                  'number'  => 8080,
                  'boolean' => false,
                  'empty'   => ''
                }
              },
              ldap_cfg: {
                'servers' => [
                  { 'host' => 'server1',
                    'use_ssl'         => true,
                    'search_filter'   => '(sAMAccountName=%s)',
                    'search_base_dns' => ['dc=domain1,dc=com'] },
                  { 'host' => 'server2',
                    'use_ssl'         => true,
                    'search_filter'   => '(sAMAccountName=%s)',
                    'search_base_dns' => ['dc=domain2,dc=com'] }
                ],
                'servers.attributes' => {
                  'name'      => 'givenName',
                  'surname'   => 'sn',
                  'username'  => 'sAMAccountName',
                  'member_of' => 'memberOf',
                  'email'     => 'email'
                }
              }
            }
          end

          expected = "# This file is managed by Puppet, any changes will be overwritten\n\n"\
                     "app_mode = production\n\n"\
                     "[section]\n"\
                     "boolean = false\n"\
                     "empty = \n"\
                     "number = 8080\n"\
                     "string = production\n"

          it { is_expected.to contain_file(config_path).with_content(expected) }

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

          it { is_expected.to contain_file('/etc/grafana/ldap.toml').with_content(ldap_expected) }
        end
      end

      context 'sysconfig environment variables' do
        let(:params) do
          {
            install_method: 'repo',
            sysconfig: { http_proxy: 'http://proxy.example.com/' }
          }
        end

        case facts[:osfamily]
        when 'Debian'
          describe 'Add the environment variable to the config file' do
            it { is_expected.to contain_augeas('sysconfig/grafana-server').with_context('/files/etc/default/grafana-server') }
            it { is_expected.to contain_augeas('sysconfig/grafana-server').with_changes(['set http_proxy http://proxy.example.com/']) }
          end
        when 'RedHat'
          describe 'Add the environment variable to the config file' do
            it { is_expected.to contain_augeas('sysconfig/grafana-server').with_context('/files/etc/sysconfig/grafana-server') }
            it { is_expected.to contain_augeas('sysconfig/grafana-server').with_changes(['set http_proxy http://proxy.example.com/']) }
          end
        end
      end
    end
  end
end
