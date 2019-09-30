require "spec_helper"

describe Facter::Util::Fact do
  before { Facter.clear }
  after { Facter.clear }

  describe 'systemd' do
    context 'returns true when systemd present' do
      before do
        Facter.fact(:kernel).stubs(:value).returns(:linux)
        Facter.add(:service_provider) { setcode { 'systemd' } }
      end

      it { expect(Facter.value(:service_provider)).to eq('systemd') }
      it { expect(Facter.value(:systemd)).to be true }
    end

    context 'returns false when systemd not present' do
      before do
        Facter.fact(:kernel).stubs(:value).returns(:linux)
        Facter.add(:service_provider) { setcode { 'redhat' } }
      end

      it { expect(Facter.value(:service_provider)).to eq('redhat') }
      it { expect(Facter.value(:systemd)).to be false }
    end

    context 'returns nil when kernel is not linux' do
      before do
        Facter.fact(:kernel).stubs(:value).returns(:windows)
      end

      it { expect(Facter.value(:systemd)).to be_nil }
    end
  end
end
