require 'spec_helper'

describe 'logstash::plugin', :type => 'define' do

  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux'
  } end
  
  let(:title) { 'fooplugin' }

  context 'with bad source' do
    let(:params) { {
      :ensure   => 'present',
      :source   => 'http://mypatterns',
    } }

    it { expect { should raise_error(Puppet::Error) } }
  end

  context 'with bad plugin type' do
    let(:params) { {
      :ensure   => 'present',
      :source   => 'puppet:///path/to/plugin.rb',
      :type     => 'dontexist' 
    } }

    it { expect { should raise_error(Puppet::Error) } }
  end
end
