require 'spec_helper_acceptance'

describe 'kibana4 package', :node => :package do

  package = only_host_with_role(hosts, 'package')

  let(:manifest_package) {
  <<-EOS
    class { '::kibana4': }
    EOS
  }

  let(:manifest_package_plugin_install) {
  <<-EOS
    class { '::kibana4':
      plugins => {
        'elasticsearch/marvel' => {
           ensure          => present,
           plugin_dest_dir => 'marvel',
        },
	'elastic/sense' => {
           ensure          => present,
           plugin_dest_dir => 'sense',
        }
      }

    }
    EOS
  }

  let(:manifest_package_plugin_remove) {
  <<-EOS
    class { '::kibana4':
      plugins => {
        'elasticsearch/marvel' => {
           ensure          => absent,
           plugin_dest_dir => 'marvel',
        },
	'elastic/sense' => {
           ensure          => absent,
           plugin_dest_dir => 'sense',
        }
      }

    }
    EOS
  }

  it 'package install should run without errors' do
    result = apply_manifest_on(package, manifest_package, opts = { :catch_failures => true })
    expect(@result.exit_code).to eq 2
  end

  it 'package install should run a second time without changes' do
    result = apply_manifest_on(package, manifest_package, opts = { :catch_failures => true })
    expect(@result.exit_code).to eq 0
  end

  context 'package default params' do


    #if os[:family] == 'redhat'
    #  describe yumrepo('kibana-4.4') do
    #    it { should exist }
    #    it { should be_enabled }
    #  end
    #end

    describe group('kibana') do
      it { should exist }
    end

    describe user('kibana') do
      it { should exist }
      it { should belong_to_group 'kibana' }
    end

    describe package('kibana') do
      it { should be_installed }
    end

    describe file('/opt/kibana') do
      it { should be_directory }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe file('/etc/init.d/kibana') do
      it { should be_file }
      it { should be_executable }
    end

    describe file('/etc/default/kibana') do
      it { should be_file }
      it { should contain 'user="kibana"' }
    end

    describe service('kibana') do
      #it { should be_installed }
      it { should be_running }
    end

    describe command('sleep 45') do
      its(:exit_status) { should eq 0 }
      describe port(5601) do
        it { should be_listening.with('tcp') }
      end
    end


  end

  it 'package plugin install should run without errors' do
    result = apply_manifest_on(package, manifest_package_plugin_install, opts = { :catch_failures => true })
    expect(@result.exit_code).to eq 2
  end

  it 'package plugin install should run a second time without changes' do
    result = apply_manifest_on(package, manifest_package_plugin_install, opts = { :catch_failures => true })
    expect(@result.exit_code).to eq 0
  end

  it 'package plugin remove should run without errors' do
    result = apply_manifest_on(package, manifest_package_plugin_remove, opts = { :catch_failures => true })
    expect(@result.exit_code).to eq 2
  end

  it 'package plugin remove should run a second time without changes' do
    result = apply_manifest_on(package, manifest_package_plugin_remove, opts = { :catch_failures => true })
    expect(@result.exit_code).to eq 0
  end

end
