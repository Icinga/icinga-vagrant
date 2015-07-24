require 'spec_helper'

describe 'selinux' do
  [
    'RedHat 7',
    'CentOS 7',
    'Fedora 22',
  ].each do |ctx|
    context ctx do
      include_context ctx

      it { should contain_class('selinux::package') }
      it { should contain_class('selinux::config') }
    end
  end
end
