require 'spec_helper'
require 'tempfile'

describe Puppet::Type.type(:mongodb_database).provider(:mongodb) do
  let(:raw_dbs) do
    {
      'databases' => [
        {
          'name'       => 'admin',
          'sizeOnDisk' => 83_886_080,
          'empty'      => false
        }, {
          'name'       => 'local',
          'sizeOnDisk' => 83_886_080,
          'empty'      => false
        }
      ],
      'totalSize' => 251_658_240,
      'ok' => 1
    }.to_json
  end

  let(:resource) do
    Puppet::Type.type(:mongodb_database).new(
      ensure: :present,
      name: 'new_database',
      provider: described_class.name
    )
  end

  let(:provider) { resource.provider }

  let(:instance) { provider.class.instances.first }

  before do
    tmp = Tempfile.new('test')
    mongodconffile = tmp.path
    allow(provider.class).to receive(:mongod_conf_file).and_return(mongodconffile)
    allow(provider.class).to receive(:mongo_eval).with('rs.slaveOk();printjson(db.getMongo().getDBs())').and_return(raw_dbs)
    allow(provider.class).to receive(:db_ismaster).and_return(true)
  end

  describe 'self.instances' do
    it 'returns an array of dbs' do
      expect(provider.class.instances.map(&:name)).to match_array(%w[admin local])
    end
  end

  describe 'create' do
    it 'makes a database' do
      expect(provider).to receive(:mongo_eval)
      provider.create
    end
  end

  describe 'destroy' do
    it 'removes a database' do
      expect(provider).to receive(:mongo_eval)
      provider.destroy
    end
  end

  describe 'exists?' do
    it 'checks if database exists' do
      instance.exists?
    end
  end
end
