require 'spec_helper'

describe 'graphite::config_gunicorn', :type => 'class' do

  shared_context 'all platforms' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('graphite::params') }
  end

  shared_context 'RedHat supported platforms' do
    it { is_expected.to contain_package('python-gunicorn').with({ :name => 'python-gunicorn', :ensure => 'installed' }) }
  end

  shared_context 'RedHat 6 platforms' do
    it { is_expected.to contain_file('/etc/init.d/gunicorn').with({
        'ensure'  => 'file',
        'mode'    => '0755'}) }
    it { is_expected.to contain_service('gunicorn').with({
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasrestart' => 'true',
        'hasstatus'  => 'false',
        'provider'   => 'redhat'}).
        that_requires(
          ['Package[python-gunicorn]', 
           'File[/opt/graphite/conf/graphite_wsgi.py]', 
           'File[/etc/init.d/gunicorn]']) }
  end

  shared_context 'RedHat 7 platforms' do
    it { is_expected.to contain_exec('gunicorn-reload-systemd') }
    it { is_expected.to contain_file('/etc/systemd/system/gunicorn.service').with({
        'ensure'  => 'file',
        'mode'    => '0644'}).that_notifies('Exec[gunicorn-reload-systemd]') }
    it { is_expected.to contain_file('/etc/systemd/system/gunicorn.socket').with({
        'ensure'  => 'file',
        'mode'    => '0755'}).that_notifies('Exec[gunicorn-reload-systemd]') }
    it { is_expected.to contain_file('/etc/tmpfiles.d/gunicorn.conf').with({
        'ensure'  => 'file',
        'mode'    => '0644'}).that_notifies('Exec[gunicorn-reload-systemd]') }
    it { is_expected.to contain_service('gunicorn').with({
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasrestart' => 'true',
        'hasstatus'  => 'false',
        'provider'   => 'systemd'}).
        that_requires(
          ['Package[python-gunicorn]', 
           'Exec[gunicorn-reload-systemd]', 
           'File[/opt/graphite/conf/graphite_wsgi.py]']) }
  end

  shared_context 'Debian supported platforms' do
    it { is_expected.to contain_package('gunicorn').with({ :name => 'gunicorn', :ensure => 'installed' }) }
    it { is_expected.to contain_file('/etc/gunicorn.d').with({
        'ensure'  => 'directory',
        'path'    => '/etc/gunicorn.d'}) }
    it { is_expected.to contain_file('/etc/gunicorn.d/graphite').with({
        'ensure'  => 'file',
        'mode'    => '0644',
        'before'  => 'Package[gunicorn]' }).that_requires('File[/etc/gunicorn.d]') }
    it { is_expected.to contain_service('gunicorn').with({
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasrestart' => 'true',
        'hasstatus'  => 'false'}).
        that_requires(
          ['Package[gunicorn]', 
           'File[/opt/graphite/conf/graphite_wsgi.py]']) }
  end

  #shared_context 'Debian sysv platforms' do
    #it { is_expected.to contain_service('gunicorn').with({
        #'ensure'     => 'running',
        #'enable'     => 'true',
        #'hasrestart' => 'true',
        #'hasstatus'  => 'false',
        #'provider'   => 'debian'}).
        #that_requires(
          #['Package[gunicorn]', 
           #'File[/opt/graphite/conf/graphite_wsgi.py']) }
  #end

  #shared_context 'Debian systemd platforms' do
    #it { is_expected.to contain_service('gunicorn').with({
        #'ensure'     => 'running',
        #'enable'     => 'true',
        #'hasrestart' => 'true',
        #'hasstatus'  => 'false',
        #'provider'   => 'systemd'}).
        #that_requires(
          #['Package[gunicorn]', 
           #'File[/opt/graphite/conf/graphite_wsgi.py']) }
  #end

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
        case facts[:operatingsystemrelease]
        when /^6/ then
          it_behaves_like 'RedHat 6 platforms'
        when /^7/ then
          it_behaves_like 'RedHat 7 platforms'
        else
          it { is_expected.to raise_error(Puppet::Error,/unsupported os,.+\./ )}
        end
      else
        it { is_expected.to raise_error(Puppet::Error, /unsupported os,.+\./ )}
      end

    end

  end

end
