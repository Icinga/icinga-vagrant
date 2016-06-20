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
  let(:gdashboard) {
    described_class.new :name => "foo", :grafana_url => "http://example.com/", :content => "{}", :ensure => :present
  }
  context "when setting parameters" do

    it "should fail if grafana_url isn't HTTP-based" do
      expect {
        described_class.new :name => "foo", :grafana_url => "example.com", :content => "{}", :ensure => :present
      }.to raise_error(Puppet::Error, /not a valid URL/)
    end

    it "should fail if content isn't provided" do
      expect {
        described_class.new :name => "foo", :grafana_url => "http://example.com", :ensure => :present
      }.to raise_error(Puppet::Error, /content is required/)
    end

    it "should fail if content isn't JSON" do
      expect {
        described_class.new :name => "foo", :grafana_url => "http://example.com/", :content => "{invalid", :ensure => :present
      }.to raise_error(Puppet::Error, /Invalid JSON/)
    end

    it "should accept valid parameters" do
      expect(gdashboard[:name]).to eq('foo')
      expect(gdashboard[:grafana_url]).to eq('http://example.com/')
      expect(gdashboard[:content]).to eq({})
    end
    it "should autorequire the grafana-server for proper ordering" do
      catalog = Puppet::Resource::Catalog.new
      service = Puppet::Type.type(:service).new(:name => "grafana-server")
      catalog.add_resource service
      catalog.add_resource gdashboard

      relationship = gdashboard.autorequire.find do |rel|
        (rel.source.to_s == "Service[grafana-server]") and (rel.target.to_s == gdashboard.to_s)
      end
      expect(relationship).to be_a Puppet::Relationship
    end
    it "should not autorequire the service it is not managed" do
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource gdashboard
      expect(gdashboard.autorequire).to be_empty
    end
  end
end
