require 'spec_helper'

describe Puppet::Type.type(:kibana_plugin) do
  let(:resource_name) { 'x-pack' }

  describe 'input validation' do
    it 'should default to being installed' do
      plugin = described_class.new(:name => resource_name)
      expect(plugin.should(:ensure)).to eq(:present)
    end

    describe 'when validating attributes' do
      it 'should have an organization parameter' do
        expect(described_class.attrtype(:organization)).to eq(:param)
      end

      it 'should have a url parameter' do
        expect(described_class.attrtype(:url)).to eq(:param)
      end

      it 'should have an ensure property' do
        expect(described_class.attrtype(:ensure)).to eq(:property)
      end

      it 'should have a version property' do
        expect(described_class.attrtype(:version)).to eq(:property)
      end
    end

    describe 'validate' do
      it 'should require version when organization is set' do
        expect { described_class.new(:name => 'marvel', :organization => 'elasticsearch') }
          .to raise_error(Puppet::Error, /version must be set if organization is set/)
      end

      it 'should not require version when organization is set when ensure is absent' do
        expect do
          described_class.new(
            :name => 'marvel',
            :ensure => 'absent',
            :organization => 'elasticsearch'
          )
        end.not_to raise_error
      end
    end
  end

  describe 'autorequire' do
    before :each do
      @kibana_pkg = Puppet::Type.type(:package).new(:name => 'kibana', :ensure => :present)
      @catalog = Puppet::Resource::Catalog.new
      @catalog.add_resource @kibana_pkg
    end

    it 'should autorequire the kibana package' do
      @resource = described_class.new(:name => 'x-pack')
      @catalog.add_resource @resource
      req = @resource.autorequire
      expect(req.size).to eq(1)
      expect(req[0].target).to eq(@resource)
      expect(req[0].source).to eq(@kibana_pkg)
    end
  end
end
