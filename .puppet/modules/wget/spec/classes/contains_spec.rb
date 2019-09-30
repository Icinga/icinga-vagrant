# To check the correct dependencies are set up for wget.

require 'spec_helper'
describe 'wget' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      describe 'Testing the dependancies between the classes' do
        it { is_expected.to contain_class('wget::install') }
        it { is_expected.to contain_class('wget::config') }
        it { is_expected.to contain_class('wget::install').that_comes_before('Class[wget::config]') }
      end
    end
  end
end
