require 'spec_helper'

describe 'selinux' do
  context 'package' do
    context 'on RedHat 5 based OSes' do
      let(:facts) do
        {
          osfamily: 'RedHat',
          operatingsystem: 'RedHat',
          operatingsystemmajrelease: '5',
          selinux_current_mode: 'enforcing'
        }
      end

      it { is_expected.to contain_package('policycoreutils').with(ensure: 'present') }
    end

    %w(6).each do |majrelease|
      context "On RedHat #{majrelease} based OSes" do
        let(:facts) do
          {
            osfamily: 'RedHat',
            operatingsystem: 'RedHat',
            operatingsystemmajrelease: majrelease,
            selinux_current_mode: 'enforcing'
          }
        end

        it { is_expected.to contain_package('policycoreutils-python').with(ensure: 'present') }
      end
    end

    %w(7).each do |majrelease|
      context "On RedHat #{majrelease} based OSes" do
        let(:facts) do
          {
            osfamily: 'RedHat',
            operatingsystem: 'RedHat',
            operatingsystemmajrelease: majrelease,
            selinux_current_mode: 'enforcing'
          }
        end

        it { is_expected.to contain_package('selinux-policy-devel').with(ensure: 'present') }
      end
    end

    %w(19 20).each do |majrelease|
      context "On Fedora #{majrelease}" do
        let(:facts) do
          {
            osfamily: 'RedHat',
            operatingsystem: 'Fedora',
            operatingsystemmajrelease: majrelease,
            selinux_current_mode: 'enforcing'
          }
        end
        it { is_expected.to contain_package('policycoreutils-python').with(ensure: 'present') }
      end
    end

    %w(21 22 23).each do |majrelease|
      context "On Fedora #{majrelease}" do
        let(:facts) do
          {
            osfamily: 'RedHat',
            operatingsystem: 'Fedora',
            operatingsystemmajrelease: majrelease,
            selinux_current_mode: 'enforcing'
          }
        end
        it { is_expected.to contain_package('policycoreutils-devel').with(ensure: 'present') }
      end
    end

    %w(24).each do |majrelease|
      context "On Fedora #{majrelease}" do
        let(:facts) do
          {
            osfamily: 'RedHat',
            operatingsystem: 'Fedora',
            operatingsystemmajrelease: majrelease,
            selinux_current_mode: 'enforcing'
          }
        end
        it { is_expected.to contain_package('selinux-policy-devel').with(ensure: 'present') }
      end
    end

    context 'do not manage package' do
      let(:facts) do
        {
          osfamily: 'RedHat',
          operatingsystem: 'RedHat',
          operatingsystemmajrelease: '5'
        }
      end
      let(:params) do
        {
          manage_package: false
        }
      end

      it { is_expected.not_to contain_package('policycoreutils').with(ensure: 'present') }
    end

    context 'install a different package name' do
      let(:facts) do
        {
          osfamily: 'RedHat',
          operatingsystem: 'RedHat',
          operatingsystemmajrelease: '5'
        }
      end
      let(:params) do
        {
          package_name: 'some_package'
        }
      end

      it { is_expected.to contain_package('some_package').with(ensure: 'present') }
    end
  end
end
