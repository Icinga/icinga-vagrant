require 'spec_helper'

['Debian', 'RedHat', 'generic systemd'].each do |osfamily|
  describe 'docker::run', type: :define do
    let(:title) { 'sample' }

    params = { 'command' => 'command', 'image' => 'base' }

    context "on #{osfamily}" do
      initscript = '/etc/systemd/system/docker-sample.service'
      startscript = '/usr/local/bin/docker-run-sample-start.sh'
      stopscript = '/usr/local/bin/docker-run-sample-stop.sh'

      if osfamily == 'Debian'
        pre_condition = "class { 'docker': docker_group => 'docker', service_name => 'docker' }"
        let(:pre_condition) { pre_condition }
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

        systemd = true
      elsif osfamily == 'RedHat'
        pre_condition = "class { 'docker': docker_group => 'docker', service_name => 'docker' }"
        let(:pre_condition) { pre_condition }
        let(:facts) do
          {
            architecture: 'x86_64',
            osfamily: osfamily,
            operatingsystem: 'RedHat',
            lsbdistcodename: 'xenial',
            operatingsystemrelease: '7.2',
            operatingsystemmajrelease: '7',
            kernelversion: '3.10.0',
            os: { distro: { codename: 'wheezy' }, family: osfamily, name: osfamily, release: { major: '7', full: '7.0' } },
          }
        end

        systemd = true
      elsif osfamily == 'generic systemd'
        pre_condition = "class { 'docker': docker_group => 'docker', service_name => 'docker', service_provider => systemd, acknowledge_unsupported_os => true }"
        let(:pre_condition) { pre_condition }
        let(:facts) do
          {
            osfamily: 'Gentoo',
            operatingsystem: 'Generic',
          }
        end

        params['service_provider'] = 'systemd'
        systemd = true
      end

      startscript_or_init = systemd ? startscript : initscript
      stopscript_or_init = systemd ? stopscript : initscript

      context 'passing the required params' do
        let(:params) { params }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('docker-sample') }
        it { is_expected.to contain_file(initscript).with_content(%r{#{Regexp.escape(startscript)}}).with_mode('0644') }
        it { is_expected.to contain_file(initscript).with_content(%r{#{Regexp.escape(stopscript)}}) }
        it { is_expected.to contain_file(startscript_or_init).with_content(%r{docker start}).with_content(%r{command}).with_content(%r{base}) }

        if systemd
          it { is_expected.to contain_file(initscript).with_content(%r{^SyslogIdentifier=docker-sample$}) }
        end
      end

      context 'when passing `after` containers' do
        let(:params) { params.merge('after' => ['foo', 'bar', 'foo_bar/baz']) }

        if systemd
          it { is_expected.to contain_file(initscript).with_content(%r{After=(.*\s+)?docker-foo.service}) }
          it { is_expected.to contain_file(initscript).with_content(%r{After=(.*\s+)?docker-bar.service}) }
          it { is_expected.to contain_file(initscript).with_content(%r{After=(.*\s+)?docker-foo_bar-baz.service}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Wants=(.*\s+)?docker-foo.service}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Wants=(.*\s+)?docker-bar.service}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Wants=(.*\s+)?docker-foo_bar-baz.service}) }
        else
          it { is_expected.to contain_file(initscript).with_content(%r{Required-Start:.*\s+docker-foo}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Required-Start:.*\s+docker-bar}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Required-Start:.*\s+docker-foo_bar-baz}) }
        end
      end

      context 'when passing `depends` containers' do
        let(:params) { params.merge('depends' => ['foo', 'bar', 'foo_bar/baz']) }

        if systemd
          it { is_expected.to contain_file(initscript).with_content(%r{After=(.*\s+)?docker-foo.service}) }
          it { is_expected.to contain_file(initscript).with_content(%r{After=(.*\s+)?docker-bar.service}) }
          it { is_expected.to contain_file(initscript).with_content(%r{After=(.*\s+)?docker-foo_bar-baz.service}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Requires=(.*\s+)?docker-foo.service}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Requires=(.*\s+)?docker-bar.service}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Requires=(.*\s+)?docker-foo_bar-baz.service}) }
        else
          it { is_expected.to contain_file(initscript).with_content(%r{Required-Start:.*\s+docker-foo}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Required-Start:.*\s+docker-bar}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Required-Start:.*\s+docker-foo_bar-baz}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Required-Stop:.*\s+docker-foo}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Required-Stop:.*\s+docker-bar}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Required-Stop:.*\s+docker-foo_bar-baz}) }
        end
      end

      context 'when passing `depend_services`' do
        let(:params) { params.merge('depend_services' => ['foo', 'bar']) }

        if systemd
          it { is_expected.to contain_file(initscript).with_content(%r{After=(.*\s+)?foo.service}) }
          it { is_expected.to contain_file(initscript).with_content(%r{After=(.*\s+)?bar.service}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Requires=(.*\s+)?foo.service}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Requires=(.*\s+)?bar.service}) }

          context 'with full systemd unit names' do
            let(:params) { params.merge('depend_services' => ['foo', 'bar.service', 'baz.target']) }

            it { is_expected.to contain_file(initscript).with_content(%r{After=(.*\s+)?foo.service(\s+|$)}) }
            it { is_expected.to contain_file(initscript).with_content(%r{After=(.*\s+)?bar.service(\s+|$)}) }
            it { is_expected.to contain_file(initscript).with_content(%r{After=(.*\s+)?baz.target(\s+|$)}) }
            it { is_expected.to contain_file(initscript).with_content(%r{Requires=(.*\s+)?foo.service(\s+|$)}) }
            it { is_expected.to contain_file(initscript).with_content(%r{Requires=(.*\s+)?bar.service(\s+|$)}) }
            it { is_expected.to contain_file(initscript).with_content(%r{Requires=(.*\s+)?baz.target(\s+|$)}) }
          end
        else
          it { is_expected.to contain_file(initscript).with_content(%r{Required-Start:.*\s+foo}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Required-Start:.*\s+bar}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Required-Stop:.*\s+foo}) }
          it { is_expected.to contain_file(initscript).with_content(%r{Required-Stop:.*\s+bar}) }
        end
      end

      context 'removing containers and volumes' do
        context 'when trying to remove the volume and not the container on stop' do
          let(:params) do
            params.merge('remove_container_on_stop' => false,
                         'remove_volume_on_stop' => true)
          end

          it do
            expect {
              is_expected.to contain_service('docker-sample')
            }.to raise_error(Puppet::Error)
          end
        end

        context 'when trying to remove the volume and not the container on start' do
          let(:params) do
            params.merge('remove_container_on_start' => false,
                         'remove_volume_on_start' => true)
          end

          it do
            expect {
              is_expected.to contain_service('docker-sample')
            }.to raise_error(Puppet::Error)
          end
        end

        context 'When restarting an unhealthy container' do
          let(:params) do
            params.merge('health_check_cmd' => 'pwd',
                         'restart_on_unhealthy' => true,
                         'health_check_interval' => 60)
          end

          if systemd
            it { is_expected.to contain_file(stopscript).with_content(%r{\/usr\/bin\/docker stop --time=0 }).with_content(%r{\/usr\/bin\/docker rm}) }
            it { is_expected.to contain_file(startscript).with_content(%r{--health-cmd}) }
          end
        end

        context 'when not removing containers on container start and stop' do
          let(:params) do
            params.merge('remove_container_on_start' => false,
                         'remove_container_on_stop' => false)
          end

          it { is_expected.not_to contain_file(startscript_or_init).with_content(%r{\/usr\/bin\/docker rm  sample}) }
        end

        context 'when removing containers on container start' do
          let(:params) { params.merge('remove_container_on_start' => true) }

          it { is_expected.to contain_file(startscript_or_init).with_content(%r{\/usr\/bin\/docker rm  sample}) }
        end

        context 'when removing containers on container stop' do
          let(:params) { params.merge('remove_container_on_stop' => true) }

          it { is_expected.to contain_file(stopscript_or_init).with_content(%r{\/usr\/bin\/docker rm  sample}) }
        end

        context 'when not removing volumes on container start' do
          let(:params) { params.merge('remove_volume_on_start' => false) }

          it { is_expected.not_to contain_file(startscript_or_init).with_content(%r{\/usr\/bin\/docker rm -v sample}) }
        end

        context 'when removing volumes on container start' do
          let(:params) { params.merge('remove_volume_on_start' => true) }

          it { is_expected.to contain_file(startscript_or_init).with_content(%r{\/usr\/bin\/docker rm -v}) }
        end

        context 'when not removing volumes on container stop' do
          let(:params) { params.merge('remove_volume_on_stop' => false) }

          it { is_expected.not_to contain_file(stopscript_or_init).with_content(%r{\/usr\/bin\/docker rm -v sample}) }
        end

        context 'when removing volumes on container stop' do
          let(:params) { params.merge('remove_volume_on_stop' => true) }

          it { is_expected.to contain_file(stopscript_or_init).with_content(%r{\/usr\/bin\/docker rm -v}) }
        end
      end

      context 'with autorestart functionality' do
        let(:params) { params }

        if systemd
          it { is_expected.to contain_file(initscript).with_content(%r{Restart=on-failure}) }
        end
      end

      context 'when lxc_conf disables swap' do
        let(:params) { params.merge('lxc_conf' => 'lxc.cgroup.memory.memsw.limit_in_bytes=536870912') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-lxc-conf=\"lxc.cgroup.memory.memsw.limit_in_bytes=536870912\"}) }
      end

      context 'when `use_name` is true' do
        let(:params) { params.merge('use_name' => true) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--name sample }) }
      end

      context 'when stopping the service' do
        let(:params) { params.merge('running' => false) }

        it { is_expected.to contain_service('docker-sample').with_ensure(false) }
      end

      context 'when passing a memory limit in bytes' do
        let(:params) { params.merge('memory_limit' => '1000b') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-m 1000b}) }
      end

      context 'when passing a cpuset' do
        let(:params) { params.merge('cpuset' => '3') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--cpuset-cpus=3}) }
      end

      context 'when passing a multiple cpu cpuset' do
        let(:params) { params.merge('cpuset' => ['0', '3']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--cpuset-cpus=0,3}) }
      end

      context 'when not passing a cpuset' do
        let(:params) { params }

        it { is_expected.to contain_file(startscript_or_init).without_content(%r{--cpuset-cpus=}) }
      end

      context 'when passing a links option' do
        let(:params) { params.merge('links' => ['example:one', 'example:two']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--link example:one}).with_content(%r{--link example:two}) }
      end

      context 'when passing a hostname' do
        let(:params) { params.merge('hostname' => 'example.com') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-h 'example.com'}) }
      end

      context 'when not passing a hostname' do
        let(:params) { params }

        it { is_expected.to contain_file(startscript_or_init).without_content(%r{-h ''}) }
      end

      context 'when passing a username' do
        let(:params) { params.merge('username' => 'bob') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-u 'bob'}) }
      end

      context 'when not passing a username' do
        let(:params) { params }

        it { is_expected.to contain_file(startscript_or_init).without_content(%r{-u ''}) }
      end

      context 'when passing a port number' do
        let(:params) { params.merge('ports' => '4444') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-p 4444}) }
      end

      context 'when passing a port to expose' do
        let(:params) { params.merge('expose' => '4666') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--expose=4666}) }
      end

      context 'when passing a label' do
        let(:params) { params.merge('labels' => 'key=value') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-l key=value}) }
      end

      context 'when passing a hostentry' do
        let(:params) { params.merge('hostentries' => 'dummyhost:127.0.0.2') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--add-host dummyhost:127.0.0.2}) }
      end

      context 'when connecting to shared data volumes' do
        let(:params) { params.merge('volumes_from' => '6446ea52fbc9') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--volumes-from 6446ea52fbc9}) }
      end

      context 'when connecting to several shared data volumes' do
        let(:params) { params.merge('volumes_from' => ['sample-linked-container-1', 'sample-linked-container-2']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--volumes-from sample-linked-container-1}) }
        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--volumes-from sample-linked-container-2}) }
      end

      context 'when passing several port numbers' do
        let(:params) { params.merge('ports' => ['4444', '4555']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-p 4444}).with_content(%r{-p 4555}) }
      end

      context 'when passing several labels' do
        let(:params) { params.merge('labels' => ['key1=value1', 'key2=value2']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-l key1=value1}).with_content(%r{-l key2=value2}) }
      end

      context 'when passing several ports to expose' do
        let(:params) { params.merge('expose' => ['4666', '4777']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--expose=4666}).with_content(%r{--expose=4777}) }
      end

      context 'when passing serveral environment variables' do
        let(:params) { params.merge('env' => ['FOO=BAR', 'FOO2=BAR2']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-e "FOO=BAR"}).with_content(%r{-e "FOO2=BAR2"}) }
      end

      context 'when passing an environment variable' do
        let(:params) { params.merge('env' => 'FOO=BAR') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-e "FOO=BAR"}) }
      end

      context 'when passing serveral environment files' do
        let(:params) { params.merge('env_file' => ['/etc/foo.env', '/etc/bar.env']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--env-file \/etc\/foo.env}).with_content(%r{--env-file \/etc\/bar.env}) }
      end

      context 'when passing an environment file' do
        let(:params) { params.merge('env_file' => '/etc/foo.env') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--env-file \/etc\/foo.env}) }
      end

      context 'when passing serveral dns addresses' do
        let(:params) { params.merge('dns' => ['8.8.8.8', '8.8.4.4']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--dns 8.8.8.8}).with_content(%r{--dns 8.8.4.4}) }
      end

      context 'when passing a dns address' do
        let(:params) { params.merge('dns' => '8.8.8.8') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--dns 8.8.8.8}) }
      end

      context 'when passing serveral sockets to connect to' do
        let(:params) { params.merge('socket_connect' => ['tcp://127.0.0.1:4567', 'tcp://127.0.0.2:4567']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-H tcp:\/\/127.0.0.1:4567}) }
      end

      context 'when passing a socket to connect to' do
        let(:params) { params.merge('socket_connect' => 'tcp://127.0.0.1:4567') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-H tcp:\/\/127.0.0.1:4567}) }
      end

      context 'when passing serveral dns search domains' do
        let(:params) { params.merge('dns_search' => ['my.domain.local', 'other-domain.de']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--dns-search my.domain.local}).with_content(%r{--dns-search other-domain.de}) }
      end

      context 'when passing a dns search domain' do
        let(:params) { params.merge('dns_search' => 'my.domain.local') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--dns-search my.domain.local}) }
      end

      context 'when disabling network' do
        let(:params) { params.merge('disable_network' => true) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-n false}) }
      end

      context 'when running privileged' do
        let(:params) { params.merge('privileged' => true) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--privileged}) }
      end

      context 'should run with correct detached value' do
        let(:params) { params }

        if systemd
          it { is_expected.not_to contain_file(startscript).with_content(%r{--detach=true}) }
        else
          it { is_expected.to contain_file(initscript).with_content(%r{--detach=true}) }
        end
      end

      context 'should be able to override detached' do
        let(:params) { params.merge('detach' => false) }

        it { is_expected.to contain_file(startscript_or_init).without_content(%r{--detach=true}) }
      end

      context 'when running with a tty' do
        let(:params) { params.merge('tty' => true) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-t}) }
      end

      context 'when running with read-only image' do
        let(:params) { params.merge('read_only' => true) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--read-only=true}) }
      end

      context 'when passing serveral extra parameters' do
        let(:params) { params.merge('extra_parameters' => ['--rm', '-w /tmp']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--rm}).with_content(%r{-w \/tmp}) }
      end

      context 'when passing an extra parameter' do
        let(:params) { params.merge('extra_parameters' => '-c 4') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-c 4}) }
      end

      context 'when passing a data volume' do
        let(:params) { params.merge('volumes' => '/var/log') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-v \/var\/log}) }
      end

      context 'when passing serveral data volume' do
        let(:params) { params.merge('volumes' => ['/var/lib/couchdb', '/var/log']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-v \/var\/lib\/couchdb}) }
        it { is_expected.to contain_file(startscript_or_init).with_content(%r{-v \/var\/log}) }
      end

      context 'when using network mode with a single network' do
        let(:params) { params.merge('net' => 'host') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{--net host}) }
      end

      context 'when using network mode with multiple networks' do
        let(:params) { params.merge('net' => ['host', 'foo']) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{docker network connect host sample}) }
        it { is_expected.to contain_file(startscript_or_init).with_content(%r{docker network connect foo sample}) }
      end

      context 'when `pull_on_start` is true' do
        let(:params) { params.merge('pull_on_start' => true) }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{docker pull base}) }
      end

      context 'when `pull_on_start` is false' do
        let(:params) { params.merge('pull_on_start' => false) }

        it { is_expected.not_to contain_file(startscript_or_init).with_content(%r{docker pull base}) }
      end

      context 'when `before_start` is set' do
        let(:params) { params.merge('before_start' => 'echo before_start') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{before_start}) }
      end

      context 'when `before_start` is not set' do
        let(:params) { params.merge('before_start' => false) }

        it { is_expected.not_to contain_file(startscript_or_init).with_content(%r{before_start}) }
      end

      context 'when `before_stop` is set' do
        let(:params) { params.merge('before_stop' => 'echo before_stop') }

        it { is_expected.to contain_file(stopscript_or_init).with_content(%r{before_stop}) }
      end

      context 'when `before_stop` is not set' do
        let(:params) { params.merge('before_stop' => false) }

        it { is_expected.not_to contain_file(stopscript_or_init).with_content(%r{before_stop}) }
      end

      context 'when `after_create` is set' do
        let(:params) { params.merge('after_create' => 'echo after_create') }

        it { is_expected.to contain_file(startscript_or_init).with_content(%r{after_create}) }
      end

      context 'with an title that will not format into a path' do
        let(:title) { 'this/that' }
        let(:params) { params }

        new_initscript = '/etc/systemd/system/docker-this-that.service'
        new_startscript = '/usr/local/bin/docker-run-this-that-start.sh'
        new_stopscript = '/usr/local/bin/docker-run-this-that-stop.sh'

        it { is_expected.to contain_service('docker-this-that') }
        it { is_expected.to contain_file(new_initscript) }
        it { is_expected.to contain_file(new_startscript) }
        it { is_expected.to contain_file(new_stopscript) }
      end

      context 'with manage_service turned off' do
        let(:title) { 'this/that' }
        let(:params) { params.merge('manage_service' => false) }

        new_initscript = '/etc/systemd/system/docker-this-that.service'
        new_startscript = '/usr/local/bin/docker-run-this-that-start.sh'
        new_stopscript = '/usr/local/bin/docker-run-this-that-stop.sh'

        it { is_expected.not_to contain_service('docker-this-that') }
        it { is_expected.to contain_file(new_initscript) }
        it { is_expected.to contain_file(new_startscript) }
        it { is_expected.to contain_file(new_stopscript) }
      end

      context 'with service_prefix set to empty string' do
        let(:title) { 'this/that' }
        let(:params) { params.merge('service_prefix' => '') }

        new_initscript = '/etc/systemd/system/this-that.service'
        new_startscript = '/usr/local/bin/docker-run-this-that-start.sh'
        new_stopscript = '/usr/local/bin/docker-run-this-that-stop.sh'

        it { is_expected.to contain_service('this-that') }
        it { is_expected.to contain_file(new_initscript) }
        it { is_expected.to contain_file(new_startscript) }
        it { is_expected.to contain_file(new_stopscript) }
      end

      context 'with an invalid title' do
        let(:title) { 'with spaces' }

        it do
          expect {
            is_expected.to contain_service('docker-sample')
          }.to raise_error(Puppet::Error)
        end
      end

      context 'with title that need sanitisation' do
        let(:title) { 'this/that_other' }
        let(:params) { params }

        new_initscript = '/etc/systemd/system/docker-this-that_other.service'
        new_startscript = '/usr/local/bin/docker-run-this-that_other-start.sh'
        new_stopscript = '/usr/local/bin/docker-run-this-that_other-stop.sh'

        it { is_expected.to contain_service('docker-this-that_other') }
        it { is_expected.to contain_file(new_initscript) }
        it { is_expected.to contain_file(new_startscript) }
        it { is_expected.to contain_file(new_stopscript) }
      end

      context 'with an invalid image name' do
        let(:params) { params.merge('image' => 'with spaces', 'running' => 'not a boolean') }

        it do
          expect {
            is_expected.to contain_service('docker-sample')
          }.to raise_error(Puppet::Error)
        end
      end

      context 'with an invalid running value' do
        let(:title) { 'with spaces' }
        let(:params) { params.merge('running' => 'not a boolean') }

        it do
          expect {
            is_expected.to contain_service('docker-sample')
          }.to raise_error(Puppet::Error)
        end
      end

      context 'with an invalid memory value' do
        let(:title) { 'with spaces' }
        let(:params) { params.merge('memory' => 'not a number') }

        it do
          expect {
            is_expected.to contain_service('docker-sample')
          }.to raise_error(Puppet::Error)
        end
      end

      context 'with a missing memory unit' do
        let(:title) { 'with spaces' }
        let(:params) { params.merge('memory' => '10240') }

        it do
          expect {
            is_expected.to contain_service('docker-sample')
          }.to raise_error(Puppet::Error)
        end
      end

      context 'with restart policy set to no' do
        let(:params) { params.merge('restart' => 'no', 'extra_parameters' => '-c 4') }

        it { is_expected.to contain_exec('run sample with docker') }
        it { is_expected.to contain_exec('run sample with docker').with_unless(%r{sample}) }
        it { is_expected.to contain_exec('run sample with docker').with_unless(%r{inspect}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{--cidfile=\/var\/run\/docker-sample.cid}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{-c 4}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{--restart="no"}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{base command}) }
        it { is_expected.to contain_exec('run sample with docker').with_timeout(0) }
      end

      context 'with restart policy set to always' do
        let(:params) { params.merge('restart' => 'always', 'extra_parameters' => '-c 4') }

        it { is_expected.to contain_exec('run sample with docker') }
        it { is_expected.to contain_exec('run sample with docker').with_unless(%r{sample}) }
        it { is_expected.to contain_exec('run sample with docker').with_unless(%r{inspect}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{--cidfile=\/var\/run\/docker-sample.cid}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{-c 4}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{--restart="always"}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{base command}) }
        it { is_expected.to contain_exec('run sample with docker').with_timeout(0) }
      end

      context 'with restart policy set to on-failure' do
        let(:params) { params.merge('restart' => 'on-failure', 'extra_parameters' => '-c 4') }

        it { is_expected.to contain_exec('run sample with docker') }
        it { is_expected.to contain_exec('run sample with docker').with_unless(%r{sample}) }
        it { is_expected.to contain_exec('run sample with docker').with_unless(%r{inspect}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{--cidfile=\/var\/run\/docker-sample.cid}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{-c 4}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{--restart="on-failure"}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{base command}) }
        it { is_expected.to contain_exec('run sample with docker').with_timeout(0) }
      end

      context 'with restart policy set to on-failure:3' do
        let(:params) { params.merge('restart' => 'on-failure:3', 'extra_parameters' => '-c 4') }

        it { is_expected.to contain_exec('run sample with docker') }
        it { is_expected.to contain_exec('run sample with docker').with_unless(%r{sample}) }
        it { is_expected.to contain_exec('run sample with docker').with_unless(%r{inspect}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{--cidfile=\/var\/run\/docker-sample.cid}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{-c 4}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{--restart="on-failure:3"}) }
        it { is_expected.to contain_exec('run sample with docker').with_command(%r{base command}) }
        it { is_expected.to contain_exec('run sample with docker').with_timeout(0) }
      end

      context 'when `docker_service` is false' do
        let(:params) { params.merge('docker_service' => false) }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('docker-sample') }
      end

      context 'when `docker_service` is true' do
        let(:params) { params.merge('docker_service' => true) }
        let(:pre_condition) { ["service { 'docker': provider => systemd }", pre_condition] }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('docker').that_comes_before('Service[docker-sample]') }
        it { is_expected.to contain_service('docker').that_notifies('Service[docker-sample]') }
      end

      context 'when `docker_service` is true and `restart_service_on_docker_refresh` is false' do
        let(:params) { params.merge('docker_service' => true, 'restart_service_on_docker_refresh' => false) }
        let(:pre_condition) { ["service { 'docker': provider => systemd }", pre_condition] }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('docker').that_comes_before('Service[docker-sample]') }
      end

      context 'when `docker_service` is `my-docker`' do
        let(:params) { params.merge('docker_service' => 'my-docker') }
        let(:pre_condition) { ["service { 'my-docker': provider => systemd }", pre_condition] }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('my-docker').that_comes_before('Service[docker-sample]') }
        it { is_expected.to contain_service('my-docker').that_notifies('Service[docker-sample]') }
      end

      context 'when `docker_service` is `my-docker` and `restart_service_on_docker_refresh` is false' do
        let(:params) { params.merge('docker_service' => 'my-docker', 'restart_service_on_docker_refresh' => false) }
        let(:pre_condition) { ["service { 'my-docker': provider => systemd }", pre_condition] }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('my-docker').that_comes_before('Service[docker-sample]') }
      end

      context 'with syslog_identifier' do
        let(:params) { params.merge('syslog_identifier' => 'docker-universe') }

        if systemd
          it { is_expected.to contain_file(initscript).with_content(%r{^SyslogIdentifier=docker-universe$}) }
        end
      end

      context 'with extra_systemd_parameters' do
        let(:params) { params.merge('extra_systemd_parameters' => { 'RestartSec' => 5 }) }

        if systemd
          it { is_expected.to contain_file(initscript).with_content(%r{^RestartSec=5$}) }
        end
      end

      context 'with ensure absent' do
        let(:params) { params.merge('ensure' => 'absent') }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('docker-sample').with_ensure(false) }
        it { is_expected.to contain_exec('remove container docker-sample').with_command('docker rm -v sample') }
        it { is_expected.not_to contain_file('docker-sample.service') }
      end
    end
  end
end
