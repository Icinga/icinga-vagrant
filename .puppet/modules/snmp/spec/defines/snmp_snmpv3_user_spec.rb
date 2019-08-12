require 'spec_helper'

describe 'snmp::snmpv3_user' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      case facts[:osfamily]
      when 'RedHat'
        describe 'with default settings' do
          let(:title) { 'myDEFAULTuser' }

          let :params do
            {
              authpass: 'myauthpass'
            }
          end

          it {
            is_expected.to contain_exec('stop-snmpd').with(
              path: '/bin:/sbin:/usr/bin:/usr/sbin',
              command: 'service snmpd stop ; sleep 5',
              user: 'root'
            ).that_requires(['Package[snmpd]', 'File[var-net-snmp]'])

            is_expected.to contain_file('/var/lib/net-snmp/snmpd.conf')

            is_expected.to contain_file_line('create-snmpv3-user-myDEFAULTuser').with(
              path:  '/var/lib/net-snmp/snmpd.conf',
              line:  'createUser myDEFAULTuser SHA "myauthpass"',
              match: '^createUser myDEFAULTuser '
            ).that_subscribes_to(['Exec[stop-snmpd]']).that_comes_before('Service[snmpd]')
          }
        end

        describe 'with all settings' do
          let(:title) { 'myALLuser' }

          let :params do
            {
              authpass: 'myauthpass',
              authtype: 'MD5',
              privpass: 'myprivpass',
              privtype: 'DES'
            }
          end

          it {
            is_expected.to contain_exec('stop-snmpd').with(
              path: '/bin:/sbin:/usr/bin:/usr/sbin',
              command: 'service snmpd stop ; sleep 5',
              user: 'root'
            ).that_requires(['Package[snmpd]', 'File[var-net-snmp]'])

            is_expected.to contain_file('/var/lib/net-snmp/snmpd.conf')

            is_expected.to contain_file_line('create-snmpv3-user-myALLuser').with(
              path:  '/var/lib/net-snmp/snmpd.conf',
              line:  'createUser myALLuser MD5 "myauthpass" DES "myprivpass"',
              match: '^createUser myALLuser '
            ).that_subscribes_to(['Exec[stop-snmpd]']).that_comes_before('Service[snmpd]')
          }
        end

        describe 'with snmptrapd settings' do
          let(:title) { 'myTRAPuser' }

          let :params do
            {
              authpass: 'myauthpass',
              daemon: 'snmptrapd'
            }
          end

          it {
            is_expected.to contain_exec('stop-snmptrapd').with(
              path: '/bin:/sbin:/usr/bin:/usr/sbin',
              command: 'service snmptrapd stop ; sleep 5',
              user: 'root'
            ).that_requires(['Package[snmpd]', 'File[var-net-snmp]'])

            is_expected.to contain_file('/var/lib/net-snmp/snmptrapd.conf')

            is_expected.to contain_file_line('create-snmpv3-user-myTRAPuser').with(
              path:  '/var/lib/net-snmp/snmptrapd.conf',
              line:  'createUser myTRAPuser SHA "myauthpass"',
              match: '^createUser myTRAPuser '
            ).that_subscribes_to(['Exec[stop-snmptrapd]']).that_comes_before('Service[snmptrapd]')
          }
        end
      when 'Debian'
        describe 'with default settings' do
          let(:title) { 'myDEFAULTuser' }

          let :params do
            {
              authpass: 'myauthpass'
            }
          end

          it {
            is_expected.to contain_exec('stop-snmpd').with(
              path: '/bin:/sbin:/usr/bin:/usr/sbin',
              command: 'service snmpd stop ; sleep 5',
              user: 'root'
            ).that_requires(['Package[snmpd]', 'File[var-net-snmp]'])

            is_expected.to contain_file('/var/lib/snmp/snmpd.conf')

            is_expected.to contain_file_line('create-snmpv3-user-myDEFAULTuser').with(
              path:  '/var/lib/snmp/snmpd.conf',
              line:  'createUser myDEFAULTuser SHA "myauthpass"',
              match: '^createUser myDEFAULTuser '
            ).that_subscribes_to(['Exec[stop-snmpd]']).that_comes_before('Service[snmpd]')
          }
        end

        describe 'with all settings' do
          let(:title) { 'myALLuser' }

          let :params do
            {
              authpass: 'myauthpass',
              authtype: 'MD5',
              privpass: 'myprivpass',
              privtype: 'DES'
            }
          end

          it {
            is_expected.to contain_exec('stop-snmpd').with(
              path: '/bin:/sbin:/usr/bin:/usr/sbin',
              command: 'service snmpd stop ; sleep 5',
              user: 'root'
            ).that_requires(['Package[snmpd]', 'File[var-net-snmp]'])

            is_expected.to contain_file('/var/lib/snmp/snmpd.conf')

            is_expected.to contain_file_line('create-snmpv3-user-myALLuser').with(
              path:  '/var/lib/snmp/snmpd.conf',
              line:  'createUser myALLuser MD5 "myauthpass" DES "myprivpass"',
              match: '^createUser myALLuser '
            ).that_subscribes_to(['Exec[stop-snmpd]']).that_comes_before('Service[snmpd]')
          }
        end

        describe 'with snmptrapd settings' do
          let(:title) { 'myTRAPuser' }

          let :params do
            {
              authpass: 'myauthpass',
              daemon: 'snmptrapd'
            }
          end

          it {
            is_expected.to contain_exec('stop-snmpd').with(
              path: '/bin:/sbin:/usr/bin:/usr/sbin',
              command: 'service snmpd stop ; sleep 5',
              user: 'root'
            ).that_requires(['Package[snmpd]', 'File[var-net-snmp]'])

            is_expected.to contain_file('/var/lib/snmp/snmpd.conf')

            is_expected.to contain_file_line('create-snmpv3-user-myTRAPuser').with(
              path:  '/var/lib/snmp/snmpd.conf',
              line:  'createUser myTRAPuser SHA "myauthpass"',
              match: '^createUser myTRAPuser '
            ).that_subscribes_to(['Exec[stop-snmpd]']).that_comes_before('Service[snmpd]')
          }
        end
      when 'Suse'
        describe 'with default settings' do
          let(:title) { 'myDEFAULTuser' }

          let :params do
            {
              authpass: 'myauthpass'
            }
          end

          it {
            is_expected.to contain_exec('stop-snmpd').with(
              path: '/bin:/sbin:/usr/bin:/usr/sbin',
              command: 'service snmpd stop ; sleep 5',
              user: 'root'
            ).that_requires(['Package[snmpd]', 'File[var-net-snmp]'])

            is_expected.to contain_file('/var/lib/net-snmp/snmpd.conf')

            is_expected.to contain_file_line('create-snmpv3-user-myDEFAULTuser').with(
              path:  '/var/lib/net-snmp/snmpd.conf',
              line:  'createUser myDEFAULTuser SHA "myauthpass"',
              match: '^createUser myDEFAULTuser '
            ).that_subscribes_to(['Exec[stop-snmpd]']).that_comes_before('Service[snmpd]')
          }
        end

        describe 'with all settings' do
          let(:title) { 'myALLuser' }

          let :params do
            {
              authpass: 'myauthpass',
              authtype: 'MD5',
              privpass: 'myprivpass',
              privtype: 'DES'
            }
          end

          it {
            is_expected.to contain_exec('stop-snmpd').with(
              path: '/bin:/sbin:/usr/bin:/usr/sbin',
              command: 'service snmpd stop ; sleep 5',
              user: 'root'
            ).that_requires(['Package[snmpd]', 'File[var-net-snmp]'])

            is_expected.to contain_file('/var/lib/net-snmp/snmpd.conf')

            is_expected.to contain_file_line('create-snmpv3-user-myALLuser').with(
              path:  '/var/lib/net-snmp/snmpd.conf',
              line:  'createUser myALLuser MD5 "myauthpass" DES "myprivpass"',
              match: '^createUser myALLuser '
            ).that_subscribes_to(['Exec[stop-snmpd]']).that_comes_before('Service[snmpd]')
          }
        end

        describe 'with snmptrapd settings' do
          let(:title) { 'myTRAPuser' }

          let :params do
            {
              authpass: 'myauthpass',
              daemon: 'snmptrapd'
            }
          end

          it {
            is_expected.to contain_exec('stop-snmptrapd').with(
              path: '/bin:/sbin:/usr/bin:/usr/sbin',
              command: 'service snmptrapd stop ; sleep 5',
              user: 'root'
            ).that_requires(['Package[snmpd]', 'File[var-net-snmp]'])

            is_expected.to contain_file('/var/lib/net-snmp/snmptrapd.conf')

            is_expected.to contain_file_line('create-snmpv3-user-myTRAPuser').with(
              path:  '/var/lib/net-snmp/snmptrapd.conf',
              line:  'createUser myTRAPuser SHA "myauthpass"',
              match: '^createUser myTRAPuser '
            ).that_subscribes_to(['Exec[stop-snmptrapd]']).that_comes_before('Service[snmptrapd]')
          }
        end
      end

      describe 'with correct authpass and privpass for md5user' do
        let(:title) { 'md5user' }

        let :params do
          {
            authpass: 'maplesyrup',
            authtype: 'MD5',
            privpass: 'maplesyrup',
            privtype: 'AES'
          }
        end

        it {
          is_expected.not_to contain_file_line('create-snmpv3-user-md5user')
        }
      end

      describe 'with correct authpass and wrong privpass for md5user' do
        let(:title) { 'md5user' }

        let :params do
          {
            authpass: 'maplesyrup',
            authtype: 'MD5',
            privpass: 'cornsyrup',
            privtype: 'AES'
          }
        end

        it {
          is_expected.to contain_file_line('create-snmpv3-user-md5user')
        }
      end

      describe 'with wrong authpass and correct privpass for md5user' do
        let(:title) { 'md5user' }

        let :params do
          {
            authpass: 'cornsyrup',
            authtype: 'MD5',
            privpass: 'maplesyrup',
            privtype: 'AES'
          }
        end

        it {
          is_expected.to contain_file_line('create-snmpv3-user-md5user')
        }
      end

      describe 'with wrong authpass and wrong privpass for md5user' do
        let(:title) { 'md5user' }

        let :params do
          {
            authpass: 'cornsyrup',
            authtype: 'MD5',
            privpass: 'cornsyrup',
            privtype: 'AES'
          }
        end

        it {
          is_expected.to contain_file_line('create-snmpv3-user-md5user')
        }
      end

      describe 'with correct authpass and privpass for shauser' do
        let(:title) { 'shauser' }

        let :params do
          {
            authpass: 'maplesyrup',
            authtype: 'SHA',
            privpass: 'maplesyrup',
            privtype: 'AES'
          }
        end

        it {
          is_expected.not_to contain_file_line('create-snmpv3-user-shauser')
        }
      end

      describe 'with correct authpass and wrong privpass for shauser' do
        let(:title) { 'shauser' }

        let :params do
          {
            authpass: 'maplesyrup',
            authtype: 'SHA',
            privpass: 'cornsyrup',
            privtype: 'AES'
          }
        end

        it {
          is_expected.to contain_file_line('create-snmpv3-user-shauser')
        }
      end

      describe 'with wrong authpass and correct privpass for shauser' do
        let(:title) { 'shauser' }

        let :params do
          {
            authpass: 'cornsyrup',
            authtype: 'SHA',
            privpass: 'maplesyrup',
            privtype: 'AES'
          }
        end

        it {
          is_expected.to contain_file_line('create-snmpv3-user-shauser')
        }
      end

      describe 'with wrong authpass and wrong privpass for shauser' do
        let(:title) { 'shauser' }

        let :params do
          {
            authpass: 'cornsyrup',
            authtype: 'SHA',
            privpass: 'cornsyrup',
            privtype: 'AES'
          }
        end

        it {
          is_expected.to contain_file_line('create-snmpv3-user-shauser')
        }
      end

      describe 'with correct authpass and empty privpass for nonuser' do
        let(:title) { 'nonuser' }

        let :params do
          {
            authpass: 'maplesyrup',
            authtype: 'SHA'
          }
        end

        it {
          is_expected.not_to contain_file_line('create-snmpv3-user-nonuser')
        }
      end

      describe 'with wrong authpass and empty privpass for nonuser' do
        let(:title) { 'nonuser' }

        let :params do
          {
            authpass: 'cornsyrup',
            authtype: 'SHA'
          }
        end

        it {
          is_expected.to contain_file_line('create-snmpv3-user-nonuser')
        }
      end

      describe 'with correct authpass and defined privpass for nonuser' do
        let(:title) { 'nonuser' }

        let :params do
          {
            authpass: 'cornsyrup',
            authtype: 'SHA',
            privpass: 'cornsyrup',
            privtype: 'AES'
          }
        end

        it {
          is_expected.to contain_file_line('create-snmpv3-user-nonuser')
        }
      end
    end
  end
end
