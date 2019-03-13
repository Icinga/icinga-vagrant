#    Copyright 2015 Mirantis, Inc.
#
Puppet::Type.newtype(:grafana_notification) do
  @doc = 'Manage notification in Grafana'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the notification.'
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
    desc 'The username for the Grafana server'
  end

  newparam(:grafana_password) do
    desc 'The password for the Grafana server'
  end

  newproperty(:type) do
    desc 'The notification type'
  end

  newproperty(:is_default) do
    desc 'Whether the notification is the default one'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:send_reminder) do
    desc 'Whether automatic message resending is enabled or not'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:frequency) do
    desc 'The notification reminder frequency'
  end

  newproperty(:settings) do
    desc 'Additional JSON data to configure the notification'

    validate do |value|
      unless value.nil? || value.is_a?(Hash)
        raise ArgumentError, 'settings should be a Hash!'
      end
    end
  end

  autorequire(:service) do
    'grafana-server'
  end
end
