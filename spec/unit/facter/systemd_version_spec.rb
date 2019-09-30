require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
  }

  describe "systemd_version" do
    context 'returns version when systemd fact present' do
      before do
        Facter.fact(:systemd).stubs(:value).returns(true)
      end
      let(:facts) { {:systemd => true} }
      it do
        Facter::Util::Resolution.expects(:exec).with("systemctl --version | awk '/systemd/{ print $2 }'").returns('229')
        expect(Facter.value(:systemd_version)).to eq('229')
      end
    end
    context 'returns nil when systemd fact not present' do
      before do
        Facter.fact(:systemd).stubs(:value).returns(false)
      end
      let(:facts) { {:systemd => false } }
      it do
        Facter::Util::Resolution.stubs(:exec)
        Facter::Util::Resolution.expects(:exec).with("systemctl --version | awk '/systemd/{ print $2 }'").never
        expect(Facter.value(:systemd_version)).to eq(nil)
      end
    end
  end
end
