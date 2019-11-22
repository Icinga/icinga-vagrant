require 'spec_helper_acceptance'

describe 'mongodb_database' do
  describe 'creating a database' do
    context 'with default port' do
      it 'compiles with no errors' do
        pp = <<-EOS
          class { 'mongodb::server': }
          -> class { 'mongodb::client': }
          -> mongodb::db { 'testdb1':
            user     => 'testuser',
            password => 'testpass',
          }
          -> mongodb::db { 'testdb2':
            user     => 'testuser',
            password => 'testpass',
          }
        EOS
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end
      it 'creates the databases' do
        shell("mongo testdb1 --eval 'printjson(db.getMongo().getDBs())'")
        shell("mongo testdb2 --eval 'printjson(db.getMongo().getDBs())'")
      end
    end

    context 'with custom port' do
      it 'works with no errors' do
        pp = <<-EOS
          class { 'mongodb::server':
            port => 27018,
          }
          -> class { 'mongodb::client': }
          -> mongodb::db { 'testdb1':
            user     => 'testuser',
            password => 'testpass',
          }
          -> mongodb::db { 'testdb2':
            user     => 'testuser',
            password => 'testpass',
          }
        EOS

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end
      it 'creates the database' do
        shell("mongo testdb1 --port 27018 --eval 'printjson(db.getMongo().getDBs())'")
        shell("mongo testdb2 --port 27018 --eval 'printjson(db.getMongo().getDBs())'")
      end
    end
  end
end
