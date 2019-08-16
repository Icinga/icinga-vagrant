require 'spec_helper'

provider_class = Puppet::Type.type(:grafana_plugin).provider(:grafana_cli)
describe provider_class do
  let(:resource) do
    Puppet::Type::Grafana_plugin.new(
      name: 'grafana-wizzle'
    )
  end
  let(:provider) { provider_class.new(resource) }

  describe '#instances' do
    let(:plugins_ls_two) do
      # rubocop:disable Layout/TrailingWhitespace
      <<-PLUGINS
installed plugins:
grafana-simple-json-datasource @ 1.3.4 
jdbranham-diagram-panel @ 1.4.0 

Restart grafana after installing plugins . <service grafana-server restart>
      PLUGINS
      # rubocop:enable Layout/TrailingWhitespace
    end
    let(:plugins_ls_none) do
      <<-PLUGINS

Restart grafana after installing plugins . <service grafana-server restart>

      PLUGINS
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'has the correct names' do
      allow(provider_class).to receive(:grafana_cli).with('plugins', 'ls').and_return(plugins_ls_two)
      expect(provider_class.instances.map(&:name)).to match_array(['grafana-simple-json-datasource', 'jdbranham-diagram-panel'])
      expect(provider_class).to have_received(:grafana_cli)
    end

    it 'does not match if there are no plugins' do
      allow(provider_class).to receive(:grafana_cli).with('plugins', 'ls').and_return(plugins_ls_none)
      expect(provider_class.instances.size).to eq(0)
      expect(provider.exists?).to eq(false)
      expect(provider_class).to have_received(:grafana_cli)
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  it '#create' do
    allow(provider).to receive(:grafana_cli)
    provider.create
    expect(provider).to have_received(:grafana_cli).with('plugins', 'install', 'grafana-wizzle')
  end

  it '#destroy' do
    allow(provider).to receive(:grafana_cli)
    provider.destroy
    expect(provider).to have_received(:grafana_cli).with('plugins', 'uninstall', 'grafana-wizzle')
  end

  describe 'create with repo' do
    let(:resource) do
      Puppet::Type::Grafana_plugin.new(
        name: 'grafana-plugin',
        repo: 'https://nexus.company.com/grafana/plugins'
      )
    end

    it '#create with repo' do
      allow(provider).to receive(:grafana_cli)
      provider.create
      expect(provider).to have_received(:grafana_cli).with('--repo https://nexus.company.com/grafana/plugins', 'plugins', 'install', 'grafana-plugin')
    end
  end
end
