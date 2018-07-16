shared_examples 'basic acceptance' do
  context 'example manifest' do
    request_path = if RSpec.configuration.is_snapshot and not RSpec.configuration.oss
                     '/login'
                   else
                     ''
                   end

    it { apply_manifest(manifest, :catch_failures => true) }
    it { apply_manifest(manifest, :catch_changes  => true) }

    describe package("kibana#{RSpec.configuration.oss ? '-oss' : ''}") do
      it { is_expected.to be_installed }
    end

    describe service('kibana') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(5602) { it { should be_listening } }

    describe server :container do
      describe http("http://localhost:5602#{request_path}") do
        it('returns OK', :api) { expect(response.status).to eq(200) }
        it('is live', :api) { expect(response['kbn-name']).to eq('kibana') }
        it 'installs the correct version', :api do
          ver = version.count('-') >= 1 ? version.split('-')[0..-2].join('-') : version
          expect(response['kbn-version']).to eq(ver)
        end
      end
    end
  end
end
