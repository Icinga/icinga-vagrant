require 'spec_helper'

describe 'yum::config' do
  context 'with no parameters' do
    let(:title) { 'assumeyes' }

    it { is_expected.to raise_error(Puppet::PreformattedError, %r{expects a value for parameter 'ensure'}) }
  end

  context 'when ensure is a Boolean' do
    let(:title) { 'assumeyes' }
    let(:params) { { ensure: true } }

    it { is_expected.to compile.with_all_deps }
    it 'contains an Augeas resource with the correct changes' do
      is_expected.to contain_augeas("yum.conf_#{title}").with(
        changes: "set assumeyes '1'"
      )
    end
  end

  context 'ensure is an Integer' do
    let(:title) { 'assumeyes' }
    let(:params) { { ensure: 0 } }

    it { is_expected.to compile.with_all_deps }
    it 'contains an Augeas resource with the correct changes' do
      is_expected.to contain_augeas("yum.conf_#{title}").with(
        changes: "set assumeyes '0'"
      )
    end
  end

  context 'ensure is a comma separated String' do
    let(:title) { 'assumeyes' }
    let(:params) { { ensure: '1, 2' } }

    it { is_expected.to compile.with_all_deps }
    it 'contains an Augeas resource with the correct changes' do
      is_expected.to contain_augeas("yum.conf_#{title}").with(
        changes: "set assumeyes '1, 2'"
      )
    end
  end
end
