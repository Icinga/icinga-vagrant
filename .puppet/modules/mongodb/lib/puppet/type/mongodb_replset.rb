#
# Author: Francois Charlier <francois.charlier@enovance.com>
#

Puppet::Type.newtype(:mongodb_replset) do
  @doc = 'Manage a MongoDB replicaSet'

  ensurable do
    defaultto :present

    newvalue(:present) do
      provider.create
    end
  end

  newparam(:name) do
    desc 'The name of the replicaSet'
  end

  newparam(:arbiter) do
    desc 'The replicaSet arbiter'
  end

  newparam(:initialize_host) do
    desc 'Host to use for Replicaset initialization'
    defaultto '127.0.0.1'
  end

  newproperty(:settings) do
    desc 'The replicaSet settings config'

    def insync?(is)
      should.each do |k, v|
        if v != is[k]
          Puppet.debug 'The replicaset settings config is not insync'
          return false
        end
      end
      Puppet.debug 'The replicaset settings config is insync'
      true
    end
  end

  newproperty(:members, array_matching: :all) do
    desc 'The replicaSet members config'

    munge do |value|
      value.is_a?(String) ? { 'host' => value } : value
    end

    # check if is different
    def insync?(is)
      sync = true
      current = is.clone
      should.each do |sm|
        next unless current.each_with_index do |cm, index|
          next unless sm['host'] == cm['host']
          sm.each do |k, v|
            if v != cm[k]
              # new config for existing node so not insync
              sync = false
            end
          end
          # node is found, no need to remove it from cluster
          current.delete_at(index)
          break
        end
        # new node for cluster so not insync
        sync = false
      end
      # check if some nodes are needed for deletion
      sync = false unless current.empty?
      if sync
        Puppet.debug 'The replicaset members config is insync'
        return true
      end
      Puppet.debug 'The replicaset members config is not insync'
      false
    end
  end

  autorequire(:package) do
    'mongodb_client'
  end

  autorequire(:service) do
    %w[mongodb mongod]
  end
end
