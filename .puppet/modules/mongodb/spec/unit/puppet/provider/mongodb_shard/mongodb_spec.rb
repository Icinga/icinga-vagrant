require 'spec_helper'

describe Puppet::Type.type(:mongodb_shard).provider(:mongo) do
  let(:resource) do
    Puppet::Type.type(:mongodb_shard).new(
      ensure: :present,
      name: 'rs_test',
      member: 'rs_test/mongo1:27018',
      keys: [],
      provider: :mongo
    )
  end

  let(:provider) { resource.provider }
  let(:instance) { provider.class.instances.first }

  let(:parsed_shards) { %w[rs_test] }

  let(:raw_shards) do
    {
      'sharding version' => {
        '_id' => 1,
        'version' => 4,
        'minCompatibleVersion' => 4,
        'currentVersion' => 5,
        'clusterId' => "ObjectId(\'548e9110f3aca177c94c5e49\')"
      },
      'shards' => [
        {  '_id' => 'rs_test', 'host' => 'rs_test/mongo1:27018' }
      ],
      'databases' => [
        {  '_id' => 'admin', 'partitioned' => false, 'primary' => 'config' },
        {  '_id' => 'test', 'partitioned' => false, 'primary' => 'rs_test' },
        {  '_id' => 'rs_test', 'partitioned' => true, 'primary' => 'rs_test' }
      ]
    }
  end

  before do
    allow(provider.class).to receive(:mongo_command).with('sh.status()').and_return(raw_shards)
  end

  describe 'self.instances' do
    it 'creates a shard' do
      shards = provider.class.instances.map(&:name)
      expect(parsed_shards).to match_array(shards)
    end
  end

  describe '#create' do
    # rubocop:disable RSpec/MultipleExpectations
    it 'makes a shard' do
      expect(provider).to receive(:sh_addshard).with('rs_test/mongo1:27018').and_return(
        'shardAdded' => 'rs_test',
        'ok' => 1
      )
      expect(provider).to receive(:sh_enablesharding).with('rs_test').and_return(
        'ok' => 1
      )
      provider.create
      provider.flush
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe 'destroy' do
    it 'removes a shard' do
    end
  end

  describe 'exists?' do
    it 'checks if shard exists' do
      instance.exists?
    end
  end
end
