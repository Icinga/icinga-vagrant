require 'spec_helper'

describe 'graphite' do

  shared_context 'supported' do
    it { should contain_anchor('graphite::begin').that_comes_before(
      'Class[graphite::install]') }
    it { should contain_class('graphite::install').that_notifies(
      'Class[graphite::config]') }
    it { should contain_class('graphite::config').that_comes_before(
      'Anchor[graphite::end]') }
    it { should contain_anchor('graphite::end') }
  end

  context 'Unsupported OS' do
    let(:facts) {{ :osfamily => 'unsupported' }}
    it { expect { should contain_class('graphite')}.to raise_error(Puppet::Error, /unsupported os./ )}
  end

  context 'RedHat supported platforms' do
    ['6.5','7.5'].each do | operatingsystemrelease |
      let(:facts) {{ :osfamily => 'RedHat', :operatingsystemrelease => operatingsystemrelease}}
      describe "Release #{operatingsystemrelease}" do
        it_behaves_like 'supported'
      end
    end
  end

  context 'RedHat unsupported platforms' do
    ['5.0'].each do | operatingsystemrelease |
      let(:facts) {{ :osfamily => 'RedHat', :operatingsystemrelease => operatingsystemrelease}}
      describe "Redhat #{operatingsystemrelease} fails" do
        it { expect { should contain_class('graphite')}.to raise_error(Puppet::Error, /Unsupported RedHat release/) }
      end
    end
  end

  context 'Debian supported platforms' do
    ['trusty','squeeze'].each do | lsbdistcodename |
      let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => lsbdistcodename}}
      describe "Lsbdistcodename #{lsbdistcodename}" do
        it_behaves_like 'supported'
      end
    end
  end

  context 'Debian unsupported platforms' do
    ['capybara'].each do | lsbdistcodename |
      let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => lsbdistcodename}}
      describe "Debian #{lsbdistcodename} fails" do
        it { expect { should contain_class('graphite')}.to raise_error(Puppet::Error, /Unsupported Debian release/) }
      end
    end
  end

end
