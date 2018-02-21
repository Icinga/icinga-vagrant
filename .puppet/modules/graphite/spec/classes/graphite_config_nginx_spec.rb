require 'spec_helper'

describe 'graphite::config_nginx', :type => 'class' do

  shared_context 'all platforms' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('graphite::params') }
    it { is_expected.to contain_package('nginx').only_with({ :name => 'nginx', :ensure => 'installed' }) }
    it { is_expected.to contain_service('nginx').only_with({
        'name'       => 'nginx',
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasrestart' => 'true',
        'hasstatus'  => 'true' }) }
    it { is_expected.to contain_file('/etc/nginx').only_with({
        'path'    => '/etc/nginx',
        'ensure'  => 'directory',
        'mode'    => '0755',
        'require' => 'Package[nginx]' }) }
  end

  shared_context 'RedHat supported platforms' do
    it { is_expected.to contain_file('/etc/nginx/graphite-htpasswd').with({
        'ensure'  => 'absent',
        'mode'    => '0400',
        'owner'   => 'nginx',
        'content' => nil,
        'require' => 'Package[nginx]',
        'notify'  => 'Service[nginx]' }) }
    it { is_expected.to contain_file('/etc/nginx/conf.d/default.conf').only_with({
        :path    => '/etc/nginx/conf.d/default.conf',
        :ensure  => 'absent',
        :require => 'Package[nginx]',
        :notify  => 'Service[nginx]'}) }
  end

  shared_context 'Debian supported platforms' do
    it { is_expected.to contain_file('/etc/nginx/graphite-htpasswd').with({
        'ensure'  => 'absent',
        'mode'    => '0400',
        'owner'   => 'www-data',
        'content' => nil,
        'require' => 'Package[nginx]',
        'notify'  => 'Service[nginx]' }) }
    it { is_expected.to contain_file('/etc/nginx/sites-enabled/default').only_with({
        :path    => '/etc/nginx/sites-enabled/default',
        :ensure  => 'absent',
        :require => 'Package[nginx]',
        :notify  => 'Service[nginx]'}) }
  end

  context 'Unsupported OS' do
    let(:facts) {{ :osfamily => 'unsupported', :operatingsystem => 'UnknownOS' }}
    it { is_expected.to raise_error(Puppet::Error, /unsupported os,.+\./ )}
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let :pre_condition do
        'class { ::graphite: gr_web_server => nginx }'
      end

      it_behaves_like 'all platforms'

      case facts[:osfamily]
      when 'Debian' then
        it_behaves_like 'Debian supported platforms'
      when 'RedHat' then
        it_behaves_like 'RedHat supported platforms'
      else
        it { is_expected.to raise_error(Puppet::Error, /unsupported os,.+\./ )}
      end

    end

  end

end
