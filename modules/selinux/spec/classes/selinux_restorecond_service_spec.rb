require 'spec_helper'

describe 'selinux::restorecond' do
  include_context 'RedHat 7'

  it { should contain_service('restorecond') }

end
