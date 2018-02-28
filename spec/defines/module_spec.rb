require 'spec_helper'

describe('icingaweb2::module', :type => :define) do
  let(:title) { 'mymodule' }
  let(:pre_condition) { [
      "class { 'icingaweb2': }"
  ] }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context "#{os} with install_method 'none'" do
        let(:params) { { :module => 'foo',
                         :module_dir => '/usr/local/icingaweb2-modules/foo',
                         :install_method => 'none',
                         :settings => {'section1' => { 'target' => '/foo/bar', 'settings' => {'setting1' => 'value1', 'setting2' => 'value2' } } } } }

        it { is_expected.to contain_file('/etc/icingaweb2/enabledModules') }
        it { is_expected.to contain_file('/etc/icingaweb2/enabledModules/foo') }
        it { is_expected.to contain_file('/etc/icingaweb2/modules') }
        it { is_expected.to contain_file('/etc/icingaweb2/modules/foo') }

        it { is_expected.to contain_icingaweb2__inisection('section1')
                                .with_target('/foo/bar')
                                .with_settings({'setting1' => 'value1', 'setting2' => 'value2'})}
      end

      context "#{os} with install_method 'git'" do
        let(:params) { { :module => 'foo',
                         :module_dir => '/usr/local/icingaweb2-modules/foo',
                         :git_repository => 'https://github.com/icinga/foo.git',
                         :git_revision => 'master',
                         :settings => {'section1' => { 'target' => '/foo/bar', 'settings' => {'setting1' => 'value1', 'setting2' => 'value2' } } } } }

        it { is_expected.to contain_file('/etc/icingaweb2/enabledModules') }
        it { is_expected.to contain_file('/etc/icingaweb2/enabledModules/foo') }
        it { is_expected.to contain_file('/etc/icingaweb2/modules') }
        it { is_expected.to contain_file('/etc/icingaweb2/modules/foo') }

        it { is_expected.to contain_vcsrepo('/usr/local/icingaweb2-modules/foo')
          .with_provider('git')
          .with_source('https://github.com/icinga/foo.git')
          .with_revision('master')}

        it { is_expected.to contain_icingaweb2__inisection('section1')
          .with_target('/foo/bar')
          .with_settings({'setting1' => 'value1', 'setting2' => 'value2'})}
      end

      context "#{os} with install_method 'package'" do
        let(:params) { { :module => 'foo',
                         :module_dir => '/usr/local/icingaweb2-modules/foo',
                         :install_method => 'package',
                         :package_name => 'foo',
                         :settings => {'section1' => { 'target' => '/foo/bar', 'settings' => {'setting1' => 'value1', 'setting2' => 'value2' } } } } }

        it { is_expected.to contain_file('/etc/icingaweb2/enabledModules') }
        it { is_expected.to contain_file('/etc/icingaweb2/enabledModules/foo') }
        it { is_expected.to contain_file('/etc/icingaweb2/modules') }
        it { is_expected.to contain_file('/etc/icingaweb2/modules/foo') }

        it { is_expected.to contain_package('foo').with({ 'ensure' => 'present' }) }

        it { is_expected.to contain_icingaweb2__inisection('section1')
          .with_target('/foo/bar')
          .with_settings({'setting1' => 'value1', 'setting2' => 'value2'})}
      end

      context "#{os} with invalid installation_method" do
        let(:params) { { :module => 'foor',
                         :module_dir => '/usr/local/icingaweb2-modules/foo',
                         :install_method => 'foobar' } }

        it { is_expected.to raise_error(Puppet::Error, /expects a match for Enum\['git', 'none', 'package'\]/) }
      end
    end
  end
end
