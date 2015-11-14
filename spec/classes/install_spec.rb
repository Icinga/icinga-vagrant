require 'spec_helper'

describe 'graphite::install', :type => 'class' do
  # Convenience variable for 'hack' file checks
  hack_defaults = {
    :ensure  => 'link',
    :require => ['Package[carbon]','Package[graphite-web]','Package[whisper]'],
  }

  shared_context 'Unsupported OS' do
    it { should raise_error(Puppet::Error,/unsupported os,.+\./ )}
  end

  shared_context 'Debian unsupported platforms' do
    it { should raise_error(Puppet::Error,/Unsupported Debian release/) }
  end

  shared_context 'RedHat unsupported platforms' do
    it { should raise_error(Puppet::Error,/Unsupported RedHat release/) }
  end

  shared_context 'supported platforms' do
    it { should contain_class('graphite::params') }
    it { should contain_package('python-pip').with_provider(nil) }
    it { should contain_package('python-ldap').with_provider(nil) }
    it { should contain_package('python-psycopg2').with_provider(nil) }

    ['carbon','django-tagging','graphite-web','twisted','txamqp','whisper'
    ].each do |pkg|
      it { should contain_package(pkg).with_provider('pip').that_requires(
        'Package[python-ldap]').that_requires(
        'Package[python-psycopg2]') }
    end
    it { should contain_file('carbon_hack').with(hack_defaults) }
    it { should contain_file('gweb_hack').with(hack_defaults) }
  end

  shared_context 'no pip' do
    ['carbon','django-tagging','graphite-web','twisted','txamqp','whisper'
    ].each do |pkg|
      it { should contain_package(pkg).with_provider(nil).that_requires(nil) }
    end
    it { should_not contain_package('gcc') }
    it { should_not contain_package('python-pip') }
    it { should_not contain_package('python-dev') }
    it { should_not contain_package('python-devel') }
    it { should_not contain_file('carbon_hack') }
    it { should_not contain_file('gweb_hack')   }
  end

  shared_context 'no django' do
    ['python-django','Django14'].each do |pkg|
      it { should_not contain_package(pkg) }
    end
  end

  shared_context 'RedHat supported platforms' do
    it { should contain_package('carbon').with_provider(
      'pip').that_requires('Package[gcc]') }

    it { should contain_package('python-devel').with_provider(nil) }
    it { should contain_package('gcc').with_provider(nil) }
    it { should contain_package('MySQL-python').with_provider(nil) }
    it { should contain_package('bitmap').with_provider(nil) }
    it { should contain_package('bitmap-fonts-compat').with_provider(nil) }
    it { should contain_package('pyOpenSSL').with_provider(nil) }
    it { should contain_package('pycairo').with_provider(nil) }
    it { should contain_package('python-crypto').with_provider(nil) }
    it { should contain_package('python-memcached').with_provider(nil) }
    it { should contain_package('python-zope-interface').with_provider(nil) }
  end

  shared_context 'RedHat 6 platforms' do
    it { should contain_package('Django14').with_provider(nil) }
    it { should contain_package('python-sqlite2').with_provider(nil) }

    it { should contain_file('carbon_hack').only_with(hack_defaults.merge({
      :target => '/opt/graphite/lib/carbon-0.9.12-py2.6.egg-info',
      :path   => '/usr/lib/python2.6/site-packages/carbon-0.9.12-py2.6.egg-info',
    })) }
    it { should contain_file('gweb_hack').only_with(hack_defaults.merge({
      :target => '/opt/graphite/webapp/graphite_web-0.9.12-py2.6.egg-info',
      :path   => '/usr/lib/python2.6/site-packages/graphite_web-0.9.12-py2.6.egg-info',
    })) }
  end

  shared_context 'RedHat 7 platforms' do
    it { should contain_package('python-django').with_provider(nil) }
    it { should contain_package('python-sqlite3dbm').with_provider(nil) }

    it { should contain_file('carbon_hack').only_with(hack_defaults.merge({
      :target => '/opt/graphite/lib/carbon-0.9.12-py2.7.egg-info',
      :path   => '/usr/lib/python2.7/site-packages/carbon-0.9.12-py2.7.egg-info',
    })) }
    it { should contain_file('gweb_hack').only_with(hack_defaults.merge({
      :target => '/opt/graphite/webapp/graphite_web-0.9.12-py2.7.egg-info',
      :path   => '/usr/lib/python2.7/site-packages/graphite_web-0.9.12-py2.7.egg-info',
    })) }
  end

  shared_context 'Debian supported platforms' do
    it { should contain_package('python-django').with_provider(nil) }

    it { should contain_package('python-cairo').with_provider(nil) }
    it { should contain_package('python-memcache').with_provider(nil) }
    it { should contain_package('python-mysqldb').with_provider(nil) }
    it { should contain_package('python-simplejson').with_provider(nil) }
    it { should contain_package('python-sqlite').with_provider(nil) }
    it { should contain_package('python-tz').with_provider(nil) }
  end

  # Loop through various contexts
  [ { :osfamily => 'Debian', :lsbdistcodename => 'capybara', :operatingsystem => 'Debian' },
    { :osfamily => 'Debian', :lsbdistcodename => 'squeeze',  :operatingsystem => 'Debian' },
    { :osfamily => 'Debian', :lsbdistcodename => 'trusty',   :operatingsystem => 'Debian' },
    { :osfamily => 'FreeBSD', :operatingsystemrelease => '8.4-RELEASE-p27', :operatingsystem => 'FreeBSD' },
    { :osfamily => 'RedHat', :operatingsystemrelease => '5.0', :operatingsystem => 'CentOS' },
    { :osfamily => 'RedHat', :operatingsystemrelease => '6.6', :operatingsystem => 'CentOS' },
    { :osfamily => 'RedHat', :operatingsystemrelease => '7.1', :operatingsystem => 'CentOS' },
  ].each do |myfacts|

    context 'OS %s %s' % myfacts.values do
      let :facts do myfacts end
      let :pre_condition do 'include ::graphite' end

      case myfacts[:osfamily]
      when 'Debian' then
        case myfacts[:lsbdistcodename]
        when 'capybara' then
          it_behaves_like 'Debian unsupported platforms'
        else
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
        end
      when 'RedHat' then
        case myfacts[:operatingsystemrelease]
        when /^[6-7]/ then
          it_behaves_like 'supported platforms'
          it_behaves_like 'RedHat supported platforms'
          case myfacts[:operatingsystemrelease]
          when /^6/ then
            it_behaves_like 'RedHat 6 platforms'
          when /^7/ then
            it_behaves_like 'RedHat 7 platforms'
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
          it_behaves_like 'RedHat unsupported platforms'
        end
      else
        it_behaves_like 'Unsupported OS'
      end
    end
  end
end
