require 'spec_helper'

describe 'logstash::configfile', :type => 'define' do

  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux'
  } end
  
  let(:title) { 'configfile' }

  let(:pre_condition) { 'class {"logstash": }'}

  context 'Call with content' do

    let(:params) { {
      :content   => 'configfile content'
    } }

    it { should contain_logstash__configfile('configfile') }
    it { should contain_file_fragment('configfile').with(:content => 'configfile content', :source => nil, :order => '10') }

  end

  context 'call with source' do

    let(:params) { {
      :source   => 'puppet:///path/to/config',
    } }

    it { should contain_logstash__configfile('configfile') }
    it { should contain_file_fragment('configfile').with(:source => 'puppet:///path/to/config', :content => nil, :order => '10') }

  end

  context 'with custom order id' do

    let(:params) { {
      :source => 'puppet:///path/to/config',
      :order  => '100'
    } }

    it { should contain_logstash__configfile('configfile') }
    it { should contain_file_fragment('configfile').with(:source => 'puppet:///path/to/config', :content => nil, :order => '100') }

  end

end

