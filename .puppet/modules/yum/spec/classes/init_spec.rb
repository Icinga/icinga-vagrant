require 'spec_helper'
require 'deep_merge'

shared_examples 'a Yum class' do |value|
  value ||= 3

  it { is_expected.to contain_yum__config('installonly_limit').with_ensure(value.to_s) }
  it 'contains Exec[package-cleanup_oldkernels' do
    is_expected.to contain_exec('package-cleanup_oldkernels').with(
      command: "/usr/bin/package-cleanup --oldkernels --count=#{value} -y",
      refreshonly: true
    ).that_requires('Package[yum-utils]').that_subscribes_to('Yum::Config[installonly_limit]')
  end
end

shared_examples 'a catalog containing repos' do |repos|
  repos.each do |repo|
    it { is_expected.to contain_yumrepo(repo) }
  end
end

describe 'yum' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('yum') }

      context 'without any parameters' do
        let(:params) { {} }

        it_behaves_like 'a Yum class'
        it { is_expected.to have_yumrepo_resource_count(0) }
      end

      context 'when `manage_os_default_repos` is enabled' do
        let(:params) { { 'manage_os_default_repos' => true } }

        case facts[:os]['name']
        when 'CentOS'
          it { is_expected.to have_yumrepo_resource_count(10) }
          it_behaves_like 'a catalog containing repos', [
            'base',
            'updates',
            'extras',
            'base-source',
            'updates-source',
            'extras-source',
            'base-debuginfo',
            'centosplus',
            'centos-media'
          ]
          case facts[:os]['release']['major']
          when '7'
            it { is_expected.to contain_yumrepo('cr') }
            it { is_expected.not_to contain_yumrepo('contrib') }
          when '6'
            it { is_expected.to contain_yumrepo('contrib') }
            it { is_expected.not_to contain_yumrepo('cr') }
          end
        when 'Amazon'
          it { is_expected.to have_yumrepo_resource_count(16) }
          it_behaves_like 'a catalog containing repos', [
            'amzn-main',
            'amzn-main-debuginfo',
            'amzn-main-source',
            'amzn-nosrc',
            'amzn-preview',
            'amzn-preview-debuginfo',
            'amzn-preview-source',
            'amzn-updates',
            'amzn-updates-debuginfo',
            'amzn-updates-source',
            'epel',
            'epel-debuginfo',
            'epel-source',
            'epel-testing',
            'epel-testing-debuginfo',
            'epel-testing-source'
          ]
        when 'RedHat'
          it { is_expected.to have_yumrepo_resource_count(18) }
          it_behaves_like 'a catalog containing repos', [
            'rhui-REGION-rhel-server-releases',
            'rhui-REGION-rhel-server-releases-debug',
            'rhui-REGION-rhel-server-releases-source',
            'rhui-REGION-rhel-server-rhscl',
            'rhui-REGION-rhel-server-debug-rhscl',
            'rhui-REGION-rhel-server-source-rhscl',
            'rhui-REGION-rhel-server-extras',
            'rhui-REGION-rhel-server-debug-extras',
            'rhui-REGION-rhel-server-source-extras',
            'rhui-REGION-rhel-server-optional',
            'rhui-REGION-rhel-server-debug-optional',
            'rhui-REGION-rhel-server-source-optional',
            'rhui-REGION-rhel-server-rh-common',
            'rhui-REGION-rhel-server-debug-rh-common',
            'rhui-REGION-rhel-server-source-rh-common',
            'rhui-REGION-rhel-server-supplementary',
            'rhui-REGION-rhel-server-debug-supplementary',
            'rhui-REGION-rhel-server-source-supplementary'
          ]
        else
          it { is_expected.to have_yumrepo_resource_count(0) }
        end

        context 'and the CentOS base repo is negated' do
          let(:facts) { facts.merge(hiera_fixture: 'repo_exclusions') }

          case facts[:os]['name']
          when 'CentOS'
            it { is_expected.not_to contain_yumrepo('base') }
            it_behaves_like 'a catalog containing repos', [
              'updates',
              'extras',
              'base-source',
              'updates-source',
              'extras-source',
              'base-debuginfo',
              'centosplus',
              'centos-media'
            ]
          when 'Amazon'
            it { is_expected.to have_yumrepo_resource_count(16) }
            it_behaves_like 'a catalog containing repos', [
              'amzn-main',
              'amzn-main-debuginfo',
              'amzn-main-source',
              'amzn-nosrc',
              'amzn-preview',
              'amzn-preview-debuginfo',
              'amzn-preview-source',
              'amzn-updates',
              'amzn-updates-debuginfo',
              'amzn-updates-source',
              'epel',
              'epel-debuginfo',
              'epel-source',
              'epel-testing',
              'epel-testing-debuginfo',
              'epel-testing-source'
            ]
          when 'RedHat'
            it { is_expected.to have_yumrepo_resource_count(18) }
            it_behaves_like 'a catalog containing repos', [
              'rhui-REGION-rhel-server-releases',
              'rhui-REGION-rhel-server-releases-debug',
              'rhui-REGION-rhel-server-releases-source',
              'rhui-REGION-rhel-server-rhscl',
              'rhui-REGION-rhel-server-debug-rhscl',
              'rhui-REGION-rhel-server-source-rhscl',
              'rhui-REGION-rhel-server-extras',
              'rhui-REGION-rhel-server-debug-extras',
              'rhui-REGION-rhel-server-source-extras',
              'rhui-REGION-rhel-server-optional',
              'rhui-REGION-rhel-server-debug-optional',
              'rhui-REGION-rhel-server-source-optional',
              'rhui-REGION-rhel-server-rh-common',
              'rhui-REGION-rhel-server-debug-rh-common',
              'rhui-REGION-rhel-server-source-rh-common',
              'rhui-REGION-rhel-server-supplementary',
              'rhui-REGION-rhel-server-debug-supplementary',
              'rhui-REGION-rhel-server-source-supplementary'
            ]
          else
            it { is_expected.to have_yumrepo_resource_count(0) }
          end
        end
      end

      context 'when `managed_repos` is set' do
        # TODO: This should be generated with something like `lookup('yum::repos').keys`,
        # but the setup for `Puppet::Pops::Lookup` is to complicated to be worth it as of
        # this writing (2017-04-11).  For now, we just pull from `repos.yaml`.
        repos_yaml_data = YAML.load(File.read('./spec/fixtures/modules/yum/data/repos.yaml'))
        supported_repos = repos_yaml_data['yum::repos'].keys

        supported_repos.each do |supported_repo|
          context "to ['#{supported_repo}']" do
            let(:params) { { managed_repos: [supported_repo] } }

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to have_yumrepo_resource_count(1) }
            it { is_expected.to contain_yumrepo(supported_repo) }
          end
        end

        context 'to an array of all supported repos' do
          let(:params) { { managed_repos: supported_repos } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to have_yumrepo_resource_count(supported_repos.count) }
          it_behaves_like 'a catalog containing repos', supported_repos
        end
      end

      context 'when `config_options[installonly_limit]` is modified' do
        context 'with an Integer' do
          let(:params) { { config_options: { 'installonly_limit' => 10 } } }

          it_behaves_like 'a Yum class', 10
        end

        context 'with an invalid data type' do
          let(:params) { { config_options: { 'installonly_limit' => false } } }

          it 'raises a useful error' do
            is_expected.to raise_error(
              Puppet::PreformattedError,
              %r{The value or ensure for `\$yum::config_options\[installonly_limit\]` must be an Integer, but it is not\.}
            )
          end
        end
      end

      context 'when a config option other than `installonly_limit` is set' do
        context 'to a String' do
          let(:params) { { config_options: { 'cachedir' => '/var/cache/yum' } } }

          it { is_expected.to contain_yum__config('cachedir').with_ensure('/var/cache/yum') }
          it_behaves_like 'a Yum class'
        end

        context 'to an Integer' do
          let(:params) { { config_options: { 'debuglevel' => 5 } } }

          it { is_expected.to contain_yum__config('debuglevel').with_ensure('5') }
          it_behaves_like 'a Yum class'
        end

        context 'to a Boolean' do
          let(:params) { { config_options: { 'gpgcheck' => true } } }

          it { is_expected.to contain_yum__config('gpgcheck').with_ensure('1') }
          it_behaves_like 'a Yum class'
        end

        context 'using the nested attributes syntax' do
          context 'to a String' do
            let(:params) { { config_options: { 'my_cachedir' => { 'ensure' => '/var/cache/yum', 'key' => 'cachedir' } } } }

            it { is_expected.to contain_yum__config('my_cachedir').with_ensure('/var/cache/yum').with_key('cachedir') }
            it_behaves_like 'a Yum class'
          end

          context 'to an Integer' do
            let(:params) { { config_options: { 'my_debuglevel' => { 'ensure' => 5, 'key' => 'debuglevel' } } } }

            it { is_expected.to contain_yum__config('my_debuglevel').with_ensure('5').with_key('debuglevel') }
            it_behaves_like 'a Yum class'
          end

          context 'to a Boolean' do
            let(:params) { { config_options: { 'my_gpgcheck' => { 'ensure' => true, 'key' => 'gpgcheck' } } } }

            it { is_expected.to contain_yum__config('my_gpgcheck').with_ensure('1').with_key('gpgcheck') }
            it_behaves_like 'a Yum class'
          end
        end
      end

      context 'when clean_old_kernels => false' do
        let(:params) { { clean_old_kernels: false } }

        it { is_expected.to contain_exec('package-cleanup_oldkernels').without_subscribe }
      end
    end
  end

  context 'on an unsupported operating system' do
    let(:facts) { { os: { family: 'Solaris', name: 'Nexenta' } } }

    it { is_expected.to raise_error(Puppet::Error, %r{Nexenta not supported}) }
  end
end
