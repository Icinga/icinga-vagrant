# Copyright 2015 Mirantis, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'spec_helper'

describe Puppet::Type.type(:grafana_dashboard) do
  let(:gdashboard) do
    described_class.new name: 'foo', grafana_url: 'http://example.com/', content: '{}', ensure: :present
  end

  context 'when setting parameters' do
    it "fails if grafana_url isn't HTTP-based" do
      expect do
        described_class.new name: 'foo', grafana_url: 'example.com', content: '{}', ensure: :present
      end.to raise_error(Puppet::Error, %r{not a valid URL})
    end

    it "fails if content isn't provided" do
      expect do
        described_class.new name: 'foo', grafana_url: 'http://example.com', ensure: :present
      end.to raise_error(Puppet::Error, %r{content is required})
    end

    it "fails if content isn't JSON" do
      expect do
        described_class.new name: 'foo', grafana_url: 'http://example.com/', content: '{invalid', ensure: :present
      end.to raise_error(Puppet::Error, %r{Invalid JSON})
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'accepts valid parameters' do
      expect(gdashboard[:name]).to eq('foo')
      expect(gdashboard[:grafana_url]).to eq('http://example.com/')
      expect(gdashboard[:content]).to eq({})
    end
    it 'autorequires the grafana-server for proper ordering' do
      catalog = Puppet::Resource::Catalog.new
      service = Puppet::Type.type(:service).new(name: 'grafana-server')
      catalog.add_resource service
      catalog.add_resource gdashboard

      relationship = gdashboard.autorequire.find do |rel|
        (rel.source.to_s == 'Service[grafana-server]') && (rel.target.to_s == gdashboard.to_s)
      end
      expect(relationship).to be_a Puppet::Relationship
    end
    it 'does not autorequire the service it is not managed' do
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource gdashboard
      expect(gdashboard.autorequire).to be_empty
    end
  end
end
