require 'spec_helper'

describe 'selinux::restorecond::fragment' do
  let(:pre_condition) { 'class { "selinux::restorecond": }' }
  let(:title) { 'cond' }
  include_context 'RedHat 7'

  context 'source' do
    let(:params) { { :source => 'puppet:///data/cond.txt' } }
    it { should contain_concat__fragment('restorecond_conf_cond').with(:source => 'puppet:///data/cond.txt', :order => 10 ) }
  end

  context 'content and order' do
    let(:params) { { :content => '/etc/myapp', :order => 20 } }
    it { should contain_concat__fragment('restorecond_conf_cond').with(:content => '/etc/myapp', :order => 20 ) }
  end

end

