require 'spec_helper'
require 'puppet/util/external_iterator'

describe Puppet::Util::ExternalIterator do
  let(:subject) { Puppet::Util::ExternalIterator.new(["a", "b", "c"]) }

  context "#next" do
    it "should iterate over the items" do
      expect(subject.next).to eq(["a", 0])
      expect(subject.next).to eq(["b", 1])
      expect(subject.next).to eq(["c", 2])      
    end
  end

  context "#peek" do
    it "should return the 0th item repeatedly" do
      expect(subject.peek).to eq(["a", 0])
      expect(subject.peek).to eq(["a", 0])
    end
    
    it "should not advance the iterator, but should reflect calls to #next" do
      expect(subject.peek).to eq(["a", 0])
      expect(subject.peek).to eq(["a", 0])
      expect(subject.next).to eq(["a", 0])
      expect(subject.peek).to eq(["b", 1])
      expect(subject.next).to eq(["b", 1])
      expect(subject.peek).to eq(["c", 2])
      expect(subject.next).to eq(["c", 2])
      expect(subject.peek).to eq([nil, nil])
      expect(subject.next).to eq([nil, nil])
    end
  end


end
