require 'spec_helper'

describe 'kibana5', :type => 'class' do
  let(:facts) { UBUNTU_FACTS }

  context 'default params' do
    it do
      should compile.with_all_deps
      should contain_class('kibana5::install')
      should contain_class('kibana5::config')
      should contain_class('kibana5::service')
    end
  end

  context 'with plugins' do
    let(:params) {{
      :plugins                 => {
        'elasticsearch/marvel' => {
         'ensure'              => 'present',
        }
      }
    }}
    it do
      should compile.with_all_deps
      should contain_kibana5__plugin('elasticsearch/marvel')
    end
  end
end
