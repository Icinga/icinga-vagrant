require 'spec_helper'

describe Puppet::Type.type(:grafana_organization) do
  let(:gorganization) do
    described_class.new(
      name: 'foo',
      grafana_url: 'http://example.com',
      grafana_user: 'admin',
      grafana_password: 'admin',
      address: { address1: 'test address1', address2: 'test address2', city: 'CityName', state: 'NewState', zipcode: '12345', country: 'USA' }
    )
  end

  context 'when setting parameters' do
    it "fails if json_data isn't valid" do
      expect do
        described_class.new name: 'foo', address: 'invalid address'
      end.to raise_error(Puppet::Error, %r{address should be a Hash!})
    end

    it "fails if grafana_url isn't HTTP-based" do
      expect do
        described_class.new name: 'foo', grafana_url: 'example.com', content: '{}', ensure: :present
      end.to raise_error(Puppet::Error, %r{not a valid URL})
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'accepts valid parameters' do
      expect(gorganization[:name]).to eq('foo')
      expect(gorganization[:grafana_user]).to eq('admin')
      expect(gorganization[:grafana_password]).to eq('admin')
      expect(gorganization[:grafana_url]).to eq('http://example.com')
      expect(gorganization[:address]).to eq(address1: 'test address1', address2: 'test address2', city: 'CityName', state: 'NewState', zipcode: '12345', country: 'USA')
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'autorequires the grafana-server for proper ordering' do
      catalog = Puppet::Resource::Catalog.new
      service = Puppet::Type.type(:service).new(name: 'grafana-server')
      catalog.add_resource service
      catalog.add_resource gorganization

      relationship = gorganization.autorequire.find do |rel|
        (rel.source.to_s == 'Service[grafana-server]') && (rel.target.to_s == gorganization.to_s)
      end
      expect(relationship).to be_a Puppet::Relationship
    end

    it 'does not autorequire the service it is not managed' do
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource gorganization
      expect(gorganization.autorequire).to be_empty
    end
  end
end
