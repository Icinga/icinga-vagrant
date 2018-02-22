require 'spec_helper'

semanage_provider = Puppet::Type.type(:selinux_permissive).provider(:semanage)
permissive = Puppet::Type.type(:selinux_permissive)

describe semanage_provider do
  let(:semanage_output) do
    <<-EOS

    Customized Permissive Types


    Builtin Permissive Types

    tlp_t
    EOS
  end
  let(:semanage_output_custom) do
    <<-EOS

    Customized Permissive Types

    test_t
    Builtin Permissive Types

    tlp_t
    EOS
  end

  on_supported_os.each do |_os, _facts|
    let(:resource) do
      permissive.new(seltype: 'test_t',
                     ensure: :present)
    end
    let(:provider) do
      resource.provider = described_class.new
    end

    context 'semanage list' do
      context 'without custom types' do
        before do
          described_class.expects(:semanage).with('permissive', '--list').returns(semanage_output)
        end
        it 'returns one resource' do
          expect(described_class.instances.size).to eq(1)
        end
        it 'has a name tlp_t and ensure present' do
          expect(described_class.instances[0].instance_variable_get('@property_hash')).to eq(
            name: 'tlp_t',
            seltype: 'tlp_t',
            ensure: :present,
            local: false
          )
        end
      end
      context 'With a custom type' do
        before do
          described_class.expects(:semanage).with('permissive', '--list').returns(semanage_output_custom)
        end
        it 'returns two resources' do
          expect(described_class.instances.size).to eq(2)
        end
      end
    end
    context 'Creating' do
      it 'runs semanage permissive -a' do
        described_class.expects(:semanage).with('permissive', '-a', 'test_t')
        provider.create
      end
    end
    context 'Deleting' do
      it 'runs semanage permissive -d' do
        described_class.expects(:semanage).with('permissive', '-d', 'test_t')
        provider.destroy
      end
    end
    context 'Prefetch' do
      before do
        described_class.expects(:semanage).with('permissive', '--list').returns(semanage_output_custom)
      end
      it 'matches the provider' do
        semanage_provider.prefetch('test_t' => resource, 'tlp_t' => permissive.new(seltype: 'tlp_t', ensure: :present))
        expect(resource.provider.exists?).to eq(true)
      end
    end
    context 'Prefetch when purging' do
      let(:built_in) do
        b = permissive.new(seltype: 'tlp_t')
        b.purging
        b
      end
      let(:custom) do
        permissive.new(seltype: 'test_t')
      end

      it 'forces built-ins to be present' do
        described_class.expects(:semanage).with('permissive', '--list').returns(semanage_output_custom)
        semanage_provider.prefetch('test_t' => custom, 'tlp_t' => built_in)
        expect(built_in[:ensure]).to eq(:present)
      end
    end
  end
end
