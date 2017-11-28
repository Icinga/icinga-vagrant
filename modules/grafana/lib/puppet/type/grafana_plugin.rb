Puppet::Type.newtype(:grafana_plugin) do
  desc <<-DESC
manages grafana plugins

@example Install a grafana plugin
 grafana_plugin { 'grafana-simple-json-datasource': }

@example Uninstall a grafana plugin
 grafana_plugin { 'grafana-simple-json-datasource':
   ensure => absent,
 }

@example Show resources
 $ puppet resource grafana_plugin
DESC

  ensurable do
    defaultto(:present)
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, namevar: true) do
    desc 'The name of the plugin to enable'
    newvalues(%r{^\S+$})
  end
end
