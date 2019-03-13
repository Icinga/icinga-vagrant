require 'spec_helper_acceptance'

describe 'grafana_plugin' do
  context 'create plugin resource' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'grafana':}
      grafana_plugin { 'grafana-simple-json-datasource': }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has the plugin' do
      shell('grafana-cli plugins ls') do |r|
        expect(r.stdout).to match(%r{grafana-simple-json-datasource})
      end
    end
  end

  context 'create plugin resource with repo' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'grafana':}
      grafana_plugin { 'grafana-simple-json-datasource':
        ensure => present,
        repo   => 'https://nexus.company.com/grafana/plugins',
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has the plugin' do
      shell('grafana-cli plugins ls') do |r|
        expect(r.stdout).to match(%r{grafana-simple-json-datasource})
      end
    end
  end

  context 'destroy plugin resource' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'grafana':}
      grafana_plugin { 'grafana-simple-json-datasource':
        ensure => absent,
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'does not have the plugin' do
      shell('grafana-cli plugins ls') do |r|
        expect(r.stdout).not_to match(%r{grafana-simple-json-datasource})
      end
    end
  end
end
