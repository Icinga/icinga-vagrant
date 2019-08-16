#
# Authors: Emilien Macchi <emilien.macchi@enovance.com>
#          Francois Charlier <francois.charlier@enovance.com>
#

require 'spec_helper'
require 'tempfile'

describe Puppet::Type.type(:mongodb_replset).provider(:mongo) do
  valid_members = [{ 'host' => 'mongo1:27017' }, { 'host' => 'mongo2:27017' }, { 'host' => 'mongo3:27017' }]

  let(:resource) do
    Puppet::Type.type(:mongodb_replset).new(
      ensure: :present,
      name: 'rs_test',
      members: valid_members,
      settings: {},
      provider: :mongo
    )
  end

  let(:resources) { { 'rs_test' => resource } }
  let(:provider) { described_class.new(resource) }

  describe '#create' do
    before do
      tmp = Tempfile.new('test')
      mongodconffile = tmp.path
      allow(provider.class).to receive(:mongod_conf_file).and_return(mongodconffile)
      allow(provider.class).to receive(:mongo).and_return(<<EOT)
{
        "ismaster" : false,
        "secondary" : false,
        "info" : "can't get local.system.replset config from self or any seed (EMPTYCONFIG)",
        "isreplicaset" : true
}
EOT
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'creates a replicaset' do
      expect(provider.class).to receive(:replset_properties)
      expect(provider).to receive(:get_hosts_status).and_return([valid_members, []])
      expect(provider).to receive(:master_host).and_return(false)
      expect(provider).to receive(:rs_initiate).with('{"_id":"rs_test","members":[{"host":"mongo1:27017","_id":0},{"host":"mongo2:27017","_id":1},{"host":"mongo3:27017","_id":2}],"settings":{}}', 'mongo1:27017').and_return('info' => 'Config now saved locally.  Should come online in about a minute.', 'ok' => 1)
      expect(provider).to receive(:db_ismaster).and_return('{"ismaster" : true}')
      provider.create
      provider.flush
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe '#exists?' do
    before do
      tmp = Tempfile.new('test')
      mongodconffile = tmp.path
      allow(provider.class).to receive(:mongod_conf_file).and_return(mongodconffile)
    end

    describe 'when the replicaset does not exist' do
      it 'returns false' do
        allow(provider.class).to receive(:mongo_eval).and_return(<<EOT)
{
	"startupStatus" : 3,
	"info" : "run rs.initiate(...) if not yet done for the set",
	"ok" : 0,
	"errmsg" : "can't get local.system.replset config from self or any seed (EMPTYCONFIG)"
}
EOT
        provider.class.prefetch(resources)
        expect(resource.provider.exists?).to be false
      end
    end

    describe 'when the replicaset exists' do
      it 'returns true' do
        allow(provider.class).to receive(:mongo_eval).and_return(<<EOT)
{
	"_id" : "rs_test",
	"version" : 1,
	"members" : [ ]
}
EOT
        provider.class.prefetch(resources)
        expect(resource.provider.exists?).to be true
      end
    end
  end

  describe '#members' do
    before do
      tmp = Tempfile.new('test')
      mongodconffile = tmp.path
      allow(provider.class).to receive(:mongod_conf_file).and_return(mongodconffile)
    end
    it 'returns the members of a configured replicaset' do
      allow(provider.class).to receive(:mongo_eval).and_return(<<EOT)
{
	"_id" : "rs_test",
	"version" : 1,
	"members" : [
		{
			"_id" : 0,
			"host" : "mongo1:27017"
		},
		{
			"_id" : 1,
			"host" : "mongo2:27017"
		},
		{
			"_id" : 2,
			"host" : "mongo3:27017"
		}
	]
}
EOT
      provider.class.prefetch(resources)
      expect(resource.provider.members).to match_array(valid_members)
    end
  end

  describe 'members=' do
    before do
      tmp = Tempfile.new('test')
      mongodconffile = tmp.path
      allow(provider.class).to receive(:mongod_conf_file).and_return(mongodconffile)
      allow(provider.class).to receive(:mongo_eval).and_return(<<EOT)
{
	"setName" : "rs_test",
	"ismaster" : true,
	"secondary" : false,
	"hosts" : [
		"mongo1:27017"
	],
	"primary" : "mongo1:27017",
	"me" : "mongo1:27017",
	"maxBsonObjectSize" : 16777216,
	"maxMessageSizeBytes" : 48000000,
	"localTime" : "2014-01-10T19:31:51.281Z",
	"ok" : 1
}
EOT
    end

    it 'adds missing members to an existing replicaset' do
      allow(provider.class).to receive(:replset_properties)
      allow(provider).to receive(:rs_status).and_return('set' => 'rs_test')
      expect(provider).to receive('rs_add').thrice.and_return('ok' => 1)
      provider.members = valid_members
      provider.flush
    end

    it 'raises an error when the master host is not available' do
      allow(provider).to receive(:rs_status).and_return('set' => 'rs_test')
      allow(provider).to receive(:db_ismaster).and_return('primary' => false)
      provider.members = valid_members
      expect { provider.flush }.to raise_error(Puppet::Error, "Can't find master host for replicaset #{resource[:name]}.")
    end

    it 'raises an error when at least one member is not running with --replSet' do
      allow(provider).to receive(:rs_status).and_return('ok' => 0, 'errmsg' => 'not running with --replSet')
      provider.members = valid_members
      expect { provider.flush }.to raise_error(Puppet::Error, %r{is not supposed to be part of a replicaset\.$})
    end

    it 'raises an error when at least one member is configured with another replicaset name' do
      allow(provider).to receive(:rs_status).and_return('set' => 'rs_another')
      provider.members = valid_members
      expect { provider.flush }.to raise_error(Puppet::Error, %r{is already part of another replicaset\.$})
    end

    it 'raises an error when no member is available' do
      allow(provider.class).to receive(:mongo_command).and_raise(Puppet::ExecutionFailure, <<EOT)
Fri Jan 10 20:20:33.995 Error: couldn't connect to server localhost:9999 at src/mongo/shell/mongo.js:147
exception: connect failed
EOT
      provider.members = valid_members
      expect { provider.flush }.to raise_error(Puppet::Error, "Can't connect to any member of replicaset #{resource[:name]}.")
    end
  end
end
