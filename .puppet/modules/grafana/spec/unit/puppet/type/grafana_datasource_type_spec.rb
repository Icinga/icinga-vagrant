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

describe Puppet::Type.type(:grafana_datasource) do
  let(:gdatasource) do
    described_class.new(
      name: 'foo',
      grafana_url: 'http://example.com',
      url: 'http://es.example.com',
      type: 'elasticsearch',
      organization: 'test_org',
      access_mode: 'proxy',
      is_default: true,
      basic_auth: true,
      basic_auth_user: 'user',
      basic_auth_password: 'password',
      with_credentials: true,
      database: 'test_db',
      user: 'db_user',
      password: 'db_password',
      json_data: { esVersion: 5, timeField: '@timestamp', timeInterval: '1m' },
      secure_json_data: { password: '5ecretPassw0rd' }
    )
  end

  context 'when setting parameters' do
    it "fails if grafana_url isn't HTTP-based" do
      expect do
        described_class.new name: 'foo', grafana_url: 'example.com', content: '{}', ensure: :present
      end.to raise_error(Puppet::Error, %r{not a valid URL})
    end

    it "fails if json_data isn't valid" do
      expect do
        described_class.new name: 'foo', grafana_url: 'http://example.com', json_data: 'invalid', ensure: :present
      end.to raise_error(Puppet::Error, %r{json_data should be a Hash})
    end

    it "fails if secure_json_data isn't valid" do
      expect do
        described_class.new name: 'foo', grafana_url: 'http://example.com', secure_json_data: 'invalid', ensure: :present
      end.to raise_error(Puppet::Error, %r{json_data should be a Hash})
    end
    # rubocop:disable RSpec/MultipleExpectations
    it 'accepts valid parameters' do
      expect(gdatasource[:name]).to eq('foo')
      expect(gdatasource[:grafana_url]).to eq('http://example.com')
      expect(gdatasource[:url]).to eq('http://es.example.com')
      expect(gdatasource[:type]).to eq('elasticsearch')
      expect(gdatasource[:organization]).to eq('test_org')
      expect(gdatasource[:access_mode]).to eq(:proxy)
      expect(gdatasource[:is_default]).to eq(:true)
      expect(gdatasource[:basic_auth]).to eq(:true)
      expect(gdatasource[:basic_auth_user]).to eq('user')
      expect(gdatasource[:basic_auth_password]).to eq('password')
      expect(gdatasource[:with_credentials]).to eq(:true)
      expect(gdatasource[:database]).to eq('test_db')
      expect(gdatasource[:user]).to eq('db_user')
      expect(gdatasource[:password]).to eq('db_password')
      expect(gdatasource[:json_data]).to eq(esVersion: 5, timeField: '@timestamp', timeInterval: '1m')
      expect(gdatasource[:secure_json_data]).to eq(password: '5ecretPassw0rd')
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'autorequires the grafana-server for proper ordering' do
      catalog = Puppet::Resource::Catalog.new
      service = Puppet::Type.type(:service).new(name: 'grafana-server')
      catalog.add_resource service
      catalog.add_resource gdatasource

      relationship = gdatasource.autorequire.find do |rel|
        (rel.source.to_s == 'Service[grafana-server]') && (rel.target.to_s == gdatasource.to_s)
      end
      expect(relationship).to be_a Puppet::Relationship
    end

    it 'does not autorequire the service it is not managed' do
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource gdatasource
      expect(gdatasource.autorequire).to be_empty
    end
  end
end
