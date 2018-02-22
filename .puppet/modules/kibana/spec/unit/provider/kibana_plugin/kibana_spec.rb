require 'spec_helper'
require 'helpers/unit/provider/kibana_plugin_shared_examples'

describe Puppet::Type.type(:kibana_plugin).provider(:kibana) do
  let(:executable)   { home_path + '/bin/kibana' }
  let(:home_path)    { '/opt/kibana' }
  let(:install_args) { ['plugin', '--install'] }
  let(:plugin_path)  { home_path + '/installedPlugins' }
  let(:provider)     { described_class.new(:name => plugin_one[:name]) }
  let(:remove_args)  { ['plugin', '--remove'] }

  let(:plugin_one) do
    {
      :name => 'marvel',
      :version => '2.4.4'
    }
  end

  let(:plugin_two) do
    {
      :name => 'graph',
      :version => '2.4.1'
    }
  end

  let(:resource) do
    Puppet::Type.type(:kibana_plugin).new(
      :name         => plugin_one[:name],
      :organization => 'elasticsearch',
      :provider     => provider,
      :version      => '2.4.4'
    )
  end

  include_examples 'kibana plugin provider'

  describe 'url' do
    it 'causes --url to be passed to install' do
      url = 'https://some.sample.url/directory'
      expect(provider).to(
        receive(:execute)
          .with(
            [executable] + install_args + [resource[:name], '--url', url],
            :uid => 'kibana', :gid => 'kibana'
          )
          .and_return(
            Puppet::Util::Execution::ProcessOutput.new('success', 0)
          )
      )
      resource[:url] = url
      provider.create
      provider.flush
    end
  end
end
