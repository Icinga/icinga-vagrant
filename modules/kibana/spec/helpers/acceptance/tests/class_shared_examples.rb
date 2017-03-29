shared_examples 'class manifests' do |plugin_json_file, plugin_upgrade|
  context 'example manifest' do
    it { apply_manifest(manifest, :catch_failures => true) }
    it { apply_manifest(manifest, :catch_changes  => true) }

    describe package('kibana') do
      it { is_expected.to be_installed }
    end

    describe service('kibana') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(port) { it { should be_listening } }

    describe server :container do
      describe http('http://localhost:5602') do
        it('returns OK', :api) { expect(response.status).to eq(200) }
        it('is live', :api) { expect(response['kbn-name']).to eq('kibana') }
        it 'installs the correct version', :api do
          expect(response['kbn-version']).to eq(version)
        end
      end
    end
  end

  context 'plugin upgrades' do
    let(:plugin_version) { plugin_upgrade }

    it { apply_manifest(manifest, :catch_failures => true) }
    it { apply_manifest(manifest, :catch_changes  => true) }

    describe file(plugin_json_file) do
      its(:content_as_json) { should include('version' => plugin_version) }
    end
  end

  context 'removal' do
    let(:manifest) do
      <<-EOS
        class { 'kibana':
          ensure => absent,
        }
      EOS
    end

    it 'should apply cleanly' do
      apply_manifest(
        "kibana_plugin { '#{plugin}': ensure => absent } ->" + manifest,
        :catch_failures => true
      )
    end

    it 'is idempotent' do
      apply_manifest(manifest, :catch_changes => true)
    end

    describe package('kibana') do
      it { should_not be_installed }
    end

    describe service('kibana') do
      it { should_not be_enabled }
      it { should_not be_running }
    end

    describe port(port) { it { should_not be_listening } }
  end
end
