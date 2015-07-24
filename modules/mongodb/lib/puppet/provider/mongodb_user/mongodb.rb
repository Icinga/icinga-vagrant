require File.expand_path(File.join(File.dirname(__FILE__), '..', 'mongodb'))
Puppet::Type.type(:mongodb_user).provide(:mongodb, :parent => Puppet::Provider::Mongodb) do

  desc "Manage users for a MongoDB database."

  defaultfor :kernel => 'Linux'

  def self.instances
    require 'json'

    if mongo_24?
      dbs = JSON.parse mongo_eval('printjson(db.getMongo().getDBs()["databases"].map(function(db){return db["name"]}))') || 'admin'

      allusers = []

      dbs.each do |db|
        users = JSON.parse mongo_eval('printjson(db.system.users.find().toArray())', db)

        allusers += users.collect do |user|
            new(:name          => user['_id'],
                :ensure        => :present,
                :username      => user['user'],
                :database      => db,
                :roles         => user['roles'].sort,
                :password_hash => user['pwd'])
        end
      end
      return allusers
    else
      users = JSON.parse mongo_eval('printjson(db.system.users.find().toArray())')

      users.collect do |user|
          new(:name          => user['_id'],
              :ensure        => :present,
              :username      => user['user'],
              :database      => user['db'],
              :roles         => from_roles(user['roles'], user['db']),
              :password_hash => user['credentials']['MONGODB-CR'])
      end
    end
  end

  # Assign prefetched users based on username and database, not on id and name
  def self.prefetch(resources)
    users = instances
    resources.each do |name, resource|
      if provider = users.find { |user| user.username == resource[:username] and user.database == resource[:database] }
        resources[name].provider = provider
      end
    end
  end

  mk_resource_methods

  def create


    if mongo_24?
      user = {
        :user => @resource[:username],
        :pwd => @resource[:password_hash],
        :roles => @resource[:roles]
      }

      mongo_eval("db.addUser(#{user.to_json})", @resource[:database])
    else
      cmd_json=<<-EOS.gsub(/^\s*/, '').gsub(/$\n/, '')
      {
        "createUser": "#{@resource[:username]}",
        "pwd": "#{@resource[:password_hash]}",
        "customData": {"createdBy": "Puppet Mongodb_user['#{@resource[:name]}']"},
        "roles": #{@resource[:roles].to_json},
        "digestPassword": false
      }
      EOS

      mongo_eval("db.runCommand(#{cmd_json})", @resource[:database])
    end

    @property_hash[:ensure] = :present
    @property_hash[:username] = @resource[:username]
    @property_hash[:database] = @resource[:database]
    @property_hash[:password_hash] = ''
    @property_hash[:rolse] = @resource[:roles]

    exists? ? (return true) : (return false)
  end


  def destroy
    if mongo_24?
      mongo_eval("db.removeUser('#{@resource[:username]}')")
    else
      mongo_eval("db.dropUser('#{@resource[:username]}')")
    end
  end

  def exists?
    !(@property_hash[:ensure] == :absent or @property_hash[:ensure].nil?)
  end

  def password_hash=(value)
    cmd_json=<<-EOS.gsub(/^\s*/, '').gsub(/$\n/, '')
    {
        "updateUser": "#{@resource[:username]}",
        "pwd": "#{@resource[:password_hash]}",
        "digestPassword": false
    }
    EOS

    mongo_eval("db.runCommand(#{cmd_json})", @resource[:database])
  end

  def roles=(roles)
    if mongo_24?
      mongo_eval("db.system.users.update({user:'#{@resource[:username]}'}, { $set: {roles: #{@resource[:roles].to_json}}})")
    else
      grant = roles-@resource[:roles]
      if grant.length > 0
        mongo_eval("db.getSiblingDB('#{@resource[:database]}').grantRolesToUser('#{@resource[:username]}', #{grant. to_json})")
      end

      revoke = @resource[:roles]-roles
      if revoke.length > 0
        mongo_eval("db.getSiblingDB('#{@resource[:database]}').revokeRolesFromUser('#{@resource[:username]}', #{revoke.to_json})")
      end
    end
  end

  private

  def self.from_roles(roles, db)
    roles.map do |entry|
        if entry['db'] == db
            entry['role']
        else
            "#{entry['role']}@#{entry['db']}"
        end
    end.sort
  end

end
