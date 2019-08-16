require 'spec_helper'

describe 'selinux::boolean' do
  let(:title) { 'mybool' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to contain_selinux__boolean('mybool').that_requires('Anchor[selinux::module post]') }
      it { is_expected.to contain_selinux__boolean('mybool').that_comes_before('Anchor[selinux::end]') }

      ['on', true, 'present'].each do |value|
        context value do
          let(:params) do
            {
              ensure: value
            }
          end

          it do
            is_expected.to contain_selboolean('mybool').with(
              'value'      => 'on',
              'persistent' => true
            )
          end
        end
      end

      ['off', false, 'absent'].each do |value|
        context value do
          let(:params) do
            {
              ensure: value
            }
          end

          it do
            is_expected.to contain_selboolean('mybool').with(
              'value'      => 'off',
              'persistent' => true
            )
          end
        end
      end
    end
  end
end
