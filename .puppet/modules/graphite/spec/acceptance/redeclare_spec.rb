require 'spec_helper_acceptance'

describe 'graphite class' do

  context 'has packages declared twice' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      package{ 'gcc': ensure => installed }
      class { 'graphite': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
    end
  end
end