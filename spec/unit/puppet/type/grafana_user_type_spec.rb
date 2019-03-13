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

describe Puppet::Type.type(:grafana_user) do
  let(:guser) do
    described_class.new name: 'test', full_name: 'Mr tester', password: 't3st', grafana_url: 'http://example.com/'
  end

  context 'when setting parameters' do
    it "fails if grafana_url isn't HTTP-based" do
      expect do
        described_class.new name: 'test', grafana_url: 'example.com'
      end.to raise_error(Puppet::Error, %r{not a valid URL})
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'accepts valid parameters' do
      expect(guser[:name]).to eq('test')
      expect(guser[:full_name]).to eq('Mr tester')
      expect(guser[:password]).to eq('t3st')
      expect(guser[:grafana_url]).to eq('http://example.com/')
    end
    it 'autorequires the grafana-server for proper ordering' do
      catalog = Puppet::Resource::Catalog.new
      service = Puppet::Type.type(:service).new(name: 'grafana-server')
      catalog.add_resource service
      catalog.add_resource guser

      relationship = guser.autorequire.find do |rel|
        (rel.source.to_s == 'Service[grafana-server]') && (rel.target.to_s == guser.to_s)
      end
      expect(relationship).to be_a Puppet::Relationship
    end
    it 'does not autorequire the service it is not managed' do
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource guser
      expect(guser.autorequire).to be_empty
    end
  end
end
