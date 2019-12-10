require 'spec_helper'

describe 'docker', type: :class do
  ['Debian', 'Ubuntu', 'RedHat'].each do |osfamily|
    context "on #{osfamily}" do
      if osfamily == 'Debian'
        let(:facts) do
          {
            architecture: 'amd64',
            osfamily: 'Debian',
            operatingsystem: 'Debian',
            lsbdistid: 'Debian',
            lsbdistcodename: 'stretch',
            kernelrelease: '4.9.0-3-amd64',
            operatingsystemrelease: '9.0',
            operatingsystemmajrelease: '9',
            os: { distro: { codename: 'wheezy' }, family: 'Debian', name: 'Debian', release: { major: '7', full: '7.0' } },
          }
        end

        service_config_file = '/etc/default/docker'
        storage_config_file = '/etc/default/docker-storage'

        context 'It should include default prerequired_packages' do
          it { is_expected.to contain_package('cgroupfs-mount').with_ensure('present') }
        end
      end

      if osfamily == 'Ubuntu'
        let(:facts) do
          {
            architecture: 'amd64',
            osfamily: 'Debian',
            operatingsystem: 'Ubuntu',
            lsbdistid: 'Ubuntu',
            lsbdistcodename: 'xenial',
            kernelrelease: '4.4.0-21-generic',
            operatingsystemrelease: '16.04',
            operatingsystemmajrelease: '16.04',
            os: { distro: { codename: 'wheezy' }, family: 'Debian', name: 'Debian', release: { major: '7', full: '7.0' } },
          }
        end

        service_config_file = '/etc/default/docker'
        storage_config_file = '/etc/default/docker-storage'

        it { is_expected.to contain_service('docker').with_hasrestart('true') }

        context 'It should include default prerequired_packages' do
          it { is_expected.to contain_package('cgroup-lite').with_ensure('present') }
          it { is_expected.to contain_package('apparmor').with_ensure('present') }
        end
      end

      if ['Debian', 'Ubuntu'].include?(osfamily)
        it { is_expected.to contain_class('apt') }
        it { is_expected.to contain_package('docker').with_name('docker-ce').with_ensure('present') }
        it {
          is_expected.to contain_apt__pin('docker')
            .with_ensure('present')
            .with_origin('download.docker.com')
            .with_priority(500)
        }
        it { is_expected.to contain_package('docker').with_install_options(nil) }
        it { is_expected.to contain_file('/etc/default/docker').without_content(%r{icc=}) }
      end

      if osfamily == 'Ubuntu'
        it { is_expected.to contain_apt__source('docker').with_location('https://download.docker.com/linux/ubuntu') }
      end

      if osfamily == 'Debian'
        it { is_expected.to contain_apt__source('docker').with_location('https://download.docker.com/linux/debian') }
      end

      if ['Debian', 'Ubuntu'].include?(osfamily)

        context 'with a custom version' do
          let(:params) { { 'version' => '1.7.0' } }

          it { is_expected.to contain_package('docker').with_ensure('1.7.0').with_name('docker-engine') }
        end

        context 'with no upstream package source' do
          let(:params) { { 'use_upstream_package_source' => false } }

          it { is_expected.not_to contain_apt__source('docker') }
          it { is_expected.not_to contain_apt__pin('docker') }
          it { is_expected.to contain_package('docker').with_name('docker-ce') }
        end

        context 'with no upstream package source' do
          let(:params) { { 'use_upstream_package_source' => false } }

          it { is_expected.not_to contain_apt__source('docker') }
          it { is_expected.not_to contain_apt__pin('docker') }
          it { is_expected.to contain_package('docker') }
        end

        context 'with no package pinning' do
          let(:params) { { 'pin_upstream_package_source' => false } }

          it { is_expected.to contain_apt__pin('docker').with_ensure('absent') }
        end

        context 'with different package pinning priority' do
          let(:params) do
            {
              'pin_upstream_package_source' => true,
              'apt_source_pin_level' => 900,
            }
          end

          it { is_expected.to contain_apt__pin('docker').with_priority(900) }
        end

        context 'when given a specific tmp_dir' do
          let(:params) { { 'tmp_dir' => '/bigtmp' } }

          it { is_expected.to contain_file('/etc/default/docker').with_content(%r{TMPDIR="\/bigtmp"}) }
        end

        context 'with ip_forwaring param set to false' do
          let(:params) { { 'ip_forward' => false } }

          it { is_expected.to contain_file('/etc/default/docker').with_content(%r{ip-forward=false}) }
        end

        context 'with ip_masq param set to false' do
          let(:params) { { 'ip_masq' => false } }

          it { is_expected.to contain_file('/etc/default/docker').with_content(%r{ip-masq=false}) }
        end

        context 'with iptables param set to false' do
          let(:params) { { 'iptables' => false } }

          it { is_expected.to contain_file('/etc/default/docker').with_content(%r{iptables=false}) }
        end

        context 'with icc param set to false' do
          let(:params) { { 'icc' => false } }

          it { is_expected.to contain_file('/etc/default/docker').with_content(%r{icc=false}) }
        end

        context 'with tcp_bind array param' do
          let(:params) { { 'tcp_bind' => ['tcp://127.0.0.1:2375', 'tcp://10.0.0.1:2375'] } }

          it do
            is_expected.to contain_file('/etc/default/docker').with_content(
              %r{tcp:\/\/127.0.0.1:2375 -H tcp:\/\/10.0.0.1:2375},
            )
          end
        end
        context 'with tcp_bind string param' do
          let(:params) { { 'tcp_bind' => 'tcp://127.0.0.1:2375' } }

          it do
            is_expected.to contain_file('/etc/default/docker').with_content(
              %r{tcp:\/\/127.0.0.1:2375},
            )
          end
        end
        context 'with tls param' do
          let(:params) do
            {
              'tcp_bind' => 'tcp://127.0.0.1:2375',
              'tls_enable' => true,
            }
          end

          it do
            is_expected.to contain_file('/etc/default/docker').with_content(
              %r{tcp:\/\/127.0.0.1:2375},
            )
            is_expected.to contain_file('/etc/default/docker').with_content(
              %r{--tls --tlsverify --tlscacert=\/etc\/docker\/tls\/ca.pem --tlscert=\/etc\/docker\/tls\/cert.pem --tlskey=\/etc\/docker\/tls\/key.pem},
            )
          end
        end
        context 'with tls param and without tlsverify' do
          let(:params) do
            {
              'tcp_bind' => 'tcp://127.0.0.1:2375',
              'tls_enable' => true,
              'tls_verify' => false,
            }
          end

          it do
            is_expected.to contain_file('/etc/default/docker').with_content(
              %r{tcp:\/\/127.0.0.1:2375},
            )
            is_expected.to contain_file('/etc/default/docker').with_content(
              %r{--tls --tlscacert=\/etc\/docker\/tls\/ca.pem --tlscert=\/etc\/docker\/tls\/cert.pem --tlskey=\/etc\/docker\/tls\/key.pem},
            )
          end
        end

        context 'with fixed_cidr and bridge params' do
          let(:params) do
            {
              'fixed_cidr' => '10.0.0.0/24',
              'bridge' => 'br0',
            }
          end

          it { is_expected.to contain_file('/etc/default/docker').with_content(%r{fixed-cidr 10.0.0.0\/24}) }
        end

        context 'with ipv6 params' do
          let(:params) do
            {
              'ipv6' => true,
              'ipv6_cidr' => '2001:db8:1::/64',
              'default_gateway_ipv6' => 'fe80::2d4:12ff:fef6:67a2/16',
            }
          end

          it { is_expected.to contain_file('/etc/default/docker').with_content(%r{--ipv6}) }
          it { is_expected.to contain_file('/etc/default/docker').with_content(%r{--fixed-cidr-v6 2001:db8:1::\/64}) }
          it { is_expected.to contain_file('/etc/default/docker').with_content(%r{--default-gateway-v6 fe80::2d4:12ff:fef6:67a2\/16}) }
        end

        context 'with default_gateway and bridge params' do
          let(:params) do
            {
              'default_gateway' => '10.0.0.1',
              'bridge' => 'br0',
            }
          end

          it { is_expected.to contain_file('/etc/default/docker').with_content(%r{default-gateway 10.0.0.1}) }
        end

        context 'with bridge param' do
          let(:params) { { 'bridge' => 'br0' } }

          it { is_expected.to contain_file('/etc/default/docker').with_content(%r{bridge br0}) }
        end

        context 'with custom service_name' do
          let(:params) { { 'service_name' => 'docker.io' } }

          it { is_expected.to contain_file('/etc/default/docker.io') }
        end
      end

      if osfamily == 'RedHat'
        let(:facts) do
          {
            architecture: 'x86_64',
            osfamily: osfamily,
            operatingsystem: 'RedHat',
            operatingsystemrelease: '7.2',
            operatingsystemmajrelease: '7',
            kernelversion: '3.10.0',
          }
        end

        service_config_file = '/etc/sysconfig/docker'
        storage_config_file = '/etc/sysconfig/docker-storage'

        it { is_expected.to contain_file('/etc/sysconfig/docker').without_content(%r{icc=}) }

        context 'with proxy param' do
          let(:params) { { 'proxy' => 'http://127.0.0.1:3128' } }

          it { is_expected.to contain_file(service_config_file).with_content(%r{http_proxy='http:\/\/127.0.0.1:3128'}) }
          it { is_expected.to contain_file(service_config_file).with_content(%r{https_proxy='http:\/\/127.0.0.1:3128'}) }
        end

        context 'with no_proxy param' do
          let(:params) { { 'no_proxy' => '.github.com' } }

          it { is_expected.to contain_file(service_config_file).with_content(%r{no_proxy='.github.com'}) }
        end

        context 'with registry_mirror param set to mirror value' do
          let(:params) { { 'registry_mirror' => 'https://mirror.gcr.io' } }

          it { is_expected.to contain_file('/etc/sysconfig/docker').with_content(%r{registry-mirror}) }
        end

        context 'when given a specific tmp_dir' do
          let(:params) { { 'tmp_dir' => '/bigtmp' } }

          it { is_expected.to contain_file('/etc/sysconfig/docker').with_content(%r{TMPDIR="\/bigtmp"}) }
        end

        context 'with ip_forwaring param set to false' do
          let(:params) { { 'ip_forward' => false } }

          it { is_expected.to contain_file('/etc/sysconfig/docker').with_content(%r{ip-forward=false}) }
        end

        context 'with ip_masq param set to false' do
          let(:params) { { 'ip_masq' => false } }

          it { is_expected.to contain_file('/etc/sysconfig/docker').with_content(%r{ip-masq=false}) }
        end

        context 'with iptables param set to false' do
          let(:params) { { 'iptables' => false } }

          it { is_expected.to contain_file('/etc/sysconfig/docker').with_content(%r{iptables=false}) }
        end

        context 'with icc param set to false' do
          let(:params) { { 'icc' => false } }

          it { is_expected.to contain_file('/etc/sysconfig/docker').with_content(%r{icc=false}) }
        end

        context 'with tcp_bind array param' do
          let(:params) { { 'tcp_bind' => ['tcp://127.0.0.1:2375', 'tcp://10.0.0.1:2375'] } }

          it do
            is_expected.to contain_file('/etc/sysconfig/docker').with_content(
              %r{tcp:\/\/127.0.0.1:2375 -H tcp:\/\/10.0.0.1:2375},
            )
          end
        end
        context 'with tcp_bind string param' do
          let(:params) { { 'tcp_bind' => 'tcp://127.0.0.1:2375' } }

          it do
            is_expected.to contain_file('/etc/sysconfig/docker').with_content(
              %r{tcp:\/\/127.0.0.1:2375},
            )
          end
        end
        context 'with tls param' do
          let(:params) do
            {
              'tcp_bind' => 'tcp://127.0.0.1:2375',
              'tls_enable' => true,
            }
          end

          it do
            is_expected.to contain_file('/etc/sysconfig/docker').with_content(
              %r{tcp:\/\/127.0.0.1:2375},
            )
            is_expected.to contain_file('/etc/sysconfig/docker').with_content(
              %r{--tls --tlsverify --tlscacert=\/etc\/docker\/tls\/ca.pem --tlscert=\/etc\/docker\/tls\/cert.pem --tlskey=\/etc\/docker\/tls\/key.pem},
            )
          end
        end
        context 'with tls param and without tlsverify' do
          let(:params) do
            {
              'tcp_bind' => 'tcp://127.0.0.1:2375',
              'tls_enable' => true,
              'tls_verify' => false,
            }
          end

          it do
            is_expected.to contain_file('/etc/sysconfig/docker').with_content(
              %r{tcp:\/\/127.0.0.1:2375},
            )
            is_expected.to contain_file('/etc/sysconfig/docker').with_content(
              %r{--tls --tlscacert=\/etc\/docker\/tls\/ca.pem --tlscert=\/etc\/docker\/tls\/cert.pem --tlskey=\/etc\/docker\/tls\/key.pem},
            )
          end
        end

        context 'with fixed_cidr and bridge params' do
          let(:params) do
            {
              'fixed_cidr' => '10.0.0.0/24',
              'bridge' => 'br0',
            }
          end

          it { is_expected.to contain_file('/etc/sysconfig/docker').with_content(%r{fixed-cidr 10.0.0.0\/24}) }
        end

        context 'with default_gateway and bridge params' do
          let(:params) do
            {
              'default_gateway' => '10.0.0.1',
              'bridge' => 'br0',
            }
          end

          it { is_expected.to contain_file('/etc/sysconfig/docker').with_content(%r{default-gateway 10.0.0.1}) }
        end

        context 'with bridge param' do
          let(:params) { { 'bridge' => 'br0' } }

          it { is_expected.to contain_file('/etc/sysconfig/docker').with_content(%r{bridge br0}) }
        end

        context 'when given specific storage options' do
          let(:params) do
            {
              'storage_driver' => 'devicemapper',
              'dm_basesize' => '3G',
            }
          end

          it { is_expected.to contain_file('/etc/sysconfig/docker-storage').with_content(%r{^(DOCKER_STORAGE_OPTIONS=" --storage-driver devicemapper --storage-opt dm.basesize=3G)}) }
        end

        context 'It should include default prerequired_packages' do
          it { is_expected.to contain_package('device-mapper').with_ensure('present') }
        end

        context 'It should install from rpm package' do
          let(:params) do
            {
              'manage_package' => true,
              'use_upstream_package_source' => false,
              'docker_engine_package_name'  => 'docker-engine',
              'package_source'              => 'https://get.docker.com/rpm/1.7.0/centos-7/RPMS/x86_64/docker-engine-1.7.0-1.el7.x86_64.rpm',
            }
          end

          it do
            is_expected.to contain_package('docker').with(
              'ensure' => 'present',
              'source' => 'https://get.docker.com/rpm/1.7.0/centos-7/RPMS/x86_64/docker-engine-1.7.0-1.el7.x86_64.rpm',
              'name'   => 'docker-engine',
            )
          end
        end

        context 'It should install from rpm package with docker::repo_opt set' do
          let(:params) do
            {
              'manage_package' => true,
              'use_upstream_package_source' => false,
              'docker_engine_package_name'  => 'docker-engine',
              'package_source'              => 'https://get.docker.com/rpm/1.7.0/centos-7/RPMS/x86_64/docker-engine-1.7.0-1.el7.x86_64.rpm',
              'repo_opt'                    => '--enablerepo=rhel7-extras',
            }
          end

          it do
            is_expected.to contain_package('docker').with(
              'ensure'          => 'present',
              'source'          => 'https://get.docker.com/rpm/1.7.0/centos-7/RPMS/x86_64/docker-engine-1.7.0-1.el7.x86_64.rpm',
              'name'            => 'docker-engine',
              'install_options' => '--enablerepo=rhel7-extras',
            )
          end
        end

        context 'It uses default docker::repo_opt' do
          let(:params) do
            {
              'manage_package' => true,
              'use_upstream_package_source' => false,
              'docker_engine_package_name'  => 'docker-engine',
              'package_source'              => 'https://get.docker.com/rpm/1.7.0/centos-7/RPMS/x86_64/docker-engine-1.7.0-1.el7.x86_64.rpm',
            }
          end

          it do
            is_expected.to contain_package('docker').with(
              'ensure'          => 'present',
              'source'          => 'https://get.docker.com/rpm/1.7.0/centos-7/RPMS/x86_64/docker-engine-1.7.0-1.el7.x86_64.rpm',
              'name'            => 'docker-engine',
              'install_options' => '--enablerepo=rhel-7-server-extras-rpms',
            )
          end
        end

        context 'It allows overwriting docker::repo_opt with empty string' do
          let(:params) do
            {
              'manage_package' => true,
              'use_upstream_package_source' => false,
              'docker_engine_package_name'  => 'docker-engine',
              'package_source'              => 'https://get.docker.com/rpm/1.7.0/centos-7/RPMS/x86_64/docker-engine-1.7.0-1.el7.x86_64.rpm',
              'repo_opt'                    => '',
            }
          end

          it do
            is_expected.to contain_package('docker').with(
              'ensure'          => 'present',
              'source'          => 'https://get.docker.com/rpm/1.7.0/centos-7/RPMS/x86_64/docker-engine-1.7.0-1.el7.x86_64.rpm',
              'name'            => 'docker-engine',
              'install_options' => nil,
            )
          end
        end

      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('docker::repos').that_comes_before('Class[docker::install]') }
      it { is_expected.to contain_class('docker::install').that_comes_before('Class[docker::config]') }
      it { is_expected.to contain_class('docker::config').that_comes_before('Class[docker::service]') }

      it { is_expected.to contain_file(service_config_file).without_content(%r{icc=}) }

      # storage_config_file = '/etc/default/docker-storage'

      context 'with a specific docker command' do
        let(:params) { { 'docker_ce_start_command' => 'docker.io' } }

        it { is_expected.to contain_file('/etc/systemd/system/docker.service.d/service-overrides.conf').with_content(%r{docker.io}) }
      end

      context 'with an extra After entry' do
        let(:params) { { 'service_after_override' => 'containerd.service' } }

        it { is_expected.to contain_file('/etc/systemd/system/docker.service.d/service-overrides.conf').with_content(%r{containerd.service}) }
      end

      context 'with a specific socket group and override' do
        let(:params) do
          {
            'socket_group' => 'root',
            'socket_override' => true,
          }
        end

        it { is_expected.to contain_file('/etc/systemd/system/docker.socket.d/socket-overrides.conf').with_content(%r{root}) }
      end

      context 'with a custom package name' do
        let(:params) { { 'docker_ce_package_name' => 'docker-custom-pkg-name' } }

        it { is_expected.to contain_package('docker').with_name('docker-custom-pkg-name').with_ensure('present') }
      end

      context 'with a custom package name and version' do
        let(:params) do
          {
            'version' => '17.06.2~ce-0~debian',
            'docker_ce_package_name' => 'docker-custom-pkg-name',
          }
        end

        it { is_expected.to contain_package('docker').with_name('docker-custom-pkg-name').with_ensure('17.06.2~ce-0~debian') }
      end

      context 'when not managing the package' do
        let(:params) { { 'manage_package' => false } }

        skip 'the APT module at v2.1 does not support STRICT_VARIABLES' do
          it { is_expected.not_to contain_package('docker') }
        end
      end

      context 'It should accept custom prerequired_packages' do
        let(:params) do
          { 'prerequired_packages' => ['test_package'],
            'manage_package' => false }
        end

        skip 'the APT module at v2.1 does not support STRICT_VARIABLES' do
          it { is_expected.to contain_package('test_package').with_ensure('present') }
        end
      end

      context 'with proxy param' do
        let(:params) { { 'proxy' => 'http://127.0.0.1:3128' } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{http_proxy='http:\/\/127.0.0.1:3128'}) }
        it { is_expected.to contain_file(service_config_file).with_content(%r{https_proxy='http:\/\/127.0.0.1:3128'}) }
      end

      context 'with no_proxy param' do
        let(:params) { { 'no_proxy' => '.github.com' } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{no_proxy='.github.com'}) }
      end

      context 'with execdriver param lxc' do
        let(:params) { { 'execdriver' => 'lxc' } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{-e lxc}) }
      end

      context 'with execdriver param native' do
        let(:params) { { 'execdriver' => 'native' } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{-e native}) }
      end

      ['aufs', 'devicemapper', 'btrfs', 'overlay', 'overlay2', 'vfs', 'zfs'].each do |driver|
        context "with #{driver} storage driver" do
          let(:params) { { 'storage_driver' => driver } }

          it { is_expected.to contain_file(storage_config_file).with_content(%r{ --storage-driver #{driver}}) }
        end
      end

      context 'with thinpool device param' do
        let(:params) do
          { 'storage_driver' => 'devicemapper',
            'dm_thinpooldev' => '/dev/mapper/vg_test-docker--pool' }
        end

        it { is_expected.to contain_file(storage_config_file).with_content(%r{--storage-opt dm\.thinpooldev=\/dev\/mapper\/vg_test-docker--pool}) }
      end

      context 'with use deferred removal param' do
        let(:params) do
          { 'storage_driver' => 'devicemapper',
            'dm_use_deferred_removal' => true }
        end

        it { is_expected.to contain_file(storage_config_file).with_content(%r{--storage-opt dm\.use_deferred_removal=true}) }
      end

      context 'with use deferred deletion param' do
        let(:params) do
          { 'storage_driver' => 'devicemapper',
            'dm_use_deferred_deletion' => true }
        end

        it { is_expected.to contain_file(storage_config_file).with_content(%r{--storage-opt dm\.use_deferred_deletion=true}) }
      end

      context 'with block discard param' do
        let(:params) do
          { 'storage_driver' => 'devicemapper',
            'dm_blkdiscard' => true }
        end

        it { is_expected.to contain_file(storage_config_file).with_content(%r{--storage-opt dm\.blkdiscard=true}) }
      end

      context 'with override udev sync check param' do
        let(:params) do
          { 'storage_driver' => 'devicemapper',
            'dm_override_udev_sync_check' => true }
        end

        it { is_expected.to contain_file(storage_config_file).with_content(%r{--storage-opt dm\.override_udev_sync_check=true}) }
      end

      context 'without execdriver param' do
        it { is_expected.not_to contain_file(service_config_file).with_content(%r{-e lxc}) }
        it { is_expected.not_to contain_file(service_config_file).with_content(%r{-e native}) }
      end

      context 'with multi dns param' do
        let(:params) { { 'dns' => ['8.8.8.8', '8.8.4.4'] } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{--dns 8.8.8.8}).with_content(%r{--dns 8.8.4.4}) }
      end

      context 'with dns param' do
        let(:params) { { 'dns' => '8.8.8.8' } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{--dns 8.8.8.8}) }
      end

      context 'with multi dns_search param' do
        let(:params) { { 'dns_search' => ['my.domain.local', 'other-domain.de'] } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{--dns-search my.domain.local}).with_content(%r{--dns-search other-domain.de}) }
      end

      context 'with dns_search param' do
        let(:params) { { 'dns_search' => 'my.domain.local' } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{--dns-search my.domain.local}) }
      end

      context 'with multi extra parameters' do
        let(:params) { { 'extra_parameters' => ['--this this', '--that that'] } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{--this this}) }
        it { is_expected.to contain_file(service_config_file).with_content(%r{--that that}) }
      end

      context 'with a string extra parameters' do
        let(:params) { { 'extra_parameters' => '--this this' } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{--this this}) }
      end

      context 'with multi shell values' do
        let(:params) { { 'shell_values' => ['--this this', '--that that'] } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{--this this}) }
        it { is_expected.to contain_file(service_config_file).with_content(%r{--that that}) }
      end

      context 'with a string shell values' do
        let(:params) { { 'shell_values' => '--this this' } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{--this this}) }
      end

      context 'with socket group set' do
        let(:params) { { 'socket_group' => 'notdocker' } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{-G notdocker}) }
      end

      context 'with labels set' do
        let(:params) { { 'labels' => ['storage=ssd', 'stage=production'] } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{--label storage=ssd}) }
        it { is_expected.to contain_file(service_config_file).with_content(%r{--label stage=production}) }
      end

      context 'with service_state set to stopped' do
        let(:params) { { 'service_state' => 'stopped' } }

        it { is_expected.to contain_service('docker').with_ensure('stopped') }
      end

      context 'with a custom service name' do
        let(:params) { { 'service_name' => 'docker.io' } }

        it { is_expected.to contain_service('docker').with_name('docker.io') }
      end

      context 'with service_enable set to false' do
        let(:params) { { 'service_enable' => false } }

        it { is_expected.to contain_service('docker').with_enable('false') }
      end

      context 'with service_enable set to true' do
        let(:params) { { 'service_enable' => true } }

        it { is_expected.to contain_service('docker').with_enable('true') }
      end

      context 'with service_manage set to false' do
        let(:params) { { 'manage_service' => false } }

        it { is_expected.not_to contain_service('docker') }
      end

      context 'with specific log_level' do
        let(:params) { { 'log_level' => 'debug' } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{-l debug}) }
      end

      context 'with an invalid log_level' do
        let(:params) { { 'log_level' => 'verbose' } }

        it do
          expect {
            is_expected.to contain_package('docker')
          }.to raise_error(Puppet::Error, %r{log_level must be one of debug, info, warn, error or fatal})
        end
      end

      context 'with specific log_driver' do
        let(:params) { { 'log_driver' => 'json-file' } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{--log-driver json-file}) }
      end

      context 'with an invalid log_driver' do
        let(:params) { { 'log_driver' => 'etwlogs' } }

        it do
          expect {
            is_expected.to contain_package('docker')
          }.to raise_error(Puppet::Error, %r{log_driver must be one of none, json-file, syslog, journald, gelf, fluentd, splunk or awslogs})
        end
      end

      context 'with specific log_driver and log_opt' do
        let(:params) do
          { 'log_driver' => 'json-file',
            'log_opt' => ['max-size=1m', 'max-file=3'] }
        end

        it { is_expected.to contain_file(service_config_file).with_content(%r{--log-driver json-file}) }
        it { is_expected.to contain_file(service_config_file).with_content(%r{--log-opt max-size=1m}) }
        it { is_expected.to contain_file(service_config_file).with_content(%r{--log-opt max-file=3}) }
      end

      context 'without log_driver no log_opt' do
        let(:params) { { 'log_opt' => ['max-size=1m'] } }

        it { is_expected.not_to contain_file(service_config_file).with_content(%r{--log-opt max-size=1m}) }
      end

      context 'with storage_driver set to devicemapper and dm_* options set' do
        let(:params) do
          { 'storage_driver' => 'devicemapper',
            'dm_datadev'     => '/dev/sda',
            'dm_metadatadev' => '/dev/sdb' }
        end

        it { is_expected.to contain_file(storage_config_file).with_content(%r{dm.datadev=\/dev\/sda}) }
      end

      context 'with storage_driver unset and dm_ options set' do
        let(:params) do
          { 'dm_datadev'     => '/dev/sda',
            'dm_metadatadev' => '/dev/sdb' }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{Values for dm_ variables will be ignored unless storage_driver is set to devicemapper.}) }
      end

      context 'with storage_driver and dm_basesize set' do
        let(:params) do
          { 'storage_driver' => 'devicemapper',
            'dm_basesize'    => '20G' }
        end

        it { is_expected.to contain_file(storage_config_file).with_content(%r{dm.basesize=20G}) }
      end

      context 'with storage_driver unset and dm_basesize set' do
        let(:params) { { 'dm_basesize' => '20G' } }

        it { is_expected.to raise_error(Puppet::Error, %r{Values for dm_ variables will be ignored unless storage_driver is set to devicemapper.}) }
      end

      context 'with specific selinux_enabled parameter' do
        let(:params) { { 'selinux_enabled' => true } }

        it { is_expected.to contain_file(service_config_file).with_content(%r{--selinux-enabled=true}) }
      end

      context 'with an invalid selinux_enabled parameter' do
        let(:params) { { 'selinux_enabled' => 'yes' } }

        it do
          expect {
            is_expected.to contain_package('docker')
          }.to raise_error(Puppet::Error, %r{got String})
        end
      end

      context 'with custom root dir && Docker version < 17.06' do
        let(:params) do
          {
            'root_dir' => '/mnt/docker',
            'version' => '17.03',
          }
        end

        it { is_expected.to contain_file(service_config_file).with_content(%r{-g \/mnt\/docker}) }
      end

      context 'with custom root dir && Docker version > 18.09' do
        let(:params) do
          {
            'root_dir' => '/mnt/docker',
            'version' => '19.09',
          }
        end

        it { is_expected.to contain_file(service_config_file).with_content(%r{--data-root \/mnt\/docker}) }
      end

      context 'with ensure absent' do
        let(:params) { { 'ensure' => 'absent' } }

        it { is_expected.to contain_package('docker').with_ensure('absent') }
      end

      context 'with ensure absent and ' do
        let(:params) { { 'ensure' => 'absent' } }

        it { is_expected.to contain_package('docker').with_ensure('absent') }
        it { is_expected.to contain_package('docker-ce-cli').with_ensure('absent') }
        it { is_expected.to contain_package('containerd.io').with_ensure('absent') }
      end

      context 'with an invalid combination of devicemapper options' do
        let(:params) do
          { 'dm_datadev' => '/dev/mapper/vg_test-docker--pool_tdata',
            'dm_metadatadev' => '/dev/mapper/vg_test-docker--pool_tmeta',
            'dm_thinpooldev' => '/dev/mapper/vg_test-docker--pool' }
        end

        it do
          expect {
            is_expected.to contain_package('docker')
          }.to raise_error(Puppet::Error, %r{You can use the \$dm_thinpooldev parameter, or the \$dm_datadev and \$dm_metadatadev parameter pair, but you cannot use both.})
        end
      end
    end
  end

  ['RedHat', 'CentOS'].each do |operatingsystem|
    context "on #{operatingsystem}" do
      let(:facts) do
        {
          architecture: 'x86_64',
          osfamily: 'RedHat',
          operatingsystem: operatingsystem,
          operatingsystemrelease: '7.0',
          operatingsystemmajrelease: '7',
          kernelversion: '3.10.0',
          os: { distro: { codename: 'wheezy' }, family: 'Debian', name: 'Debian', release: { major: '7', full: '7.0' } },
        }
      end

      storage_setup_file = '/etc/sysconfig/docker-storage-setup'

      context 'with storage driver' do
        let(:params) { { 'storage_driver' => 'devicemapper' } }

        it { is_expected.to contain_file(storage_setup_file).with_content(%r{^STORAGE_DRIVER=devicemapper}) }
      end

      context 'with storage devices' do
        let(:params) { { 'storage_devs' => '/dev/sda,/dev/sdb' } }

        it { is_expected.to contain_file(storage_setup_file).with_content(%r{^DEVS="\/dev\/sda,\/dev\/sdb"}) }
      end

      context 'with storage volume group' do
        let(:params) { { 'storage_vg' => 'vg_test' } }

        it { is_expected.to contain_file(storage_setup_file).with_content(%r{^VG=vg_test}) }
      end

      context 'with storage root size' do
        let(:params) { { 'storage_root_size' => '10G' } }

        it { is_expected.to contain_file(storage_setup_file).with_content(%r{^ROOT_SIZE=10G}) }
      end

      context 'with storage data size' do
        let(:params) { { 'storage_data_size' => '10G' } }

        it { is_expected.to contain_file(storage_setup_file).with_content(%r{^DATA_SIZE=10G}) }
      end

      context 'with storage min data size' do
        let(:params) { { 'storage_min_data_size' => '2G' } }

        it { is_expected.to contain_file(storage_setup_file).with_content(%r{^MIN_DATA_SIZE=2G}) }
      end

      context 'with storage chunk size' do
        let(:params) { { 'storage_chunk_size' => '10G' } }

        it { is_expected.to contain_file(storage_setup_file).with_content(%r{^CHUNK_SIZE=10G}) }
      end

      context 'with storage grow partition' do
        let(:params) { { 'storage_growpart' => true } }

        it { is_expected.to contain_file(storage_setup_file).with_content(%r{^GROWPART=true}) }
      end

      context 'with storage auto extend pool' do
        let(:params) { { 'storage_auto_extend_pool' => '1' } }

        it { is_expected.to contain_file(storage_setup_file).with_content(%r{^AUTO_EXTEND_POOL=1}) }
      end

      context 'with storage auto extend threshold' do
        let(:params) { { 'storage_pool_autoextend_threshold' => '1' } }

        it { is_expected.to contain_file(storage_setup_file).with_content(%r{^POOL_AUTOEXTEND_THRESHOLD=1}) }
      end

      context 'with storage auto extend percent' do
        let(:params) { { 'storage_pool_autoextend_percent' => '10' } }

        it { is_expected.to contain_file(storage_setup_file).with_content(%r{^POOL_AUTOEXTEND_PERCENT=10}) }
      end

      context 'with custom storage_setup_file' do
        let(:params) { { 'storage_setup_file' => '/etc/sysconfig/docker-latest-storage-setup' } }

        it { is_expected.to contain_file('/etc/sysconfig/docker-latest-storage-setup').with_content(%r{managed by Puppet}) }
      end
    end
  end

  context 'specific to Ubuntu Trusty' do
    let(:facts) do
      {
        architecture: 'amd64',
        osfamily: 'Debian',
        lsbdistid: 'Ubuntu',
        operatingsystem: 'Ubuntu',
        lsbdistcodename: 'trusty',
        operatingsystemrelease: '14.04',
        kernelrelease: '3.8.0-29-generic',
        os: { distro: { codename: 'wheezy' }, family: 'Debian', name: 'Debian', release: { major: '7', full: '7.0' } },
      }
    end

    it { is_expected.to contain_service('docker').with_provider('upstart') }
    it { is_expected.to contain_package('docker').with_name('docker-ce').with_ensure('present') }
    it { is_expected.to contain_package('apparmor') }
  end

  context 'newer versions of Debian and Ubuntu' do
    context 'Ubuntu >= 15.04' do
      let(:facts) do
        {
          architecture: 'amd64',
          osfamily: 'Debian',
          lsbdistid: 'Ubuntu',
          operatingsystem: 'Ubuntu',
          lsbdistcodename: 'trusty',
          operatingsystemrelease: '15.04',
          kernelrelease: '3.8.0-29-generic',
          os: { distro: { codename: 'wheezy' }, family: 'Debian', name: 'Debian', release: { major: '7', full: '7.0' } },
        }
      end

      it { is_expected.to contain_service('docker').with_provider('systemd').with_hasstatus(true).with_hasrestart(true) }
    end

    context 'Debian >= 8' do
      let(:facts) do
        {
          architecture: 'amd64',
          osfamily: 'Debian',
          operatingsystem: 'Debian',
          lsbdistid: 'Debian',
          lsbdistcodename: 'jessie',
          kernelrelease: '3.2.0-4-amd64',
          operatingsystemmajrelease: '8',
          os: { distro: { codename: 'wheezy' }, family: 'Debian', name: 'Debian', release: { major: '7', full: '7.0' } },
        }
      end

      it { is_expected.to contain_service('docker').with_provider('systemd').with_hasstatus(true).with_hasrestart(true) }
    end
  end

  context 'with an invalid distro name' do
    let(:facts) do
      {
        architecture: 'Whatever',
        osfamily: 'Whatever',
        operatingsystem: 'Whatever',
        lsbdistid: 'Whatever',
        lsbdistcodename: 'Whatever',
        kernelrelease: 'Whatever',
        operatingsystemmajrelease: 'Whatever',
        os: { distro: { codename: 'Whatever' }, family: 'Whatever', name: 'Whatever', release: { major: 'Whatever', full: 'Whatever' } },
      }
    end

    it do
      expect {
        is_expected.to contain_package('docker')
      }.to raise_error(Puppet::Error, %r{This module only works on Debian, Red Hat or Windows based systems.})
    end
  end

  context 'CentOS < 7' do
    let(:facts) do
      {
        architecture: 'x86_64',
        osfamily: 'RedHat',
        operatingsystem: 'CentOS',
        kernelversion: '3.10.0',
        operatingsystemmajrelease: '6',
        os: { family: 'RedHat', name: 'CentOS', release: { major: '6', full: '6.0' } },
      }
    end

    it do
      expect {
        is_expected.to contain_package('docker')
      }.to raise_error(Puppet::Error, %r{This module only works on CentOS version 7 and higher based systems.})
    end
  end
end
