shared_examples 'RedHat' do

  describe 'when using default class parameters with osfamily => RedHat and major release => 6' do
    let(:params) { {} }
    let(:facts) do
      {
        :os => {
          :name => 'CentOS',
          :family => 'RedHat',
          :release => { :major => '6' }
        }
      }
    end

    it { is_expected.to create_class('timezone') }

    it do
      is_expected.to contain_package('tzdata').with(:ensure => 'present',
                                                    :before => 'File[/etc/localtime]')
    end

    it { is_expected.to contain_file('/etc/sysconfig/clock').with_ensure('file') }
    it { is_expected.to contain_file('/etc/sysconfig/clock').with_content(%r{^ZONE="Etc/UTC"$}) }
    it { is_expected.not_to contain_exec('update_timezone') }

    it do
      is_expected.to contain_file('/etc/localtime').with(:ensure => 'link',
                                                         :target => '/usr/share/zoneinfo/Etc/UTC')
    end

    context 'when timezone => "Europe/Berlin"' do
      let(:params) { { :timezone => 'Europe/Berlin' } }

      it { is_expected.to contain_file('/etc/sysconfig/clock').with_content(%r{^ZONE="Europe/Berlin"$}) }
      it { is_expected.to contain_file('/etc/localtime').with_target('/usr/share/zoneinfo/Europe/Berlin') }
    end

    context 'when autoupgrade => true' do
      let(:params) { { :autoupgrade => true } }

      it { is_expected.to contain_package('tzdata').with_ensure('latest') }
    end

    context 'when ensure => absent' do
      let(:params) { { :ensure => 'absent' } }

      it { is_expected.to contain_package('tzdata').with_ensure('present') }
      it { is_expected.to contain_file('/etc/sysconfig/clock').with_ensure('absent') }
      it { is_expected.to contain_file('/etc/localtime').with_ensure('absent') }
    end

    include_examples 'validate parameters'
  end

  describe 'when using default class parameters with osfamily => RedHat and major release => 7' do
    let(:params) { {} }
    let(:facts) do
      {
        :os => {
          :name => 'CentOS',
          :family => 'RedHat',
          :release => { :major => '7' }
        }
      }
    end

    it { is_expected.to create_class('timezone') }
    it { is_expected.not_to contain_file('/etc/sysconfig/clock') }
    it { is_expected.to contain_file('/etc/localtime').with_ensure('link') }
    it { is_expected.to contain_exec('update_timezone').with_command('timedatectl set-timezone Etc/UTC').with_unless('timedatectl status | grep "Timezone:\|Time zone:" | grep -q Etc/UTC') }

    include_examples 'validate parameters'
  end
end
