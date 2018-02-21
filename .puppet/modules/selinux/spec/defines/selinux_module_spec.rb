require 'spec_helper'

describe 'selinux::module' do
  let(:title) { 'mymodule' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:workdir) do
        '/var/lib/puppet/puppet-selinux/modules'
      end
      let(:module_basepath) do
        '/var/lib/puppet/puppet-selinux/modules/mymodule'
      end

      context 'ordering' do
        let(:params) do
          {
            source_te: 'puppet:///modules/mymodule/selinux/mymodule.te'
          }
        end

        it { is_expected.to contain_selinux__module('mymodule').that_requires('Anchor[selinux::module pre]') }
        it { is_expected.to contain_selinux__module('mymodule').that_comes_before('Anchor[selinux::module post]') }
      end

      context 'present case with refpolicy builder and with te file only' do
        let(:params) do
          {
            source_te: 'puppet:///modules/mymodule/selinux/mymodule.te',
            builder: 'refpolicy'
          }
        end

        it { is_expected.to contain_file(workdir) }
        it { is_expected.to contain_file("#{workdir}/mymodule.te").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_file("#{workdir}/mymodule.fc").with(source: nil, content: '') }
        it { is_expected.to contain_file("#{workdir}/mymodule.if").with(source: nil, content: '') }
        it { is_expected.to contain_exec('clean-module-mymodule').with(command: "rm -f '#{module_basepath}.pp' '#{module_basepath}.loaded'", cwd: workdir) }
        it { is_expected.to contain_exec('build-module-mymodule').with(command: "make -f /usr/share/selinux/devel/Makefile mymodule.pp || (rm -f #{module_basepath}.pp #{module_basepath}.loaded && exit 1)", creates: "#{module_basepath}.pp") }
        it { is_expected.to contain_exec('install-module-mymodule').with(command: "semodule -i #{module_basepath}.pp && touch #{module_basepath}.loaded", cwd: workdir, creates: "#{module_basepath}.loaded") }
        it { is_expected.to contain_selmodule('mymodule').with_ensure('present', selmodulepath: workdir) }
      end

      context 'present case with refpolicy builder and with te and fc file' do
        let(:params) do
          {
            source_te: 'puppet:///modules/mymodule/selinux/mymodule.te',
            source_fc: 'puppet:///modules/mymodule/selinux/mymodule.fc',
            builder: 'refpolicy'
          }
        end

        it { is_expected.to contain_file(workdir) }
        it { is_expected.to contain_file("#{workdir}/mymodule.te").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_file("#{workdir}/mymodule.fc").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_file("#{workdir}/mymodule.if").with(source: nil, content: '') }
        it { is_expected.to contain_exec('clean-module-mymodule').with(command: "rm -f '#{module_basepath}.pp' '#{module_basepath}.loaded'", cwd: workdir) }
        it { is_expected.to contain_exec('build-module-mymodule').with(command: "make -f /usr/share/selinux/devel/Makefile mymodule.pp || (rm -f #{module_basepath}.pp #{module_basepath}.loaded && exit 1)", creates: "#{module_basepath}.pp") }
        it { is_expected.to contain_exec('install-module-mymodule').with(command: "semodule -i #{module_basepath}.pp && touch #{module_basepath}.loaded", cwd: workdir, creates: "#{module_basepath}.loaded") }
        it { is_expected.to contain_selmodule('mymodule').with_ensure('present', selmodulepath: workdir) }
      end

      context 'present case with refpolicy builder and with te, fc and if file' do
        let(:params) do
          {
            source_te: 'puppet:///modules/mymodule/selinux/mymodule.te',
            source_if: 'puppet:///modules/mymodule/selinux/mymodule.if',
            source_fc: 'puppet:///modules/mymodule/selinux/mymodule.fc',
            builder: 'refpolicy'
          }
        end

        it { is_expected.to contain_file(workdir) }
        it { is_expected.to contain_file("#{workdir}/mymodule.te").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_file("#{workdir}/mymodule.if").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_file("#{workdir}/mymodule.fc").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_exec('clean-module-mymodule').with(command: "rm -f '#{module_basepath}.pp' '#{module_basepath}.loaded'", cwd: workdir) }
        it { is_expected.to contain_exec('build-module-mymodule').with(command: "make -f /usr/share/selinux/devel/Makefile mymodule.pp || (rm -f #{module_basepath}.pp #{module_basepath}.loaded && exit 1)", creates: "#{module_basepath}.pp") }
        it { is_expected.to contain_exec('install-module-mymodule').with(command: "semodule -i #{module_basepath}.pp && touch #{module_basepath}.loaded", cwd: workdir, creates: "#{module_basepath}.loaded") }
        it { is_expected.to contain_selmodule('mymodule').with_ensure('present', selmodulepath: workdir) }
      end

      context 'present case with refpolicy builder and with inline te, fc and if file' do
        let(:params) do
          {
            content_te: 'policy_module(puppet_test, 1.0.0)',
            content_if: 'interface(puppet_test)',
            content_fc: '/bin/sh system_u:object_r:bin_t',
            builder: 'refpolicy'
          }
        end

        it { is_expected.to contain_file(workdir) }
        it { is_expected.to contain_file("#{workdir}/mymodule.te").with(source: nil, content: 'policy_module(puppet_test, 1.0.0)').that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_file("#{workdir}/mymodule.if").with(source: nil, content: 'interface(puppet_test)').that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_file("#{workdir}/mymodule.fc").with(source: nil, content: '/bin/sh system_u:object_r:bin_t').that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_exec('clean-module-mymodule').with(command: "rm -f '#{module_basepath}.pp' '#{module_basepath}.loaded'", cwd: workdir) }
        it { is_expected.to contain_exec('build-module-mymodule').with(command: "make -f /usr/share/selinux/devel/Makefile mymodule.pp || (rm -f #{module_basepath}.pp #{module_basepath}.loaded && exit 1)", creates: "#{module_basepath}.pp") }
        it { is_expected.to contain_exec('install-module-mymodule').with(command: "semodule -i #{module_basepath}.pp && touch #{module_basepath}.loaded", cwd: workdir, creates: "#{module_basepath}.loaded") }
        it { is_expected.to contain_selmodule('mymodule').with_ensure('present', selmodulepath: workdir) }
      end

      context 'present case with simple builder with te' do
        let(:params) do
          {
            source_te: 'puppet:///modules/mymodule/selinux/mymodule.te',
            builder: 'simple'
          }
        end

        it { is_expected.to contain_file(workdir) }
        it { is_expected.to contain_file("#{workdir}/mymodule.te").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_file("#{workdir}/mymodule.fc").with(source: nil, content: '') }
        it { is_expected.to contain_file("#{workdir}/mymodule.if").with(source: nil, content: '') }
        it { is_expected.to contain_exec('clean-module-mymodule').with(command: "rm -f '#{module_basepath}.pp' '#{module_basepath}.loaded'", cwd: workdir) }
        it { is_expected.to contain_exec('build-module-mymodule').with(command: "/var/lib/puppet/puppet-selinux/bin/selinux_build_module_simple.sh mymodule #{workdir} || (rm -f #{module_basepath}.pp #{module_basepath}.loaded && exit 1)", creates: "#{module_basepath}.pp") }
        it { is_expected.to contain_exec('install-module-mymodule').with(command: "semodule -i #{module_basepath}.pp && touch #{module_basepath}.loaded", cwd: workdir, creates: "#{module_basepath}.loaded") }
        it { is_expected.to contain_selmodule('mymodule').with_ensure('present', selmodulepath: workdir) }
      end

      context 'present case with simple builder with inline te' do
        let(:params) do
          {
            content_te: 'policy_module(puppet_test, 1.0.0)',
            builder: 'simple'
          }
        end

        it { is_expected.to contain_file(workdir) }
        it { is_expected.to contain_file("#{workdir}/mymodule.te").with(content: 'policy_module(puppet_test, 1.0.0)').that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_file("#{workdir}/mymodule.fc").with(source: nil, content: '') }
        it { is_expected.to contain_file("#{workdir}/mymodule.if").with(source: nil, content: '') }
        it { is_expected.to contain_exec('clean-module-mymodule').with(command: "rm -f '#{module_basepath}.pp' '#{module_basepath}.loaded'", cwd: workdir) }
        it { is_expected.to contain_exec('build-module-mymodule').with(command: "/var/lib/puppet/puppet-selinux/bin/selinux_build_module_simple.sh mymodule #{workdir} || (rm -f #{module_basepath}.pp #{module_basepath}.loaded && exit 1)", creates: "#{module_basepath}.pp") }
        it { is_expected.to contain_exec('install-module-mymodule').with(command: "semodule -i #{module_basepath}.pp && touch #{module_basepath}.loaded", cwd: workdir, creates: "#{module_basepath}.loaded") }
        it { is_expected.to contain_selmodule('mymodule').with_ensure('present', selmodulepath: workdir) }
      end

      context 'unsupported source with simple builder' do
        let(:params) do
          {
            source_if: 'puppet:///modules/mymodule/selinux/mymodule.te',
            builder: 'simple'
          }
        end

        it do
          is_expected.to raise_error(Puppet::Error, %r{simple builder does not support})
        end
      end
      context 'absent case' do
        let(:params) do
          {
            ensure: 'absent'
          }
        end

        it { is_expected.to contain_selmodule('mymodule').with_ensure('absent') }
      end
    end
  end
end
