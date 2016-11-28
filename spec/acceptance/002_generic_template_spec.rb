require 'spec_helper_acceptance'

describe "filebeat class" do

  package_name = 'filebeat'
  service_name = 'filebeat'

  context 'use generic template' do

    let(:pp) do
      <<-EOS
      if $::osfamily == 'Debian' {
        include ::apt

        package { 'apt-transport-https':
          ensure => present,
        }
      }

      class { 'filebeat':
        use_generic_template => true,
        outputs => {
          'logstash' => {
            'bulk_max_size' => 1024,
            'hosts' => [
              'localhost:5044',
            ],
          },
          'file'     => {
            'path' => '/tmp',
            'filename' => 'filebeat',
            'rotate_every_kb' => 10240,
            'number_of_files' => 2,
          },
        },
        shipper => {
          refresh_topology_freq => 10,
          topology_expire => 15,
          queue_size => 1000,
        },
        logging => {
          files => {
            rotateeverybytes => 10485760,
            keepfiles => 7,
          }
        },
        prospectors => {
          'system-logs' => {
            doc_type => 'system',
            paths    => [
              '/var/log/dmesg',
            ],
            fields   => {
              service => 'system',
              file    => 'dmesg',
            }
          }
        }
      }
      EOS
    end

    it_behaves_like "an idempotent resource"

    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end

    describe package(package_name) do
      it { should be_installed }
    end
  end
end
