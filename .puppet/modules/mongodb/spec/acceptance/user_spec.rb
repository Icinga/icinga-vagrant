require 'spec_helper_acceptance'

describe 'mongodb_database' do
  context 'with default port' do
    it 'compiles with no errors' do
      pp = <<-EOS
        class { 'mongodb::server': }
        -> class { 'mongodb::client': }
        -> mongodb_database { 'testdb': ensure => present }
        ->
        mongodb_user {'testuser':
          ensure        => present,
          password_hash => mongodb_password('testuser', 'passw0rd'),
          database      => 'testdb',
        }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'creates the user' do
      shell("mongo testdb --quiet --eval 'db.auth(\"testuser\",\"passw0rd\")'") do |r|
        expect(r.stdout.chomp).to eq('1')
      end
    end
  end

  context 'with custom port' do
    it 'works with no errors' do
      pp = <<-EOS
        class { 'mongodb::server': port => 27018 }
        -> class { 'mongodb::client': }
        -> mongodb_database { 'testdb': ensure => present }
        ->
        mongodb_user {'testuser':
          ensure        => present,
          password_hash => mongodb_password('testuser', 'passw0rd'),
          database      => 'testdb',
        }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'creates the user' do
      shell("mongo testdb --quiet --port 27018 --eval 'db.auth(\"testuser\",\"passw0rd\")'") do |r|
        expect(r.stdout.chomp).to eq('1')
      end
    end
  end
end
