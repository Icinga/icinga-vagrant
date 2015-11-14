require 'spec_helper'

describe 'grafana' do

  describe "contains classes" do
    it { should contain_anchor('grafana::begin') }
    it { should contain_class('grafana::install') }
    it { should contain_class('grafana::config') }
    it { should contain_anchor('grafana::end') }
  end

end
