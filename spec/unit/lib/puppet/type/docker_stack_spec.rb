require 'spec_helper'

stack = Puppet::Type.type(:docker_stack)

describe stack do
  let :params do
    [
      :name,
      :provider,
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
      expect(stack.properties.map(&:name)).to be_include(property)
    end
  end

  it 'has expected parameters' do
    params.each do |param|
      expect(stack.parameters).to be_include(param)
    end
  end

  it 'requires up_args to be a string' do
    expect(stack).to require_string_for('up_args')
  end
end
