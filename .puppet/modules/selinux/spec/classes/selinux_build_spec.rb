require 'spec_helper'

describe 'selinux::build' do
  let(:params) { { module_build_root: '/var/lib/puppet/puppet-selinux' } }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_file('/var/lib/puppet/puppet-selinux').with_ensure('directory') }
  it { is_expected.to contain_file('/var/lib/puppet/puppet-selinux/modules').with_ensure('directory') }
  it { is_expected.to contain_file('/var/lib/puppet/puppet-selinux/modules/tmp').with_ensure('directory') }
  it { is_expected.to contain_file('/var/lib/puppet/puppet-selinux/bin').with_ensure('directory') }
  it { is_expected.to contain_file('/var/lib/puppet/puppet-selinux/bin/selinux_build_module_simple.sh').with_ensure('file') }
end
