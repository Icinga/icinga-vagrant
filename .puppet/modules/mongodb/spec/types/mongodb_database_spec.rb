require 'spec_helper'

describe 'mongodb_database' do
  let(:title) { 'test' }

  it do
    is_expected.to be_valid_type.
      with_provider(:mongodb).
      with_properties('ensure').
      with_parameters(%w[name tries])
  end

  it { is_expected.to be_valid_type.with_set_attributes(tries: 5) }
  it { expect { is_expected.to be_valid_type.with_set_attributes(tries: 'a') }.to raise_error(Puppet::Error) }
end
