require 'json'

Puppet::Type.newtype(:grafana_folder) do
  @doc = 'Manage folders in Grafana'

  ensurable

  newparam(:title, namevar: true) do
    desc 'The title of the folder'
  end

  newparam(:uid) do
    desc 'UID of the folder'
  end

  newparam(:grafana_url) do
    desc 'The URL of the Grafana server'
    defaultto ''

    validate do |value|
      unless value =~ %r{^https?://}
        raise ArgumentError, format('%s is not a valid URL', value)
      end
    end
  end

  newparam(:grafana_user) do
    desc 'The username for the Grafana server (optional)'
  end

  newparam(:grafana_password) do
    desc 'The password for the Grafana server (optional)'
  end

  newparam(:grafana_api_path) do
    desc 'The absolute path to the API endpoint'
    defaultto '/api'

    validate do |value|
      unless value =~ %r{^/.*/?api$}
        raise ArgumentError, format('%s is not a valid API path', value)
      end
    end
  end

  newparam(:organization) do
    desc 'The organization name to create the datasource on'
    defaultto 1
  end

  autorequire(:service) do
    'grafana-server'
  end
end
