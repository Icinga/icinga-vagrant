require 'spec_helper_acceptance'

case fact('os.family')
when 'RedHat'
  client_package = 'net-snmp-utils'
  service_config = '/etc/snmp/snmpd.conf'
  service_varconfig = '/var/lib/net-snmp/snmpd.conf'
when 'Debian'
  client_package = 'snmp'
  service_config = '/etc/snmp/snmpd.conf'
  service_varconfig = '/var/lib/snmp/snmpd.conf'
when 'Suse'
  client_package = 'net-snmp'
  service_config = '/etc/snmp/snmpd.conf'
  service_varconfig = '/var/lib/snmp/snmpd.conf'
end

describe 'snmp class' do
  context 'with snmpv3 parameters' do
    it 'installs snmpd idempotently' do
      pp = %(
        snmp::snmpv3_user { 'myops':
          authpass => '1234authpass',
          privpass => '5678privpass',
        }
        snmp::snmpv3_user { 'mysubcontractor':
          authpass => '456authpass',
          privpass => '789privpass',
        }
        class { 'snmp':
        manage_client => true,
        snmp_config   => [
          'mibs :',
        ],
        agentaddress  => [ 'udp:127.0.0.1:161' ],
          ro_community  => [],
          ro_community6 => [],
          rw_community  => [],
          rw_community6 => [],
          com2sec       => [],
          com2sec6      => [],
          groups        => [],
          views => [
            'all_view      included    .1',
            'custom_view   excluded    .1',
            'custom_view   included    .1.3.6.1.2.1.1',
          ],
          accesses => [
            'MyOpsGroup            ""      usm      priv    exact  all_view       none   none',
            'MySubContractorsGroup ""      usm      priv    exact  custom_view    none   none',
          ],
          snmpd_config => [
            'rouser myops authPriv -V all_view',
            'rouser mysubcontractor authPriv -V custom_view',
          ],
        }
      )
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
    describe process('snmpd') do
      it { is_expected.to be_running }
    end
    describe process('snmptrapd') do
      it { is_expected.not_to be_running }
    end
    describe file(service_config.to_s) do
      it { is_expected.to be_file }
      it { is_expected.not_to contain 'rocommunity' }
      it { is_expected.not_to contain 'rocommunity6' }
      it { is_expected.not_to contain 'rwcommunity' }
      it { is_expected.not_to contain 'rwcommunity6' }
      it { is_expected.to contain 'access  MyOpsGroup            ""      usm      priv    exact  all_view       none   none' }
      it { is_expected.to contain 'access  MySubContractorsGroup ""      usm      priv    exact  custom_view    none   none' }
      it { is_expected.to contain 'view    all_view      included    .1' }
      it { is_expected.to contain 'view    custom_view   excluded    .1' }
      it { is_expected.to contain 'view    custom_view   included    .1.3.6.1.2.1.1' }
      it { is_expected.to contain 'sysLocation Unknown' }
      it { is_expected.to contain 'sysContact Unknown' }
      it { is_expected.to contain 'rouser myops authPriv -V all_view' }
      it { is_expected.to contain 'rouser mysubcontractor authPriv -V custom_view' }
    end
    describe file(service_varconfig.to_s) do
      it { is_expected.to be_file }
      it { is_expected.to contain 'usmUser ' }
    end
    describe package(client_package.to_s) do
      it { is_expected.to be_installed }
    end
    describe command('snmpget -v 3 -u myops -l authPriv -a SHA -A 1234authpass -x AES -X 5678privpass localhost iso.3.6.1.2.1.25.1.4.0') do
      its(:stdout) { is_expected.to match %r{.*iso.3.6.1.2.1.25.1.4.0 = STRING: "BOOT_IMAGE=.*} }
      its(:exit_status) { is_expected.to eq 0 }
    end
    describe command('snmpget -v 3 -u mysubcontractor -l authPriv -a SHA -A 456authpass -x AES -X 789privpass localhost iso.3.6.1.2.1.25.1.4.0') do
      its(:stdout) { is_expected.to match %r{iso.3.6.1.2.1.25.1.4.0 = No Such Object available on this agent at this OID.*} }
      its(:exit_status) { is_expected.to eq 0 }
    end
    describe command('snmpget -v 3 -u mysubcontractor -l authPriv -a SHA -A 456authpass -x AES -X 789privpass localhost iso.3.6.1.2.1.1.1.0') do
      its(:stdout) { is_expected.to match %r{iso.3.6.1.2.1.1.1.0 = STRING: "Linux.*} }
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  context 'with snmptrapd running' do
    it 'installs snmpd idempotently' do
      pp = %(
        class { 'snmp':
          trap_service_ensure => 'running',
          agentaddress  => [ 'udp:127.0.0.1:161' ],
          snmptrapdaddr => [ 'udp:127.0.0.1:162' ],
        }
      )
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
    describe process('snmpd') do
      it { is_expected.to be_running }
    end
    describe process('snmptrapd') do
      it { is_expected.to be_running }
    end
  end
end
