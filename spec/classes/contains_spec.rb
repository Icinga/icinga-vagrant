# To check the correct dependencies are set up for wget.

require 'spec_helper'
describe 'wget' do
  let(:facts) {{ :is_virtual => 'false' }}

  on_supported_os.select { |_, f| f[:os]['family'] != 'Solaris' }.each do |os, f|
    context "on #{os}" do
      let(:facts) do
        f.merge(super())
      end

      it { is_expected.to compile.with_all_deps }
      describe "Testing the dependancies between the classes" do
        it { should contain_class('wget::install') }
        it { should contain_class('wget::config') }
        it { is_expected.to contain_class('wget::install').that_comes_before('Class[wget::config]') }
      end
    end
  end
end