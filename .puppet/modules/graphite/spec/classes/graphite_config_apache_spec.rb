require 'spec_helper'

describe 'graphite::config_apache', :type => 'class' do

  shared_context 'all platforms' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('graphite::params') }
  end

  shared_context 'RedHat supported platforms' do
    it { is_expected.to contain_package('httpd').only_with({ :name => 'httpd', :ensure => 'installed' }) }
    it { is_expected.to contain_package('mod_wsgi').only_with({ :name => 'mod_wsgi', :ensure => 'installed', 'require' => 'Package[httpd]'}) }
    it { is_expected.to contain_service('httpd').only_with({
        :name       => 'httpd',
        :ensure     => 'running',
        :enable     => 'true',
        :hasrestart => 'true',
        :hasstatus  => 'true'})
    }
    it { is_expected.to contain_file('/var/log/httpd/graphite-web').only_with({
        :path    => '/var/log/httpd/graphite-web',
        :ensure  => 'directory',
        :group   => 'apache',
        :owner   => 'apache',
        :mode    => '0644',
        :require => 'Package[httpd]',
        :before  => 'Service[httpd]'})
    }
    it { is_expected.to contain_file('/etc/httpd/conf.d/welcome.conf').only_with({
        :path    => '/etc/httpd/conf.d/welcome.conf',
        :ensure  => 'absent',
        :require => 'Package[mod_wsgi]',
        :notify  => 'Service[httpd]'})
    }
  end

  shared_context 'Debian supported platforms' do
    it { is_expected.to contain_package('apache2').only_with({ :name => 'apache2', :ensure => 'installed' }) }
    it { is_expected.to contain_package('libapache2-mod-wsgi').only_with({ :name => 'libapache2-mod-wsgi', :ensure => 'installed', 'require' => 'Package[apache2]'}) }
    it { is_expected.to contain_service('apache2').only_with({
        :name       => 'apache2',
        :ensure     => 'running',
        :enable     => 'true',
        :hasrestart => 'true',
        :hasstatus  => 'true'})
    }
    it { is_expected.to contain_file('/var/log/apache2/graphite-web').only_with({
        :path    => '/var/log/apache2/graphite-web',
        :ensure  => 'directory',
        :group   => 'www-data',
        :owner   => 'www-data',
        :mode    => '0644',
        :require => 'Package[apache2]',
        :before  => 'Service[apache2]'})
    }
    it { is_expected.to contain_exec('Disable default apache site').only_with({
        :command => 'a2dissite 000-default',
        :path    => '/bin:/usr/bin:/usr/sbin',
        :notify  => 'Service[apache2]',
        :onlyif  => 'test -f /etc/apache2/sites-enabled/000-default -o -f /etc/apache2/sites-enabled/000-default.conf',
        :require => 'Package[libapache2-mod-wsgi]',})
    }
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
        'include ::graphite'
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
