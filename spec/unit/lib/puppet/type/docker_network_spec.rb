require 'spec_helper'

network = Puppet::Type.type(:docker_network)

describe network do
  let :params do
    [
      :name,
      :provider,
      :subnet,
      :gateway,
      :ip_range,
      :aux_address,
      :options,
      :additional_flags,
    ]
  end

  let :properties do
    [
      :ensure,
      :driver,
      :ipam_driver,
      :id,
    ]
  end

  it 'has expected properties' do
    properties.each do |property|
      expect(network.properties.map(&:name)).to be_include(property)
    end
  end

  it 'has expected parameters' do
    params.each do |param|
      expect(network.parameters).to be_include(param)
    end
  end
end
