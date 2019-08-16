require 'spec_helper'

describe Facter::Util::Fact do # rubocop:disable RSpec/FilePath
  before(:each) do
    Facter.clear
  end

  describe 'vcsrepo_svn_ver' do
    context 'with valid value' do
      before :each do
        allow(Facter.fact(:operatingsystem)).to receive(:value).and_return('OpenBSD')
        allow(Facter::Core::Execution).to receive(:execute)
          .with('svn --version --quiet')
          .and_return('1.7.23')
      end
      it {
        expect(Facter.fact(:vcsrepo_svn_ver).value).to eq('1.7.23')
      }
    end
  end
end
