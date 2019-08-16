Puppet::Type.newtype(:mongodb_database) do
  @doc = 'Manage MongoDB databases.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the database.'
    newvalues(%r{^[\w-]+$})
  end

  newparam(:tries) do
    desc 'The maximum amount of two second tries to wait MongoDB startup.'
    defaultto 10
    newvalues(%r{^\d+$})
    munge do |value|
      Integer(value)
    end
  end

  autorequire(:package) do
    'mongodb_client'
  end

  autorequire(:service) do
    %w[mongodb mongod]
  end
end
