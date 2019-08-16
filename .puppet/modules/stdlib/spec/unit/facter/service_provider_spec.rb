require 'spec_helper'
require 'puppet/type'
require 'puppet/type/service'

describe 'service_provider', :type => :fact do
  before(:each) { Facter.clear }
  after(:each) { Facter.clear }

  context 'when macosx' do
    it 'returns launchd' do
      provider = Puppet::Type.type(:service).provider(:launchd)
      allow(Puppet::Type.type(:service)).to receive(:defaultprovider).and_return(provider)

      expect(Facter.fact(:service_provider).value).to eq('launchd')
    end
  end

  context 'when systemd' do
    it 'returns systemd' do
      provider = Puppet::Type.type(:service).provider(:systemd)
      allow(Puppet::Type.type(:service)).to receive(:defaultprovider).and_return(provider)

      expect(Facter.fact(:service_provider).value).to eq('systemd')
    end
  end

  context 'when redhat' do
    it 'returns redhat' do
      provider = Puppet::Type.type(:service).provider(:redhat)
      allow(Puppet::Type.type(:service)).to receive(:defaultprovider).and_return(provider)

      expect(Facter.fact(:service_provider).value).to eq('redhat')
    end
  end
end
