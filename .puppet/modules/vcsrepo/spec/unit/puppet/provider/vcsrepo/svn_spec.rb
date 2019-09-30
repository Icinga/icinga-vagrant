require 'spec_helper'

describe Puppet::Type.type(:vcsrepo).provider(:svn) do
  let(:resource) do
    Puppet::Type.type(:vcsrepo).new(name: 'test',
                                    ensure: :present,
                                    provider: :svn,
                                    path: '/tmp/vcsrepo')
  end

  let(:provider) { resource.provider }

  let(:test_paths) { ['path1/file1', 'path2/nested/deep/file2'] }
  let(:test_paths_parents) { ['path1', 'path2', 'path2/nested', 'path2/nested/deep'] }

  before :each do
    allow(Puppet::Util).to receive(:which).with('svn').and_return('/usr/bin/svn')
  end

  describe 'creation/checkout' do
    context 'with source and revision' do
      it "executes 'svn checkout' with a revision" do
        resource[:source] = 'exists'
        resource[:revision] = '1'
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'checkout', '-r', resource.value(:revision),
                                                       resource.value(:source), resource.value(:path))
        provider.create
      end
    end
    context 'with source' do
      it "justs execute 'svn checkout' without a revision" do
        resource[:source] = 'exists'
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'checkout',
                                                       resource.value(:source),
                                                       resource.value(:path))
        provider.create
      end
    end

    context 'with fstype' do
      it "executes 'svnadmin create' with an '--fs-type' option" do
        resource[:fstype] = 'ext4'
        expect(provider).to receive(:svnadmin).with('create', '--fs-type',
                                                    resource.value(:fstype),
                                                    resource.value(:path))
        provider.create
      end
    end
    context 'without fstype' do
      it "executes 'svnadmin create' without an '--fs-type' option" do
        expect(provider).to receive(:svnadmin).with('create', resource.value(:path))
        provider.create
      end
    end

    context 'with depth' do
      it "executes 'svn checkout' with a depth" do
        resource[:source] = 'exists'
        resource[:depth] = 'infinity'
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'checkout', '--depth', 'infinity',
                                                       resource.value(:source), resource.value(:path))
        provider.create
      end
    end

    context 'with trust_server_cert' do
      it "executes 'svn checkout' without a trust-server-cert" do
        resource[:source] = 'exists'
        resource[:trust_server_cert] = false
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'checkout',
                                                       resource.value(:source), resource.value(:path))
        provider.create
      end
      it "executes 'svn checkout' with a trust-server-cert" do
        resource[:source] = 'exists'
        resource[:trust_server_cert] = true
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', '--trust-server-cert', 'checkout',
                                                       resource.value(:source), resource.value(:path))
        provider.create
      end
    end

    context 'with specific include paths' do
      it 'raises an error when trying to make a repo' do
        resource[:includes] = test_paths
        expect { provider.create }.to raise_error(Puppet::Error, %r{Specifying include paths on a nonexistent repo.})
      end

      it 'performs a sparse checkout' do
        resource[:source] = 'exists'
        resource[:includes] = test_paths
        expect(Dir).to receive(:chdir).with('/tmp/vcsrepo').once.and_yield
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'checkout', '--depth', 'empty',
                                                       resource.value(:source),
                                                       resource.value(:path))
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'update', '--depth', 'empty',
                                                       *test_paths_parents)
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'update',
                                                       *resource[:includes])
        provider.create
      end
      it 'performs a sparse checkout at a specific revision' do
        resource[:source] = 'exists'
        resource[:revision] = 1
        resource[:includes] = test_paths
        expect(Dir).to receive(:chdir).with('/tmp/vcsrepo').once.and_yield
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'checkout', '-r',
                                                       resource.value(:revision),
                                                       '--depth', 'empty',
                                                       resource.value(:source),
                                                       resource.value(:path))
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'update',
                                                       '--depth', 'empty',
                                                       '-r', resource.value(:revision),
                                                       *test_paths_parents)
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'update', '-r',
                                                       resource.value(:revision),
                                                       *resource[:includes])
        provider.create
      end
      it 'performs a sparse checkout with a specific depth' do
        resource[:source] = 'exists'
        resource[:depth] = 'files'
        resource[:includes] = test_paths
        expect(Dir).to receive(:chdir).with('/tmp/vcsrepo').once.and_yield
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'checkout', '--depth', 'empty',
                                                       resource.value(:source),
                                                       resource.value(:path))
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'update',
                                                       '--depth', 'empty',
                                                       *test_paths_parents)
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'update',
                                                       '--depth', resource.value(:depth),
                                                       *resource[:includes])
        provider.create
      end
      it 'performs a sparse checkout at a specific depth and revision' do
        resource[:source] = 'exists'
        resource[:revision] = 1
        resource[:depth] = 'files'
        resource[:includes] = test_paths
        expect(Dir).to receive(:chdir).with('/tmp/vcsrepo').once.and_yield
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'checkout', '-r',
                                                       resource.value(:revision),
                                                       '--depth', 'empty',
                                                       resource.value(:source),
                                                       resource.value(:path))
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'update',
                                                       '--depth', 'empty',
                                                       '-r', resource.value(:revision),
                                                       *test_paths_parents)
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'update',
                                                       '-r', resource.value(:revision),
                                                       '--depth', resource.value(:depth),
                                                       *resource[:includes])
        provider.create
      end
    end
  end

  describe 'destroying' do
    it 'removes the directory' do
      expect_rm_rf
      provider.destroy
    end
  end

  describe 'checking existence' do
    it "runs `svn info` on the path when there's a source" do
      resource[:source] = 'dummy'
      expect_directory?(true, resource.value(:path))
      expect(provider).to receive(:svn_wrapper).with('info', resource[:path])
      provider.exists?
    end
    it "runs `svnlook uuid` on the path when there's no source" do
      expect_directory?(true, resource.value(:path))
      expect(provider).to receive(:svnlook).with('uuid', resource[:path])
      provider.exists?
    end
  end

  describe 'checking the revision property' do
    before(:each) do
      allow(provider).to receive(:svn_wrapper).with('--non-interactive', 'info').and_return(fixture(:svn_info))
    end
    it "uses 'svn info'" do
      expect_chdir
      expect(provider.revision).to eq('4') # From 'Revision', not 'Last Changed Rev'
    end
  end

  describe 'setting the revision property' do
    let(:revision) { '30' }

    context 'with conflict' do
      it "uses 'svn update'" do
        resource[:conflict] = 'theirs-full'
        expect_chdir
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'update',
                                                       '-r', revision, '--accept', resource.value(:conflict))
        provider.revision = revision
      end
    end
    context 'without conflict' do
      it "uses 'svn update'" do
        expect_chdir
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'update', '-r', revision)
        provider.revision = revision
      end
    end
  end

  describe 'setting the revision property and repo source' do
    let(:revision) { '30' }

    context 'with conflict' do
      it "uses 'svn switch'" do
        resource[:source] = 'an-unimportant-value'
        resource[:conflict] = 'theirs-full'
        expect_chdir
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'switch', '-r', revision, 'an-unimportant-value', '--accept', resource.value(:conflict))
        provider.revision = revision
      end
    end
    context 'without conflict' do
      it "uses 'svn switch' - variation one" do
        resource[:source] = 'an-unimportant-value'
        expect_chdir
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'switch', '-r', revision, 'an-unimportant-value')
        provider.revision = revision
      end
      it "uses 'svn switch' - variation two" do
        resource[:source] = 'an-unimportant-value'
        resource[:revision] = '30'
        expect_chdir
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'switch', '-r', resource.value(:revision), 'an-unimportant-value')
        provider.source = resource.value(:source)
      end
    end
  end

  describe 'checking the source property' do
    before(:each) do
      allow(provider).to receive(:svn_wrapper).with('--non-interactive', 'info').and_return(fixture(:svn_info))
    end
    it "uses 'svn info'" do
      expect_chdir
      expect(provider.source).to eq('http://example.com/svn/trunk') # From URL
    end
  end

  describe 'checking the basic_auth properties' do
    context 'when basic_auth_username is set and basic_auth_password is not set' do
      it 'fails' do
        resource[:source] = 'an-unimportant-value'
        resource[:basic_auth_username] = 'dummy_user'
        expect { provider.create }.to raise_error RuntimeError, %r{you must specify the HTTP basic authentication password.+}i
      end
    end
    context 'when basic_auth_username is not set and basic_auth_password is set' do
      it 'fails' do
        resource[:source] = 'an-unimportant-value'
        resource[:basic_auth_password] = 'dummy_pass'
        expect { provider.create }.to raise_error RuntimeError, %r{you must specify the HTTP .+username.*}i
      end
    end
    context 'when basic_auth_password is Sensitive' do
      let(:resource) do
        Puppet::Type.type(:vcsrepo).new(name: 'test',
                                        ensure: :present,
                                        provider: :svn,
                                        path: '/tmp/vcsrepo',
                                        source: 'an-unimportant-value',
                                        sensitive_parameters: [:basic_auth_password],
                                        basic_auth_username: 'dummy_user',
                                        basic_auth_password: Puppet::Pops::Types::PSensitiveType::Sensitive.new('dummy_pass'))
      end

      it 'works' do
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', '--username', resource.value(:basic_auth_username),
                                                       '--password', resource.value(:basic_auth_password).unwrap, '--no-auth-cache',
                                                       'checkout', resource.value(:source), resource.value(:path))
        provider.create
      end
    end
  end

  describe 'setting the source property' do
    context 'with conflict' do
      it "uses 'svn switch'" do
        resource[:source] = 'http://example.com/svn/tags/1.0'
        resource[:conflict] = 'theirs-full'
        expect_chdir
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'switch', '--accept', resource.value(:conflict), resource.value(:source))
        provider.source = resource.value(:source)
      end
    end
    context 'without conflict' do
      it "uses 'svn switch'" do
        resource[:source] = 'http://example.com/svn/tags/1.0'
        expect_chdir
        expect(provider).to receive(:svn_wrapper).with('--non-interactive', 'switch',
                                                       resource.value(:source))
        provider.source = resource.value(:source)
      end
    end
  end
end
