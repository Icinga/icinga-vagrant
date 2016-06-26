require 'spec_helper'

describe 'graphite', :type => 'class' do

  context 'Unsupported OS' do
    let(:facts) {{ :osfamily => 'unsupported', :operatingsystem => 'UnknownOS' }}
    it { is_expected.to raise_error(Puppet::Error,/unsupported os,.+\./ )}
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('graphite::params') }
      it { is_expected.to contain_anchor('graphite::begin').that_comes_before('Class[graphite::install]') }
      it { is_expected.to contain_class('graphite::install').that_notifies('Class[graphite::config]') }
      it { is_expected.to contain_class('graphite::config').that_comes_before('Anchor[graphite::end]') }
      it { is_expected.to contain_anchor('graphite::end') }

    end
  end

end
