require 'spec_helper'

describe 'filebeat_version' do
  before do
    Facter.fact(:kernel).stubs(:value).returns('Linux')
  end
  context 'on a Linux host' do
    before do
      File.stubs(:executable?)
      Facter::Util::Resolution.stubs(:exec)
      File.expects(:executable?).with('/usr/bin/filebeat').returns true
      Facter::Util::Resolution.stubs(:exec).with('/usr/bin/filebeat --version').returns('filebeat version 1.3.1 (amd64)')
    end
    it 'returns the correct version' do
      expect(Facter.fact(:filebeat_version).value).to eq('1.3.1')
    end
  end
end
