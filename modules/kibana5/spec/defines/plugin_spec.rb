require 'spec_helper'

describe 'kibana5::plugin', :type => 'define' do
  let(:title) { 'UNITTEST' }
  let(:facts) { UBUNTU_FACTS }

  context 'simple marvel example' do
    let(:params) {{
      :ensure          => 'present',
    }}
    it do
      should compile.with_all_deps
      should contain_exec('install_kibana_plugin_UNITTEST').with(
        'command' => '/usr/share/kibana/bin/kibana-plugin install UNITTEST')
    end
  end

  context 'simple marvel example absent' do
    let(:params) {{
      :ensure          => 'absent',
    }}
    it do
      should compile.with_all_deps
      should contain_exec('remove_kibana_plugin_UNITTEST')
    end
  end
end
