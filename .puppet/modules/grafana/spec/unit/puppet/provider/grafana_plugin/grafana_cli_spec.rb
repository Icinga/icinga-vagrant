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
    # rubocop:disable Layout/TrailingWhitespace
    provider_class.expects(:grafana_cli).with('plugins', 'ls').returns <<-EOT
installed plugins:
grafana-simple-json-datasource @ 1.3.4 
jdbranham-diagram-panel @ 1.4.0 

Restart grafana after installing plugins . <service grafana-server restart>

EOT
    # rubocop:enable Layout/TrailingWhitespace
    instances = provider_class.instances
    it 'has the right number of instances' do
      expect(instances.size).to eq(2)
    end

    it 'has the correct names' do
      names = instances.map(&:name)
      expect(names).to include('grafana-simple-json-datasource', 'jdbranham-diagram-panel')
    end

    it 'does not match if there are no plugins' do
      provider_class.expects(:grafana_cli).with('plugins', 'ls').returns <<-EOT

Restart grafana after installing plugins . <service grafana-server restart>

EOT
      instances = provider_class.instances
      expect(provider.exists?).to eq(false)
    end
  end

  it '#create' do
    provider.expects(:grafana_cli).with('plugins', 'install', 'grafana-wizzle')
    provider.create
  end

  it '#destroy' do
    provider.expects(:grafana_cli).with('plugins', 'uninstall', 'grafana-wizzle')
    provider.destroy
  end

  describe 'create with repo' do
    let(:resource) do
      Puppet::Type::Grafana_plugin.new(
        name: 'grafana-plugin',
        repo: 'https://nexus.company.com/grafana/plugins'
      )
    end

    it '#create with repo' do
      provider.expects(:grafana_cli).with('--repo https://nexus.company.com/grafana/plugins', 'plugins', 'install', 'grafana-plugin')
      provider.create
    end
  end
end
