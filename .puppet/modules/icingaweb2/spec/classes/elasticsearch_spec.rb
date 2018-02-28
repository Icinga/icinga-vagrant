require 'spec_helper'

describe('icingaweb2::module::elasticsearch', :type => :class) do
  let(:pre_condition) { [
      "class { 'icingaweb2': }"
  ] }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context "#{os} with git_revision 'v0.9.0'" do
        let(:params) { { :git_revision => 'v0.9.0', } }

        it { is_expected.to contain_icingaweb2__module('elasticsearch')
                                .with_install_method('git')
                                .with_git_revision('v0.9.0')
        }
      end

      context "#{os} with an instance" do
        let(:params) { {
            :git_revision => 'v0.9.0',
            :instances => {
                'elastic' => {
                    'uri'                => 'http://localhost:9200',
                    'user'               => 'user',
                    'password'           => 'password',
                    'ca'                 => '/tmp/ca',
                    'client_certificate' => '/tmp/client_certificate',
                    'client_private_key' => '/tmp/client_private_key',
                }
            }
        } }

        it { is_expected.to contain_icingaweb2__module('elasticsearch')
                                .with_install_method('git')
                                .with_git_revision('v0.9.0')
        }

        it { is_expected.to contain_icingaweb2__module__elasticsearch__instance('elastic')
                                .with_uri('http://localhost:9200')
                                .with_user('user')
                                .with_password('password')
                                .with_ca('/tmp/ca')
                                .with_client_certificate('/tmp/client_certificate')
                                .with_client_private_key('/tmp/client_private_key')
        }

        it { is_expected.to contain_icingaweb2__inisection('elasticsearch-instance-elastic')
                                .with_section_name('elastic')
                                .with_target('/etc/icingaweb2/modules/elasticsearch/instances.ini')
                                .with_settings( { 'uri' => 'http://localhost:9200',
                                                'user' => 'user',
                                                'password' => 'password',
                                                'ca' => '/tmp/ca',
                                                'client_certificate' => '/tmp/client_certificate',
                                                'client_private_key' => '/tmp/client_private_key'} )
        }
      end

      context "#{os} with an event type" do
        let(:params) { {
            :git_revision => 'v0.9.0',
            :eventtypes => {
                'filebeat' => {
                    'instance' => 'my-instance',
                    'index'    => 'my-index',
                    'filter'   => 'my-filter',
                    'fields'   => 'my-fields',
                }
            }
        } }

        it { is_expected.to contain_icingaweb2__module('elasticsearch')
                                .with_install_method('git')
                                .with_git_revision('v0.9.0')
        }

        it { is_expected.to contain_icingaweb2__module__elasticsearch__eventtype('filebeat')
                                .with_instance('my-instance')
                                .with_index('my-index')
                                .with_filter('my-filter')
                                .with_fields('my-fields')
        }

        it { is_expected.to contain_icingaweb2__inisection('elasticsearch-eventtype-filebeat')
                                .with_section_name('filebeat')
                                .with_target('/etc/icingaweb2/modules/elasticsearch/eventtypes.ini')
                                .with_settings( { 'instance' => 'my-instance',
                                                  'index' => 'my-index',
                                                  'filter' => 'my-filter',
                                                  'fields' => 'my-fields' } )
        }
      end
    end
  end
end