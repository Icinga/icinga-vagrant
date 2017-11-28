require 'spec_helper'

describe Puppet::Type.type(:selinux_fcontext_equivalence) do
  on_supported_os.each do |_os, _facts|
    context 'Type instance creation' do
      it 'fails with invalid path' do
        expect { described_class.new(path: 'no_good') }.to raise_error Puppet::ResourceError, %r{must specify an absolute path instead of 'no_good'}
      end
      it 'fails with invalid target path' do
        expect { described_class.new(path: '/good', target: 'bad_target') }.to raise_error Puppet::ResourceError, %r{must be an absolute path instead of 'bad_target'}
      end
    end
  end
end
