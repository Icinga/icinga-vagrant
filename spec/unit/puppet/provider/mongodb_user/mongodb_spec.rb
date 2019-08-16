require 'spec_helper'
require 'json'
require 'tempfile'

describe Puppet::Type.type(:mongodb_user).provider(:mongodb) do
  let(:raw_users) do
    [
      { '_id' => 'admin.root', 'user' => 'root', 'db' => 'admin', 'credentials' => { 'MONGODB-CR' => 'pass', 'SCRAM-SHA-1' => { 'iterationCount' => 10_000, 'salt' => 'salt', 'storedKey' => 'storedKey', 'serverKey' => 'serverKey' } }, 'roles' => [{ 'role' => 'role2', 'db' => 'admin' }, { 'role' => 'role1', 'db' => 'admin' }] }
    ].to_json
  end

  let(:parsed_users) { %w[root] }

  let(:resource) do
    Puppet::Type.type(:mongodb_user).new(
      ensure: :present,
      name: 'new_user',
      database: 'new_database',
      password_hash: 'pass',
      roles: %w[role1 role2],
      provider: described_class.name
    )
  end

  let(:provider) { resource.provider }

  let(:instance) { provider.class.instances.first }

  before do
    tmp = Tempfile.new('test')
    mongodconffile = tmp.path
    allow(provider.class).to receive(:mongod_conf_file).and_return(mongodconffile)
    allow(provider.class).to receive(:mongo_eval).with('printjson(db.system.users.find().toArray())').and_return(raw_users)
    allow(provider.class).to receive(:mongo_version).and_return('2.6.x')
    allow(provider.class).to receive(:db_ismaster).and_return(true)
  end

  describe 'self.instances' do
    it 'returns an array of users' do
      usernames = provider.class.instances.map(&:username)
      expect(parsed_users).to match_array(usernames)
    end
  end

  describe 'empty self.instances from slave' do
    it 'doesn`t retrun array of users' do
      allow(provider.class).to receive(:db_ismaster).and_return(false)
      expect(provider.class.instances).to match_array([])
    end
  end

  describe 'create' do
    it 'creates a user' do
      cmd_json = <<-EOS.gsub(%r{^\s*}, '').gsub(%r{$\n}, '')
      {
        "createUser":"new_user",
        "pwd":"pass",
        "customData":{"createdBy":"Puppet Mongodb_user['new_user']"},
        "roles":["role1","role2"],
        "digestPassword":false
      }
      EOS

      expect(provider).to receive(:mongo_eval).with("db.runCommand(#{cmd_json})", 'new_database')
      provider.create
    end
  end

  describe 'destroy' do
    it 'removes a user' do
      expect(provider).to receive(:mongo_eval).with('db.dropUser("new_user")')
      provider.destroy
    end
  end

  describe 'exists?' do
    it 'checks if user exists' do
      expect(provider.exists?).to be false
    end
  end

  describe 'password_hash' do
    it 'returns a password_hash' do
      expect(instance.password_hash).to eq('pass')
    end
  end

  describe 'password_hash=' do
    it 'changes a password_hash' do
      cmd_json = <<-EOS.gsub(%r{^\s*}, '').gsub(%r{$\n}, '')
      {
          "updateUser":"new_user",
          "pwd":"pass",
          "digestPassword":false
      }
      EOS
      expect(provider).to receive(:mongo_eval).
        with("db.runCommand(#{cmd_json})", 'new_database')
      provider.password_hash = 'newpass'
    end
  end

  describe 'scram_credentials' do
    it 'returns scram_credentials' do
      credentials = {
        'iterationCount' => 10_000,
        'salt' => 'salt',
        'storedKey' => 'storedKey',
        'serverKey' => 'serverKey'
      }
      expect(instance.scram_credentials).to match(credentials)
    end
  end

  describe 'roles' do
    it 'returns a sorted roles' do
      expect(instance.roles).to eq(%w[role1 role2])
    end
  end

  describe 'roles=' do
    it 'changes nothing' do
      resource.provider.set(name: 'new_user', ensure: :present, roles: %w[role1 role2])
      expect(provider).not_to receive(:mongo_eval)
      provider.roles = %w[role1 role2]
    end

    it 'grant a role' do
      resource.provider.set(name: 'new_user', ensure: :present, roles: %w[role1 role2])
      expect(provider).to receive(:mongo_eval).
        with('db.getSiblingDB("new_database").grantRolesToUser("new_user", ["role3"])')
      provider.roles = %w[role1 role2 role3]
    end

    it 'revokes a role' do
      resource.provider.set(name: 'new_user', ensure: :present, roles: %w[role1 role2])
      expect(provider).to receive(:mongo_eval).
        with('db.getSiblingDB("new_database").revokeRolesFromUser("new_user", ["role1"])')
      provider.roles = ['role2']
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'exchanges a role' do
      resource.provider.set(name: 'new_user', ensure: :present, roles: %w[role1 role2])
      expect(provider).to receive(:mongo_eval).
        with('db.getSiblingDB("new_database").revokeRolesFromUser("new_user", ["role1"])')
      expect(provider).to receive(:mongo_eval).
        with('db.getSiblingDB("new_database").grantRolesToUser("new_user", ["role3"])')

      provider.roles = %w[role2 role3]
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
