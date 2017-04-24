require 'spec_helper'

describe 'selinux::port' do
  let(:title) { 'myapp' }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      %w(tcp udp tcp6 udp6).each do |protocol|
        context "valid protocol #{protocol}" do
          let(:params) do
            {
              context: 'http_port_t',
              port: 8080,
              protocol: protocol
            }
          end
          it { is_expected.to contain_exec("add_http_port_t_8080_#{protocol}").with(command: "semanage port -a -t http_port_t -p #{protocol} 8080") }
        end
        context "protocol #{protocol} and port as range" do
          let(:params) do
            {
              context: 'http_port_t',
              port: '8080-8089',
              protocol: protocol
            }
          end
          it { is_expected.to contain_exec("add_http_port_t_8080-8089_#{protocol}").with(command: "semanage port -a -t http_port_t -p #{protocol} 8080-8089") }
        end
      end

      context 'invalid protocol' do
        let(:params) do
          {
            context: 'http_port_t',
            port: 8080,
            protocol: 'bad'
          }
        end
        it { expect { is_expected.to compile }.to raise_error(%r{error during compilation}) }
      end

      context 'no protocol' do
        let(:params) do
          {
            context: 'http_port_t',
            port: 8080
          }
        end
        it { is_expected.to contain_exec('add_http_port_t_8080').with(command: 'semanage port -a -t http_port_t 8080') }
      end
    end
  end
end
