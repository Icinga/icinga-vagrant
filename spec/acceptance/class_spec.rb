require 'spec_helper_acceptance'

describe 'grafana class' do
  # Create dummy module directorty
  shell('mkdir -p /etc/puppetlabs/code/environments/production/modules/my_custom_module/files/dashboards')

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'grafana': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('grafana') do
      it { is_expected.to be_installed }
    end

    describe service('grafana-server') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  context 'with fancy dashboard config' do
    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'grafana':
        provisioning_datasources => {
          apiVersion  => 1,
          datasources => [
            {
            name      => 'Prometheus',
            type      => 'prometheus',
            access    => 'proxy',
            url       => 'http://localhost:9090/prometheus',
            isDefault => false,
            },
          ],
        },
        provisioning_dashboards => {
          apiVersion => 1,
          providers  => [
            {
              name            => 'default',
              orgId           => 1,
              folder         => '',
              type            => 'file',
              disableDeletion => true,
              options         => {
                path          => '/var/lib/grafana/dashboards',
                puppetsource  => 'puppet:///modules/my_custom_module/dashboards',
              },
            },
          ],
        }
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'with fancy dashboard config and custom target file' do
    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'grafana':
        provisioning_datasources      => {
          apiVersion  => 1,
          datasources => [
            {
            name      => 'Prometheus',
            type      => 'prometheus',
            access    => 'proxy',
            url       => 'http://localhost:9090/prometheus',
            isDefault => false,
            },
          ],
        },
        provisioning_dashboards       => {
          apiVersion => 1,
          providers  => [
            {
              name            => 'default',
              orgId           => 1,
              folder         => '',
              type            => 'file',
              disableDeletion => true,
              options         => {
                path          => '/var/lib/grafana/dashboards',
                puppetsource  => 'puppet:///modules/my_custom_module/dashboards',
              },
            },
          ],
        },
        provisioning_dashboards_file  => '/etc/grafana/provisioning/dashboards/dashboard.yaml',
        provisioning_datasources_file => '/etc/grafana/provisioning/datasources/datasources.yaml'
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'beta release' do
    it 'works idempotently with no errors' do
      case fact('os.family')
      when 'Debian'
        pp = <<-EOS
        class { 'grafana':
          version   => '6.0.0-beta1',
          repo_name => 'beta',
        }
        EOS
      when 'RedHat'
        pp = <<-EOS
        class { 'grafana':
          version       => '6.0.0',
          rpm_iteration => 'beta1',
          repo_name     => 'beta',
        }
        EOS
      end

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('grafana') do
      it { is_expected.to be_installed }
    end
  end
end
