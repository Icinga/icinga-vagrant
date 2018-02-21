require 'spec_helper'

semanage_provider = Puppet::Type.type(:selinux_port).provider(:semanage)
port = Puppet::Type.type(:selinux_port)

# 23 lines:
ports_helper_output = <<-EOS
policy system_u:object_r:ipp_port_t:s0 8614 8610 tcp
policy system_u:object_r:ipp_port_t:s0 8614 8610 udp
policy system_u:object_r:pki_ca_port_t:s0 9447 9443 tcp
policy system_u:object_r:gluster_port_t:s0 38469 38465 tcp
policy system_u:object_r:http_cache_port_t:s0 10010 10001 tcp
policy system_u:object_r:traceroute_port_t:s0 64010 64000 udp
policy system_u:object_r:vnc_port_t:s0 5999 5985 tcp
policy system_u:object_r:cyphesis_port_t:s0 6799 6780 tcp
policy system_u:object_r:xserver_port_t:s0 6020 6000 tcp
policy system_u:object_r:gluster_port_t:s0 24027 24007 tcp
policy system_u:object_r:mysqld_port_t:s0 63164 63132 tcp
policy system_u:object_r:virt_migration_port_t:s0 49216 49152 tcp
policy system_u:object_r:vnc_port_t:s0 5983 5900 tcp
policy system_u:object_r:unreserved_port_t:s0 65535 61001 tcp
policy system_u:object_r:unreserved_port_t:s0 65535 61001 udp
policy system_u:object_r:ephemeral_port_t:s0 61000 32768 tcp
policy system_u:object_r:ephemeral_port_t:s0 61000 32768 udp
policy system_u:object_r:unreserved_port_t:s0 32767 1024 tcp
policy system_u:object_r:unreserved_port_t:s0 32767 1024 udp
local system_u:object_r:zope_port_t:s0 12345 12345 tcp
local system_u:object_r:zope_port_t:s0 12345 12345 udp
local system_u:object_r:zookeeper_client_port_t:s0 15132 15123 udp
local system_u:object_r:zookeeper_client_port_t:s0 15132 15123 tcp
EOS

# END 23 instances

instance_examples = {
  0 => {
    ensure: :present,
    name: 'tcp_8610-8614',
    protocol: :tcp,
    seltype: 'ipp_port_t',
    high_port: '8614',
    low_port: '8610',
    source: :policy
  },
  1 => {
    ensure: :present,
    name: 'udp_8610-8614',
    protocol: :udp,
    seltype: 'ipp_port_t',
    high_port: '8614',
    low_port: '8610',
    source: :policy
  },
  20 => {
    ensure: :present,
    name: 'udp_12345-12345',
    protocol: :udp,
    seltype: 'zope_port_t',
    high_port: '12345',
    low_port: '12345',
    source: :local
  },
  21 => {
    ensure: :present,
    name: 'udp_15123-15132',
    protocol: :udp,
    seltype: 'zookeeper_client_port_t',
    high_port: '15132',
    low_port: '15123',
    source: :local
  },
  22 => {
    ensure: :present,
    name: 'tcp_15123-15132',
    protocol: :tcp,
    seltype: 'zookeeper_client_port_t',
    high_port: '15132',
    low_port: '15123',
    source: :local
  }
}

# remove the source key as it's supposed to error out
resource_example = instance_examples[22].clone
resource_example.delete(:source)

describe semanage_provider do
  on_supported_os.each do |os, _facts|
    context "on #{os}" do
      context 'with some local port definitions' do
        before do
          # Call to python helper script
          semanage_provider.expects(:python).returns(ports_helper_output)
        end
        it 'returns 23 resources' do
          expect(described_class.instances.size).to eq(23)
        end
        instance_examples.each do |index, hash|
          it "parses example #{index} correctly" do
            expect(described_class.instances[index].instance_variable_get('@property_hash')).to eq(hash)
          end
        end
      end
      context 'creating' do
        let(:resource) do
          res = port.new(resource_example)
          res.provider = semanage_provider.new
          res
        end

        it 'runs semanage port -a for a port range' do
          described_class.expects(:semanage).with('port', '-a', '-t', 'zookeeper_client_port_t', '-p', :tcp, '15123-15132')
          resource.provider.create
        end
        it 'runs semanage port -a for a single port' do
          resource[:high_port] = resource[:low_port]
          described_class.expects(:semanage).with('port', '-a', '-t', 'zookeeper_client_port_t', '-p', :tcp, '15123')
          resource.provider.create
        end
      end
      context 'deleting' do
        let(:res_port_range) do
          res = port.new(resource_example)
          res.provider = semanage_provider.new(resource_example)
          res
        end
        let(:res_single_port) do
          ex = resource_example.clone
          ex[:high_port] = ex[:low_port]
          res = port.new(ex)
          res.provider = semanage_provider.new(ex)
          res
        end

        it 'runs semanage port -d for a port range' do
          described_class.expects(:semanage).with('port', '-d', '-p', :tcp, '15123-15132')
          res_port_range.provider.destroy
        end
        it 'runs semanage port -d for a single port' do
          described_class.expects(:semanage).with('port', '-d', '-p', :tcp, '15123')
          res_single_port.provider.destroy
        end
      end
      context 'with resources differing from the catalog' do
        let(:resources) do
          {
            'tcp_54321-54321' => port.new(
              name: 'tcp_54321-54321',
              protocol: :tcp,
              seltype: 'ipp_port_t',
              high_port: '54321',
              low_port: '54321'
            ),
            'tcp_15123-15132' => port.new(resource_example)
          }
        end

        before do
          # prefetch:
          semanage_provider.expects(:python).returns(ports_helper_output)
          semanage_provider.prefetch(resources)
        end
        context 'prefetch finds the provider for tcp_15123-15132 (resource example)' do
          let(:p) { resources['tcp_15123-15132'].provider }

          it { expect(p.name).to eq('tcp_15123-15132') }
          it { expect(p.protocol).to eq(:tcp) }
          it { expect(p.seltype).to eq('zookeeper_client_port_t') }
          it { expect(p.high_port).to eq('15132') }
          it { expect(p.low_port).to eq('15123') }
        end
      end
    end
  end
end
