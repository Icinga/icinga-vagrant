Puppet::Type.newtype(:grafana_plugin) do
  desc <<-DESC
manages grafana plugins

@example Install a grafana plugin
 grafana_plugin { 'grafana-simple-json-datasource': }

@example Install a grafana plugin from different repo
 grafana_plugin { 'grafana-simple-json-datasource':
   ensure => present,
   repo   => 'https://nexus.company.com/grafana/plugins',
 }

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

  newparam(:repo) do
    desc 'The URL of an internal plugin server'

    validate do |value|
      unless value =~ %r{^https?://}
        raise ArgumentError, format('%s is not a valid URL', value)
      end
    end
  end
end
