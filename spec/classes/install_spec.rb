require 'spec_helper'

describe 'kibana5::install', :type => 'class' do
  context 'redhat' do
    let(:facts) {{
      :osfamily => 'RedHat'
    }}
    it do
      should compile.with_all_deps
      should contain_yumrepo('kibana-5.x').with(
        'baseurl' => /packages\/5.x\//,
        'descr'   => /for 5.x/)
      should contain_package('kibana5').with(
        'ensure' => '5.0.0')
    end
  end

  context 'debian' do
    let(:facts) { UBUNTU_FACTS }
    it do
      should compile.with_all_deps
      should contain_class('apt')
      should contain_apt__source('kibana-5.x').with(
        'location' => /packages\/5.x\//)
      should contain_package('kibana5').with(
        'ensure' => '5.0.0')
    end
  end

  context 'manage_repo => false' do
    let(:facts) { UBUNTU_FACTS }
    let(:params) {{ :manage_repo => false }}
    it do
      should compile.with_all_deps
      should_not contain_class('apt')
      should_not contain_yumrepo('kibana-5.x')
      should_not contain_apt__source('kibana-5.x')

      should contain_package('kibana5').with(
        'ensure' => '5.0.0')
    end
  end

end
