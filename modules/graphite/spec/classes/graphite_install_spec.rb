require 'spec_helper'

describe 'graphite::install', :type => 'class' do

  # Convenience variable for 'hack' file checks
  hack_defaults = {
    :ensure  => 'link',
    :require => ['Package[carbon]','Package[graphite-web]','Package[whisper]'],
  }

  shared_context 'supported platforms' do
    it { is_expected.to contain_class('graphite::params') }
    it { is_expected.to contain_package('python-pip').with_provider(nil) }
    it { is_expected.to contain_package('python-ldap').with_provider(nil) }
    it { is_expected.to contain_package('python-psycopg2').with_provider(nil) }

    ['carbon','django-tagging','graphite-web','twisted','txamqp','whisper'
    ].each do |pkg|
      it { is_expected.to contain_package(pkg).with_provider('pip').that_requires(
        'Package[python-ldap]').that_requires(
        'Package[python-psycopg2]') }
    end
    it { is_expected.to contain_file('carbon_hack').with(hack_defaults) }
    it { is_expected.to contain_file('gweb_hack').with(hack_defaults) }
  end

  shared_context 'no pip' do
    ['carbon','django-tagging','graphite-web','twisted','txamqp','whisper'
    ].each do |pkg|
      it { is_expected.to contain_package(pkg).with_provider(nil).that_requires(nil) }
    end
    it { is_expected.not_to contain_package('gcc') }
    it { is_expected.not_to contain_package('python-pip') }
    it { is_expected.not_to contain_package('python-dev') }
    it { is_expected.not_to contain_package('python-devel') }
    it { is_expected.not_to contain_file('carbon_hack') }
    it { is_expected.not_to contain_file('gweb_hack')   }
  end

  shared_context 'no django' do
    ['Django', 'python-django','Django14'].each do |pkg|
      it { is_expected.not_to contain_package(pkg) }
    end
  end

  shared_context 'RedHat supported platforms' do
    it { is_expected.to contain_package('carbon').with_provider(
      'pip').that_requires('Package[gcc]') }

    it { is_expected.to contain_package('python-devel').with_provider(nil) }
    it { is_expected.to contain_package('gcc').with_provider(nil) }
    it { is_expected.to contain_package('MySQL-python').with_provider(nil) }
    it { is_expected.to contain_package('pyOpenSSL').with_provider(nil) }
    it { is_expected.to contain_package('python-memcached').with_provider(nil) }
    it { is_expected.to contain_package('python-zope-interface').with_provider(nil) }
    it { is_expected.to contain_package('python-tzlocal').with_provider(nil) }
  end

  shared_context 'RedHat 6 platforms' do
    it { is_expected.to contain_package('pycairo').with_provider(nil) }
    it { is_expected.to contain_package('Django').with_provider('pip') }
    it { is_expected.to contain_package('python-sqlite2').with_provider(nil) }
    it { is_expected.to contain_package('bitmap').with_provider(nil) }
    it { is_expected.to contain_package('bitmap-fonts-compat').with_provider(nil) }
    it { is_expected.to contain_package('python-crypto').with_provider(nil) }

    it { is_expected.to contain_file('carbon_hack').only_with(hack_defaults.merge({
      :target => '/opt/graphite/lib/carbon-0.9.15-py2.6.egg-info',
      :path   => '/usr/lib/python2.6/site-packages/carbon-0.9.15-py2.6.egg-info',
    })) }
    it { should contain_file('gweb_hack').only_with(hack_defaults.merge({
      :target => '/opt/graphite/webapp/graphite_web-0.9.15-py2.6.egg-info',
      :path   => '/usr/lib/python2.6/site-packages/graphite_web-0.9.15-py2.6.egg-info',
    })) }
  end

  shared_context 'RedHat 7 platforms' do
    it { is_expected.to contain_package('python-cairocffi').with_provider(nil) }
    it { is_expected.to contain_package('Django').with_provider('pip') }
    it { is_expected.to contain_package('python-sqlite3dbm').with_provider(nil) }
    it { is_expected.to contain_package('dejavu-fonts-common').with_provider(nil) }
    it { is_expected.to contain_package('dejavu-sans-fonts').with_provider(nil) }
    it { is_expected.to contain_package('python2-crypto').with_provider(nil) }

    it { is_expected.to contain_file('carbon_hack').only_with(hack_defaults.merge({
      :target => '/opt/graphite/lib/carbon-0.9.15-py2.7.egg-info',
      :path   => '/usr/lib/python2.7/site-packages/carbon-0.9.15-py2.7.egg-info',
    })) }
    it { is_expected.to contain_file('gweb_hack').only_with(hack_defaults.merge({
      :target => '/opt/graphite/webapp/graphite_web-0.9.15-py2.7.egg-info',
      :path   => '/usr/lib/python2.7/site-packages/graphite_web-0.9.15-py2.7.egg-info',
    })) }
  end

  shared_context 'Debian supported platforms' do
    it { is_expected.to contain_package('Django').with_provider('pip') }
    it { is_expected.to contain_package('python-cairo').with_provider(nil) }
    it { is_expected.to contain_package('python-memcache').with_provider(nil) }
    it { is_expected.to contain_package('python-mysqldb').with_provider(nil) }
    it { is_expected.to contain_package('python-simplejson').with_provider(nil) }
    it { is_expected.to contain_package('python-sqlite').with_provider(nil) }
    it { is_expected.to contain_package('python-tz').with_provider(nil) }
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

      case facts[:osfamily]
      when 'Debian' then
        it_behaves_like 'supported platforms'
        it_behaves_like 'Debian supported platforms'

        context 'without pip' do
          let :pre_condition do 'class { graphite: gr_pip_install => false }' end
          it_behaves_like 'no pip'
        end

        context 'without django' do
          let :pre_condition do 'class { graphite: gr_django_pkg => false }' end
          it_behaves_like 'no django'
        end
      when 'RedHat' then
        it_behaves_like 'supported platforms'
        it_behaves_like 'RedHat supported platforms'

        case facts[:operatingsystemrelease]
        when /^6/ then
          it_behaves_like 'RedHat 6 platforms'
        when /^7/ then
          it_behaves_like 'RedHat 7 platforms'
        else
          it { is_expected.to raise_error(Puppet::Error,/unsupported os,.+\./ )}
        end

        context 'without pip' do
          let :pre_condition do 'class { graphite: gr_pip_install => false }' end
          it_behaves_like 'no pip'
        end

        context 'without django' do
          let :pre_condition do 'class { graphite: gr_django_pkg => false }' end
          it_behaves_like 'no django'
        end
      else
        it { is_expected.to raise_error(Puppet::Error,/unsupported os,.+\./ )}
      end
    end
  end
end
