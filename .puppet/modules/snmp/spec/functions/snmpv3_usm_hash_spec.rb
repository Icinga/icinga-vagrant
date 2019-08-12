require 'spec_helper'

describe 'snmp::snmpv3_usm_hash' do
  describe 'with MD5 hash (RFC-3414 A.3.1)' do
    it {
      is_expected.to run.with_params('MD5',
                                     '0x000000000000000000000002',
                                     'maplesyrup').
        and_return('0x526f5eed9fcce26f8964c2930787d82b')
    }
  end

  describe 'with SHA1 hash (RFC-3414 A.3.2)' do
    it {
      is_expected.to run.with_params('SHA',
                                     '0x000000000000000000000002',
                                     'maplesyrup').
        and_return('0x6695febc9288e36282235fc7151f128497b38f3f')
    }
  end

  describe 'with SHA1 hash and truncated to 128 bits' do
    it {
      is_expected.to run.with_params('SHA',
                                     '0x000000000000000000000002',
                                     'maplesyrup',
                                     128).
        and_return('0x6695febc9288e36282235fc7151f1284')
    }
  end
end
