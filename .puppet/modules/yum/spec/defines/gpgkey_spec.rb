require 'spec_helper'

describe 'yum::gpgkey' do
  context 'with no parameters' do
    let(:title) { '/test-key' }

    it { is_expected.to raise_error(Puppet::PreformattedError, %r{Missing params: \$content or \$source must be specified}) }
  end

  context 'with content provided' do
    let(:title) { '/test-key' }
    let(:params) { { content: 'a_non_empty_string' } }

    it { is_expected.to compile.with_all_deps }
  end

  context 'with a source specified' do
    let(:title) { '/test-key' }
    let(:params) { { source: 'puppet:///files/test-key' } }

    it { is_expected.to compile.with_all_deps }
  end

  context 'when both content and source are specified' do
    let(:title) { '/test-key' }
    let(:params) do
      {
        content: 'a_non_empty_string',
        source: 'puppet:///files/test-key'
      }
    end

    it { is_expected.to raise_error(Puppet::PreformattedError, %r{You cannot specify more than one of content, source}) }
  end
end
