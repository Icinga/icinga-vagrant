require 'spec_helper'
require 'yaml'

# A few helpers to make config handling easier
class String
  def config
    "# File managed by Puppet.\n---\n#{unindent}"
  end

  def unindent
    gsub(/^#{scan(/^\s*/).min_by(&:length)}/, '')
  end
end

describe 'kibana.yml.erb' do
  let :harness do
    h = TemplateHarness.new('templates/etc/kibana/kibana.yml.erb')
    h.set('@config', config)
    h.run
  end

  describe 'normal, sorted hashes' do
    let :config do
      {
        'server.host' => 'localhost',
        'kibana.index' => '.kibana'
      }
    end

    let :yaml do
      <<-CONFIG
        kibana.index: ".kibana"
        server.host: localhost
      CONFIG
    end

    it { expect(harness).to eq(yaml.config) }
  end

  describe 'nested hashes' do
    let :config do
      {
        'tilemap' => {
          'options' => {
            'maxZoom' => 18
          },
          'url' => 'https://test'
        }
      }
    end

    let :yaml do
      <<-CONFIG
        tilemap:
          options:
            maxZoom: 18
          url: https://test
      CONFIG
    end

    it { expect(harness).to eq(yaml.config) }
  end
end
