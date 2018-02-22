require 'spec_helper'
describe 'graylog' do

  context 'with default values for all parameters' do
    it { should contain_class('graylog') }
  end
end
