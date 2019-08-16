require 'spec_helper'

# This is a reduced version of ruby_spec.rb just to ensure we can subclass as
# documented
$LOAD_PATH << './spec/fixtures/inherit_ini_setting/lib'

describe Puppet::Type.type(:inherit_ini_setting).provider(:ini_setting) do
  include PuppetlabsSpec::Files

  let(:tmpfile) { tmpfilename('inherit_ini_setting_test') }

  def validate_file(expected_content, tmpfile)
    expect(File.read(tmpfile)).to eq(expected_content)
  end

  before :each do
    File.open(tmpfile, 'w') do |fh|
      fh.write(orig_content)
    end
  end

  context 'when calling instances' do
    let(:orig_content) { '' }

    it 'parses nothing when the file is empty' do
      allow(described_class).to receive(:file_path).and_return(tmpfile)
      expect(described_class.instances).to eq([])
    end

    context 'when the file has contents' do
      let(:orig_content) do
        <<-EOS
          # A comment
          red = blue
          green = purple
        EOS
      end

      it 'parses the results' do
        allow(described_class).to receive(:file_path).and_return(tmpfile)
        instances = described_class.instances
        expect(instances.size).to eq(2)
        # inherited version of namevar flattens the names
        names = instances.map do |instance| instance.instance_variable_get(:@property_hash)[:name] end # rubocop:disable Style/BlockDelimiters
        expect(names.sort).to eq(['green', 'red'])
      end
    end
  end

  context 'when ensuring that a setting is present' do
    let(:orig_content) { '' }

    it 'adds a value to the file' do
      allow(described_class).to receive(:file_path).and_return(tmpfile)
      resource = Puppet::Type::Inherit_ini_setting.new(setting: 'set_this', value: 'to_that')
      provider = described_class.new(resource)
      provider.create
      validate_file("set_this=to_that\n", tmpfile)
    end
  end
end
