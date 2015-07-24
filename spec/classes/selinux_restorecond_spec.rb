require 'spec_helper'

describe 'selinux::restorecond' do
  include_context 'RedHat 7'

  it { should contain_class('selinux::restorecond::config') }
  it { should contain_class('selinux::restorecond::service') }

end
