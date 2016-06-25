require 'spec_helper'

describe 'logstash::patternfile', :type => 'define' do

  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux'
  } end
  
  let(:title) { 'foopatterns' }

  let(:pre_condition) { 'class {"logstash": }'}

  context 'Default call' do

    let(:params) { {
      :source   => 'puppet:///mypatterns'
    } }

    it { should contain_logstash__patternfile('foopatterns') }
    it { should contain_file('/etc/logstash/patterns/mypatterns').with( :source => 'puppet:///mypatterns') }

  end

  context 'using file:// schema' do

    let(:params) { {
      :source   => 'file:///mypatterns',
    } }

    it { should contain_logstash__patternfile('foopatterns') }
    it { should contain_file('/etc/logstash/patterns/mypatterns').with( :source => 'file:///mypatterns') }

  end

  context 'set filename' do

    let(:params) { {
      :source   => 'puppet:///mypatterns',
      :filename => 'pattern123'
    } }

    it { should contain_logstash__patternfile('foopatterns') }
    it { should contain_file('/etc/logstash/patterns/pattern123')}

  end

  context 'with bad source' do

    let(:params) { {
      :source   => 'http://mypatterns',
    } }

    it { expect { should raise_error(Puppet::Error) } }

  end

end

