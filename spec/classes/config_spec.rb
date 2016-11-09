require 'spec_helper'

describe 'kibana5::config', :type => 'class' do
  let(:facts) { UBUNTU_FACTS }

  context 'default params' do
    it do
      should compile.with_all_deps
      should_not contain_file('kibana-config-file')
    end
  end
  
  context 'config => { test hash }' do
    let(:params) {{
      :config => { 'server.host' => 'test_host' }
    }}
    it do
      should compile.with_all_deps
      should contain_file('kibana-config-file').with(
        'content' => /test_host/)
    end
  end
end
