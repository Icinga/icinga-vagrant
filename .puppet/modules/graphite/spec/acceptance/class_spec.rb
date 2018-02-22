require 'spec_helper_acceptance'

describe 'graphite class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'graphite': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_failures => true)
    end
    describe port('2003') do
      it { should be_listening.with('tcp') }
      it { should_not be_listening.with('udp') }
    end
    describe port('2023') do
      it { should_not be_listening.with('tcp') }
      it { should_not be_listening.with('udp') }
    end
  end
  context 'with TCP & UDP carbon-cache and TCP & UDP carbon-aggregator configured' do
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'graphite':
        gr_enable_udp_listener            => 'True',
        gr_enable_carbon_aggregator       => true,
        gr_aggregator_enable_udp_listener => 'True'
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_failures => true)
    end
    describe port('2003') do
      it { should be_listening.with('tcp') }
      it { should be_listening.with('udp') }
    end
    describe port('2023') do
      it { should be_listening.with('tcp') }
      it { should be_listening.with('udp') }
    end
  end
end