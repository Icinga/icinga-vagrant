require 'spec_helper'

compose = Puppet::Type.type(:docker_compose)

describe compose do
  let :params do
    [
      :name,
      :provider,
      :scale,
      :options,
      :up_args,
    ]
  end

  let :properties do
    [
      :ensure,
    ]
  end

  it 'has expected properties' do
    properties.each do |property|
      expect(compose.properties.map(&:name)).to be_include(property)
    end
  end

  it 'has expected parameters' do
    params.each do |param|
      expect(compose.parameters).to be_include(param)
    end
  end

  it 'requires options to be a string' do
    expect(compose).to require_string_for('options')
  end

  it 'requires up_args to be a string' do
    expect(compose).to require_string_for('up_args')
  end

  it 'requires scale to be a hash' do
    expect(compose).to require_hash_for('scale')
  end
end
