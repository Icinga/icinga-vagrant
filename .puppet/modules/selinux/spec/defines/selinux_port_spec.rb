require 'spec_helper'

describe 'selinux::port' do
  let(:title) { 'myapp' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'ordering' do
        let(:params) do
          {
            seltype: 'http_port_t',
            port: 8080,
            protocol: 'tcp'
          }
        end

        it { is_expected.to contain_selinux__port('myapp').that_requires('Anchor[selinux::module post]') }
        it { is_expected.to contain_selinux__port('myapp').that_comes_before('Anchor[selinux::end]') }
      end

      %w[tcp udp].each do |protocol|
        context "valid protocol #{protocol}" do
          let(:params) do
            {
              seltype: 'http_port_t',
              port: 8080,
              protocol: protocol
            }
          end

          it { is_expected.to contain_selinux_port("#{protocol}_8080-8080").with(seltype: 'http_port_t') }
        end
        context "protocol #{protocol} and port_range" do
          let(:params) do
            {
              seltype: 'http_port_t',
              port_range: [8080, 8089],
              protocol: protocol
            }
          end

          it { is_expected.to contain_selinux_port("#{protocol}_8080-8089").with(seltype: 'http_port_t') }
        end
      end

      context 'invalid protocol' do
        let(:params) do
          {
            seltype: 'http_port_t',
            port: 8080,
            protocol: 'bad'
          }
        end

        it { expect { is_expected.to compile }.to raise_error(%r{error during compilation}) }
      end

      context 'both port and port_range' do
        let(:params) do
          {
            seltype: 'http_port_t',
            port: 8080,
            port_range: [8080, 8081],
            protocol: 'tcp'
          }
        end

        it { expect { is_expected.to compile }.to raise_error(%r{error during compilation}) }
      end

      context 'no protocol' do
        let(:params) do
          {
            seltype: 'http_port_t',
            port: 8080
          }
        end

        it { expect { is_expected.to compile }.to raise_error(%r{error during compilation}) }
      end
    end
  end
end
