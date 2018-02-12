require 'spec_helper'

describe 'graphite', :type => 'class' do

  context 'Unsupported OS' do
    let(:facts) {{ :osfamily => 'unsupported', :operatingsystem => 'UnknownOS' }}
    it { is_expected.to raise_error(Puppet::Error,/unsupported os,.+\./ )}
  end

  shared_context 'Graphite 0.9 cluster settings' do
    let(:params) {{
      :gr_graphite_ver => '0.9.16',
      :gr_cluster_servers => [ '10.0.0.1', '10.0.0.2' ],
      :gr_cluster_fetch_timeout => 6,
      :gr_cluster_find_timeout => 2,
      :gr_cluster_retry_delay => 10,
      :gr_cluster_cache_duration => 120,
    }}

    it { is_expected.to contain_file('/opt/graphite/webapp/graphite/local_settings.py').with_content(/REMOTE_STORE_FETCH_TIMEOUT = 6/) }
    it { is_expected.to contain_file('/opt/graphite/webapp/graphite/local_settings.py').with_content(/REMOTE_STORE_FIND_TIMEOUT = 2/) }
    it { is_expected.to contain_file('/opt/graphite/webapp/graphite/local_settings.py').with_content(/REMOTE_STORE_RETRY_DELAY = 10/) }
    it { is_expected.to contain_file('/opt/graphite/webapp/graphite/local_settings.py').with_content(/REMOTE_FIND_CACHE_DURATION = 120/) }

  end

  shared_context 'Graphite 1.0 cluster settings' do
    let(:params) {{
      :gr_graphite_ver => '1.1.1',
      :gr_cluster_servers => [ '10.0.0.1', '10.0.0.2' ],
      :gr_cluster_fetch_timeout => 6,
      :gr_cluster_find_timeout => 2,
      :gr_cluster_retry_delay => 10,
      :gr_cluster_cache_duration => 120,
    }}

    it { is_expected.to contain_file('/opt/graphite/webapp/graphite/local_settings.py').with_content(/REMOTE_FETCH_TIMEOUT = 6/) }
    it { is_expected.to contain_file('/opt/graphite/webapp/graphite/local_settings.py').with_content(/REMOTE_FIND_TIMEOUT = 2/) }
    it { is_expected.to contain_file('/opt/graphite/webapp/graphite/local_settings.py').with_content(/REMOTE_RETRY_DELAY = 10/) }
    it { is_expected.to contain_file('/opt/graphite/webapp/graphite/local_settings.py').with_content(/FIND_CACHE_DURATION = 120/) }

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

      it_behaves_like 'Graphite 0.9 cluster settings'
      it_behaves_like 'Graphite 1.0 cluster settings'

    end
  end

end
