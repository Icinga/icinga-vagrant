require 'spec_helper'
require 'puppet/util/mongodb_output'
require 'json'

describe Puppet::Util::MongodbOutput do
  let(:bson_data) do
    <<-EOT
      {
        "setName": "rs_test",
        "ismaster": true,
        "secondary": false,
        "hosts": [
          "mongo1:27017"
        ],
        "primary": "mongo1:27017",
        "me": "mongo1:27017",
        "maxBsonObjectSize": 16777216,
        "maxMessageSizeBytes": 48000000,
        "hash": BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
        "keyId": NumberLong(0),
        "clusterTime": Timestamp(1538381287, 1),
        "replicaSetId": ObjectId("5bb1d270137a581ebd3d61f2"),
        "slaveDelay": NumberLong(-1),
        "majorityWriteDate": ISODate("2018-10-01T08:08:01Z"),
        "lastHeartbeat": ISODate("2018-10-01T08:08:05.859Z"),
        "ok": 1
      }
    EOT
  end

  let(:json_data) do
    <<-EOT
      {
        "setName": "rs_test",
        "ismaster": true,
        "secondary": false,
        "hosts": [
          "mongo1:27017"
        ],
        "primary": "mongo1:27017",
        "me": "mongo1:27017",
        "maxBsonObjectSize": 16777216,
        "maxMessageSizeBytes": 48000000,
        "hash": 0,
        "keyId": 0,
        "clusterTime": 1538381287,
        "replicaSetId": "5bb1d270137a581ebd3d61f2",
        "slaveDelay": -1,
        "majorityWriteDate": "2018-10-01T08:08:01Z",
        "lastHeartbeat": "2018-10-01T08:08:05.859Z",
        "ok": 1
      }
    EOT
  end

  describe '.sanitize' do
    it 'returns a valid json' do
      sanitized_json = described_class.sanitize(bson_data)
      expect { JSON.parse(sanitized_json) }.not_to raise_error
    end
    it 'replaces data types' do
      sanitized_json = described_class.sanitize(bson_data)
      expect(JSON.parse(sanitized_json)).to include(JSON.parse(json_data))
    end
  end
end
