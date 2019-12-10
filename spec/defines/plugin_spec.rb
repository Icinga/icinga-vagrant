require 'spec_helper'

describe 'docker::plugin', type: :define do
  let(:title) { 'foo/plugin:latest' }
  let(:facts) do
    {
      osfamily: 'Debian',
      operatingsystem: 'Debian',
      lsbdistid: 'Debian',
      lsbdistcodename: 'jessie',
      kernelrelease: '3.2.0-4-amd64',
      operatingsystemmajrelease: '8',
    }
  end

  context 'with defaults for all parameters' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('plugin install foo/plugin:latest').with_command(%r{docker plugin install}) }
    it { is_expected.to contain_exec('plugin install foo/plugin:latest').with_unless(%r{docker ls --format='{{.PluginReference}}' | grep -w foo/plugin:latest}) }
  end

  context 'with enabled => false' do
    let(:params) { { 'enabled' => false } }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('disable foo/plugin:latest').with_command(%r{docker plugin disable}) }
    it { is_expected.to contain_exec('disable foo/plugin:latest').with_unless(%r{docker ls --format='{{.PluginReference}}' | grep -w foo/plugin:latest}) }
  end

  context 'with ensure => absent' do
    let(:params) { { 'ensure' => 'absent' } }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('plugin remove foo/plugin:latest').with_command(%r{docker plugin rm}) }
    it { is_expected.to contain_exec('plugin remove foo/plugin:latest').with_onlyif(%r{docker ls --format='{{.PluginReference}}' | grep -w foo/plugin:latest}) }
  end

  context 'with alias => foo-plugin' do
    let(:params) { { 'plugin_alias' => 'foo-plugin' } }

    it { is_expected.to contain_exec('plugin install foo/plugin:latest').with_command(%r{docker plugin install}) }
    it { is_expected.to contain_exec('plugin install foo/plugin:latest').with_unless(%r{docker ls --format='{{.PluginReference}}' | grep -w foo/plugin:latest}) }
  end
end
