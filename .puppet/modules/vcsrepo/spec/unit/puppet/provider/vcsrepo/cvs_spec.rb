require 'spec_helper'

describe Puppet::Type.type(:vcsrepo).provider(:cvs) do
  let(:resource) do
    Puppet::Type.type(:vcsrepo).new(name: 'test',
                                    ensure: :present,
                                    provider: :cvs,
                                    revision: '2634',
                                    source: ':pserver:anonymous@cvs.sv.gnu.org:/sources/cvs/',
                                    path: '/tmp/test')
  end

  let(:provider) { resource.provider }

  before :each do
    allow(Puppet::Util).to receive(:which).with('cvs').and_return('/usr/bin/cvs')
  end

  describe 'creating' do
    context 'with a source' do
      it "executes 'cvs checkout'" do
        resource[:source] = ':ext:source@example.com:/foo/bar'
        resource[:revision] = 'an-unimportant-value'
        expect_chdir('/tmp')
        expect(Puppet::Util::Execution).to receive(:execute).with([:cvs, '-d', resource.value(:source), 'checkout', '-r',
                                                                   'an-unimportant-value', '-d', 'test', '.'], custom_environment: {}, combine: true, failonfail: true)
        provider.create
      end

      it "executes 'cvs checkout' as user 'muppet'" do
        resource[:source] = ':ext:source@example.com:/foo/bar'
        resource[:revision] = 'an-unimportant-value'
        resource[:user] = 'muppet'
        expect_chdir('/tmp')
        expect(Puppet::Util::Execution).to receive(:execute).with([:cvs, '-d', resource.value(:source), 'checkout', '-r',
                                                                   'an-unimportant-value', '-d', 'test', '.'], uid: 'muppet', custom_environment: {}, combine: true, failonfail: true)
        provider.create
      end

      it "justs execute 'cvs checkout' without a revision" do
        resource[:source] = ':ext:source@example.com:/foo/bar'
        resource.delete(:revision)
        expect(Puppet::Util::Execution).to receive(:execute).with([:cvs, '-d', resource.value(:source), 'checkout', '-d',
                                                                   File.basename(resource.value(:path)), '.'], custom_environment: {}, combine: true, failonfail: true)
        provider.create
      end
    end

    context 'with a compression' do
      it "justs execute 'cvs checkout' without a revision" do
        resource[:source] = ':ext:source@example.com:/foo/bar'
        resource[:compression] = '3'
        resource.delete(:revision)
        expect(Puppet::Util::Execution).to receive(:execute).with([:cvs, '-d', resource.value(:source), '-z', '3', 'checkout', '-d',
                                                                   File.basename(resource.value(:path)), '.'], custom_environment: {}, combine: true, failonfail: true)
        provider.create
      end
    end

    context 'when a source is not given' do
      it "executes 'cvs init'" do
        resource.delete(:source)
        expect(Puppet::Util::Execution).to receive(:execute).with([:cvs, '-d', resource.value(:path), 'init'], custom_environment: {}, combine: true, failonfail: true)
        provider.create
      end
    end
  end

  describe 'destroying' do
    it 'removes the directory' do
      provider.destroy
    end
  end

  describe 'checking existence' do
    context 'with a source value' do
      it "runs 'cvs status'" do
        resource[:source] = ':ext:source@example.com:/foo/bar'
        expect(File).to receive(:directory?).with(File.join(resource.value(:path), 'CVS')).and_return(true)
        expect_chdir
        expect(Puppet::Util::Execution).to receive(:execute).with([:cvs, '-nq', 'status', '-l'], custom_environment: {}, combine: true, failonfail: true)
        provider.exist?
      end
    end

    context 'without a source value' do
      it 'checks for the CVSROOT directory and config file' do
        resource.delete(:source)
        expect(File).to receive(:directory?).with(File.join(resource.value(:path), 'CVSROOT')).and_return(true)
        expect(File).to receive(:exist?).with(File.join(resource.value(:path), 'CVSROOT', 'config,v')).and_return(true)
        provider.exist?
      end
    end
  end

  describe 'checking the revision property' do
    let(:tag_file) { File.join(resource.value(:path), 'CVS', 'Tag') }

    context 'when CVS/Tag exists' do
      let(:tag) { 'TAG' }

      before(:each) do
        allow(File).to receive(:exist?).with(tag_file).and_return(true)
      end
      it 'reads CVS/Tag' do
        expect(File).to receive(:read).with(tag_file).and_return("T#{tag}")
        expect(provider.revision).to eq(tag)
      end
    end

    context 'when CVS/Tag does not exist' do
      before(:each) do
        allow(File).to receive(:exist?).with(tag_file).and_return(false)
      end
      it 'assumes HEAD' do
        expect(provider.revision).to eq('HEAD')
      end
    end
  end

  describe 'when setting the revision property' do
    let(:tag) { 'SOMETAG' }

    it "uses 'cvs update -dr'" do
      expect_chdir
      expect(Puppet::Util::Execution).to receive(:execute).with([:cvs, 'update', '-dr', tag, '.'], custom_environment: {}, combine: true, failonfail: true)
      provider.revision = tag
    end
  end

  describe 'checking the source property' do
    it "reads the contents of file 'CVS/Root'" do
      expect(File).to receive(:read).with(File.join(resource.value(:path), 'CVS', 'Root'))
                                    .and_return(':pserver:anonymous@cvs.sv.gnu.org:/sources/cvs/')
      expect(provider.source).to eq(resource.value(:source))
    end
  end
  describe 'setting the source property' do
    it "calls 'create'" do
      expect(provider).to receive(:create)
      provider.source = resource.value(:source)
    end
  end

  describe 'checking the module property' do
    before(:each) do
      resource[:module] = 'ccvs'
    end
    it "reads the contents of file 'CVS/Repository'" do
      expect(File).to receive(:read).with(File.join(resource.value(:path), 'CVS', 'Repository'))
                                    .and_return('ccvs')
      expect(provider.module).to eq(resource.value(:module))
    end
  end
  describe 'setting the module property' do
    it "calls 'create'" do
      expect(provider).to receive(:create)
      provider.module = resource.value(:module)
    end
  end
end
