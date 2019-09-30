require 'spec_helper_acceptance'

describe 'grafana_folder' do
  context 'setup grafana server' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'grafana':
        cfg => {
          security => {
            admin_user     => 'admin',
            admin_password => 'admin'
          }
        }
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'create folder resource' do
    it 'creates the folder' do
      pp = <<-EOS
      grafana_folder { 'example-folder':
        ensure           => present,
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin'
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has the folder' do
      shell('curl --user admin:admin http://localhost:3000/api/folders') do |f|
        expect(f.stdout).to match(%r{example-folder})
      end
    end
  end

  context 'create folder containing dashboard' do
    it 'creates an example dashboard in the example folder' do
      pp = <<-EOS
      grafana_dashboard { 'example-dashboard':
        ensure           => present,
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
        content          => '{"uid": "abc123xy"}',
        folder           => 'example-folder'
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'folder contains dashboard' do
      shell('curl --user admin:admin http://localhost:3000/api/dashboards/db/example-dashboard') do |f|
        expect(f.stdout).to match(%r{"folderId":1})
      end
    end
  end

  context 'destroy resources' do
    it 'destroys the folders and dashboard' do
      pp = <<-EOS
      grafana_folder { 'example-folder':
        ensure           => absent,
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
      }
      grafana_folder { 'nomatch-folder':
        ensure           => absent,
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
      }
      grafana_dashboard { 'example-dashboard':
        ensure           => absent,
        grafana_url      => 'http://localhost:3000',
        grafana_user     => 'admin',
        grafana_password => 'admin',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has no example-folder' do
      shell('curl --user admin:admin http://localhost:3000/api/folders') do |f|
        expect(f.stdout).not_to match(%r{example-folder})
      end
    end

    it 'has no nomatch-folder' do
      shell('curl --user admin:admin http://localhost:3000/api/folders') do |f|
        expect(f.stdout).not_to match(%r{nomatch-folder})
      end
    end
  end
end
