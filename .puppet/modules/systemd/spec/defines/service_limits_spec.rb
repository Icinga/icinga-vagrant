require 'spec_helper'

describe 'systemd::service_limits' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        let(:title) { 'test.service' }

        describe 'with limits and present' do
          let(:params) {{
            :limits => {
              'LimitCPU'    => '10m',
              'LimitFSIZE'  => 'infinity',
              'LimitDATA'   => '10K',
              'LimitNOFILE' => '20:infinity',
              'LimitNICE'   => '-10',
              'LimitRTPRIO' => 50,
              'IODeviceWeight' => [
                {'/dev/weight' => 10},
                {'/dev/weight2' => 20}
              ],
              'IOReadBandwidthMax' => [
                {'/bw/max' => '10K'}
              ]
            }
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_file("/etc/systemd/system/#{title}.d/90-limits.conf").with(
            :ensure  => 'file',
              :content => /LimitCPU=10m/,
              :mode    => '0444'
          ) }
          it { is_expected.to create_file("/etc/systemd/system/#{title}.d/90-limits.conf").with(
            :content => /LimitFSIZE=infinity/
          ) }
          it { is_expected.to create_file("/etc/systemd/system/#{title}.d/90-limits.conf").with(
            :content => /LimitDATA=10K/
          ) }
          it { is_expected.to create_file("/etc/systemd/system/#{title}.d/90-limits.conf").with(
            :content => /LimitNOFILE=20:infinity/
          ) }
          it { is_expected.to create_file("/etc/systemd/system/#{title}.d/90-limits.conf").with(
            :content => /LimitNICE=-10/
          ) }
          it { is_expected.to create_file("/etc/systemd/system/#{title}.d/90-limits.conf").with(
            :content => /LimitRTPRIO=50/
          ) }
          it { is_expected.to create_file("/etc/systemd/system/#{title}.d/90-limits.conf").with(
            :content => %r(IODeviceWeight=/dev/weight 10)
          ) }
          it { is_expected.to create_file("/etc/systemd/system/#{title}.d/90-limits.conf").with(
            :content => %r(IODeviceWeight=/dev/weight2 20)
          ) }
          it { is_expected.to create_file("/etc/systemd/system/#{title}.d/90-limits.conf").with(
            :content => %r(IOReadBandwidthMax=/bw/max 10K)
          ) }
          it { is_expected.to create_exec("restart #{title} because limits").with(
            :command => "systemctl restart #{title}",
            :refreshonly => true
          ) }
        end

        describe 'ensured absent' do
          let(:params) {{
            :ensure => 'absent',
          }}

          it { is_expected.to compile.with_all_deps }
          it do
            is_expected.to create_file("/etc/systemd/system/#{title}.d/90-limits.conf")
              .with_ensure('absent')
              .that_notifies("Exec[restart #{title} because limits]")
          end
          it do
            is_expected.to create_exec("restart #{title} because limits")
              .with_command("systemctl restart #{title}")
              .with_refreshonly(true)
          end
        end
      end
    end
  end
end
