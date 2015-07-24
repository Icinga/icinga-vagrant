require 'spec_helper'

describe 'selinux::port' do
  let(:title) { 'myapp' }
  include_context 'RedHat 7'

  ['tcp', 'udp', 'tcp6', 'udp6'].each do |protocol|
    context "valid protocol #{protocol}" do
      let(:params) { { :context => 'http_port_t', :port => 8080, :protocol => protocol } }
      it { should contain_exec('add_http_port_t_8080').with(:command => "semanage port -a -t http_port_t -p #{protocol} 8080") }
    end
  end

  context 'invalid protocol' do
    let(:params) { { :context => 'http_port_t', :port => 8080, :protocol => 'bad' } }
    it { expect { is_expected.to compile }.to raise_error }
  end

  context 'no protocol' do
    let(:params) { { :context => 'http_port_t', :port => 8080 } }
    it { should contain_exec('add_http_port_t_8080').with(:command => 'semanage port -a -t http_port_t 8080') }
  end

end
