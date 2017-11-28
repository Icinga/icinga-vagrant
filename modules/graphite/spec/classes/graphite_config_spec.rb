require 'spec_helper'

describe 'graphite::config', :type => 'class' do

  shared_context 'all platforms' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('graphite::params') }
    it { is_expected.to contain_exec('Initial django db creation') }
    it { is_expected.to contain_class('graphite::config_apache') }

    it { is_expected.to contain_file('/opt/graphite/conf/storage-schemas.conf').with({
        'ensure' => 'file', 'mode' => '0644', 'notify' => /carbon-cache/, 'content' => /^retentions = 1m:90d$/ }) }
    it { is_expected.to contain_file('/opt/graphite/conf/carbon.conf').with({
        'ensure' => 'file', 'mode' => '0644', 'notify' => /carbon-cache/, 'content' => /^MAX_UPDATES_PER_SECOND = 500$/ }) }
    it { is_expected.to contain_file('/opt/graphite/conf/storage-aggregation.conf').with({
        'ensure' => 'file', 'mode' => '0644', 'content' => /^aggregationMethod = average$/ }) }
    it { is_expected.to contain_file('/opt/graphite/conf/whitelist.conf').with({
        'ensure' => 'file', 'mode' => '0644', 'content' => /^\.\*$/ }) }
    it { is_expected.to contain_file('/opt/graphite/conf/blacklist.conf').with({
        'ensure' => 'file', 'mode' => '0644', 'content' => /^# This file is reloaded automatically when changes are made$/ }) }

    # cron check
    it { is_expected.to contain_file('/opt/graphite/bin/carbon-logrotate.sh').with({
        'ensure' => 'file', 'mode' => '0544', 'content' => /^CARBON_LOGS_PATH="\/opt\/graphite\/storage\/log"$/ }) }
    it { is_expected.to contain_cron('Rotate carbon logs').with({
        'command' => '/opt/graphite/bin/carbon-logrotate.sh',
        'hour'    => '3',
        'minute'  => '15',
        'require' => 'File[/opt/graphite/bin/carbon-logrotate.sh]',
        'user'    => 'root',}) }
  end

  shared_context 'RedHat supported platforms' do
    it { is_expected.to contain_file('/opt/graphite/storage/whisper').with({
        'ensure' => 'directory', 'seltype' => 'httpd_sys_rw_content_t', 'owner' => 'apache', 'group' => 'apache', 'mode' => '0755', }) }
    it { is_expected.to contain_file('/opt/graphite/storage/log/carbon-cache').with({
        'ensure' => 'directory', 'seltype' => 'httpd_sys_rw_content_t', 'owner' => 'apache', 'group' => 'apache', 'mode' => '0755', }) }
    it { is_expected.to contain_file('/opt/graphite/storage/graphite.db').with({
        'ensure' => 'file', 'owner' => 'apache', 'group' => 'apache', 'mode' => '0644', }) }
    it { is_expected.to contain_file('/opt/graphite/webapp/graphite/local_settings.py').with({
        'ensure'  => 'file',
        'owner'   => 'apache',
        'group'   => 'apache',
        'mode'    => '0644',
        'seltype' => 'httpd_sys_content_t',
        'content' => /^CONF_DIR = '\/opt\/graphite\/conf'$/,
        'notify'  => 'Service[httpd]'}).that_requires('Package[httpd]') }
    it { is_expected.to contain_file('/opt/graphite/conf/graphite_wsgi.py').with({
        'path'    => '/opt/graphite/conf/graphite_wsgi.py',
        'ensure'  => 'file',
        'owner'   => 'apache',
        'group'   => 'apache',
        'mode'    => '0644',
        'seltype' => 'httpd_sys_content_t',
        'notify'  => 'Service[httpd]'}).that_requires('Package[httpd]') }
    it { is_expected.to contain_file('/opt/graphite/webapp/graphite/graphite_wsgi.py').with({
        'ensure'  => 'link',
        'target'  => '/opt/graphite/conf/graphite_wsgi.py',
        'require' => 'File[/opt/graphite/conf/graphite_wsgi.py]',
        'notify'  => 'Service[httpd]' }) }

    it { is_expected.to contain_file('/opt/graphite').with({
        'ensure'  => 'directory',
        'group'   => 'apache',
        'mode'    => '0755',
        'owner'   => 'apache',
        'seltype' => 'httpd_sys_rw_content_t' }) }

    $attributes_redhat = {'ensure' => 'directory', 'seltype' => 'httpd_sys_rw_content_t', 'group' => 'apache', 'mode' => '0755', 'owner' => 'apache', 'subscribe' => 'Exec[Initial django db creation]'}
    ['/opt/graphite/storage',
      '/opt/graphite/storage/rrd',
      '/opt/graphite/storage/lists',
      '/opt/graphite/storage/log',
      '/var/lib/graphite-web'].each { |f|
      it { is_expected.to contain_file(f).with($attributes_redhat)}
    }
  end

  shared_context 'RedHat 6 platforms' do
    it { is_expected.to contain_file('/etc/init.d/carbon-cache').with({
        'ensure'  => 'file',
        'content' => /^GRAPHITE_DIR="\/opt\/graphite"$/,
        'mode'    => '0750',
        'require' => 'File[/opt/graphite/conf/carbon.conf]',
        'notify'  => [] }) }
    it { is_expected.to contain_service('carbon-cache').with({
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasrestart' => 'true',
        'hasstatus'  => 'true',
        'provider'   => 'redhat',
        'require'    => 'File[/etc/init.d/carbon-cache]' }) }
  end

  shared_context 'RedHat 7 platforms' do
    it { is_expected.to contain_exec('graphite-reload-systemd') }
    it { is_expected.to contain_file('/etc/init.d/carbon-cache').with({
        'ensure'  => 'file',
        'content' => /^GRAPHITE_DIR="\/opt\/graphite"$/,
        'mode'    => '0750',
        'require' => 'File[/opt/graphite/conf/carbon.conf]',
        'notify'  => /graphite-reload-systemd/ }) }
    it { is_expected.to contain_service('carbon-cache').with({
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasrestart' => 'true',
        'hasstatus'  => 'true',
        'provider'   => 'systemd',
        'require'    => 'File[/etc/init.d/carbon-cache]' }) }
  end

  shared_context 'Debian supported platforms' do
    it { is_expected.to contain_file('/opt/graphite/storage/whisper').with({
        'ensure' => 'directory', 'owner' => 'www-data', 'group' => 'www-data', 'mode' => '0755', }) }
    it { is_expected.to contain_file('/opt/graphite/storage/log/carbon-cache').with({
        'ensure' => 'directory', 'owner' => 'www-data', 'group' => 'www-data', 'mode' => '0755', }) }
    it { is_expected.to contain_file('/opt/graphite/storage/graphite.db').with({
        'ensure' => 'file', 'owner' => 'www-data', 'group' => 'www-data', 'mode' => '0644', }) }
    it { is_expected.to contain_file('/opt/graphite/webapp/graphite/local_settings.py').with({
        'ensure'   => 'file',
        'owner'   => 'www-data',
        'group'   => 'www-data',
        'mode'    => '0644',
        'content' => /^CONF_DIR = '\/opt\/graphite\/conf'$/,
        'notify'  => 'Service[apache2]' }).that_requires('Package[apache2]') }
    it { is_expected.to contain_file('/opt/graphite/conf/graphite_wsgi.py').with({
        'path'    => '/opt/graphite/conf/graphite_wsgi.py',
        'ensure'  => 'file',
        'owner'   => 'www-data',
        'group'   => 'www-data',
        'mode'    => '0644',
        'notify'  => 'Service[apache2]'}).that_requires('Package[apache2]') }
    it { is_expected.to contain_file('/opt/graphite/webapp/graphite/graphite_wsgi.py').only_with({
        'path'    => '/opt/graphite/webapp/graphite/graphite_wsgi.py',
        'ensure'  => 'link',
        'target'  => '/opt/graphite/conf/graphite_wsgi.py',
        'require' => 'File[/opt/graphite/conf/graphite_wsgi.py]',
        'notify'  => 'Service[apache2]'}) }

    it { is_expected.to contain_file('/opt/graphite').with({
        'ensure'  => 'directory',
        'group'   => 'www-data',
        'mode'    => '0755',
        'owner'   => 'www-data',
        'seltype' => 'httpd_sys_rw_content_t' }) }

    $attributes_debian = {'ensure' => 'directory', 'seltype' => 'httpd_sys_rw_content_t', 'group' => 'www-data', 'mode' => '0755', 'owner' => 'www-data', 'subscribe' => 'Exec[Initial django db creation]'}
    ['/opt/graphite/storage',
      '/opt/graphite/storage/rrd',
      '/opt/graphite/storage/lists',
      '/opt/graphite/storage/log',
      '/var/lib/graphite-web'].each { |f|
      it { is_expected.to contain_file(f).with($attributes_debian)}
    }

  end

  shared_context 'Debian sysv platforms' do
    it { is_expected.to contain_file('/etc/init.d/carbon-cache').with({
        'ensure'  => 'file',
        'content' => /^GRAPHITE_DIR="\/opt\/graphite"$/,
        'mode'    => '0750',
        'require' => 'File[/opt/graphite/conf/carbon.conf]',
        'notify'  => [] }) }
    it { is_expected.to contain_service('carbon-cache').with({
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasrestart' => 'true',
        'hasstatus'  => 'true',
        'provider'   => 'debian',
        'require'    => 'File[/etc/init.d/carbon-cache]' }) }
  end

  shared_context 'Debian systemd platforms' do
    it { is_expected.to contain_exec('graphite-reload-systemd') }
    it { is_expected.to contain_file('/etc/init.d/carbon-cache').with({
        'ensure'  => 'file',
        'content' => /^GRAPHITE_DIR="\/opt\/graphite"$/,
        'mode'    => '0750',
        'require' => 'File[/opt/graphite/conf/carbon.conf]',
        'notify'  => /graphite-reload-systemd/ }) }
    it { is_expected.to contain_service('carbon-cache').with({
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasrestart' => 'true',
        'hasstatus'  => 'true',
        'provider'   => 'systemd',
        'require'    => 'File[/etc/init.d/carbon-cache]' }) }
  end

  context 'Unsupported OS' do
    let(:facts) {{ :osfamily => 'unsupported', :operatingsystem => 'UnknownOS' }}
    it { is_expected.to raise_error(Puppet::Error,/unsupported os,.+\./ )}
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
        case facts[:lsbdistcodename]
        when /squeeze|wheezy|precise|trusty|utopic|vivid/ then
          it_behaves_like 'Debian sysv platforms'
        when /jessie|wily|xenial/ then
          it_behaves_like 'Debian systemd platforms'
        else
          it { is_expected.to raise_error(Puppet::Error,/unsupported os,.+\./ )}
        end
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
        it { is_expected.to raise_error(Puppet::Error,/unsupported os,.+\./ )}
      end

    end
  end

end
