require 'spec_helper'
require 'puppet/util/external_iterator'

describe Puppet::Util::ExternalIterator do
  subject_class = nil
  expected_values = nil

  before(:each) do
    subject_class = described_class.new(['a', 'b', 'c'])
    expected_values = [['a', 0], ['b', 1], ['c', 2]]
  end

  context '#next' do
    it 'iterates over the items' do
      expected_values.each do |expected_pair|
        expect(subject_class.next).to eq(expected_pair)
      end
    end
  end

  context '#peek' do
    it 'returns the 0th item repeatedly' do
      (0..2).each do |_i|
        expect(subject_class.peek).to eq(expected_values[0])
      end
    end

    it 'does not advance the iterator, but should reflect calls to #next' do
      expected_values.each do |expected_pair|
        expect(subject_class.peek).to eq(expected_pair)
        expect(subject_class.peek).to eq(expected_pair)
        expect(subject_class.next).to eq(expected_pair)
      end
    end
  end
end
