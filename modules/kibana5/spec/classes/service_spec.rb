require 'spec_helper'

describe 'kibana5::service', :type => 'class' do
  context 'ubuntu' do
    let(:facts) { UBUNTU_FACTS }
    it do
      should compile.with_all_deps
      should contain_service('kibana5').with(
        'ensure'   => true,
        'enable'   => true,
        'provider' => 'debian')
    end
  end

  context 'redhat-7' do
    let(:facts) {{
      :osfamily                  => 'RedHat',
      :operatingsystemmajrelease => '7',
    }}
    it do
      should compile.with_all_deps
      should contain_service('kibana5').with(
        'ensure'   => true,
        'enable'   => true,
        'provider' => 'systemd')
    end
  end

  context 'redhat-8' do
    let(:facts) {{
      :osfamily                  => 'RedHat',
      :operatingsystemmajrelease => '8',
    }}
    it do
      should compile.with_all_deps
      should contain_service('kibana5').with(
        'ensure'   => true,
        'enable'   => true,
        'provider' => 'init')
    end
  end

end
