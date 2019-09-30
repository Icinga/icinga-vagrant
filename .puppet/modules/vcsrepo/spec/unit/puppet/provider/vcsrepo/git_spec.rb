require 'spec_helper'

describe Puppet::Type.type(:vcsrepo).provider(:git) do
  def branch_a_list(include_branch = nil?)
    <<BRANCHES
  end
  #{'*  master' unless include_branch.nil?}
  #{'*  ' + include_branch if include_branch}
   remote/origin/master
   remote/origin/foo

BRANCHES
  end
  let(:resource) do
    Puppet::Type.type(:vcsrepo).new(name: 'test',
                                    ensure: :present,
                                    provider: :git,
                                    revision: '2634',
                                    source: 'git@repo',
                                    path: '/tmp/test',
                                    force: false)
  end

  let(:provider) { resource.provider }

  before :each do
    allow(Puppet::Util).to receive(:which).with('git').and_return('/usr/bin/git')
  end

  context 'when with an ensure of present' do
    context 'when with an ensure of present - with a revision that is a remote branch' do
      it "executes 'git clone' and 'git checkout -b'" do
        resource[:revision] = 'only/remote'
        expect(Dir).to receive(:chdir).with('/').once.and_yield
        expect(Dir).to receive(:chdir).with('/tmp/test').at_least(:once).and_yield
        expect(provider).to receive(:git).with('clone', resource.value(:source), resource.value(:path))
        expect(provider).to receive(:update_submodules)
        expect(provider).to receive(:update_remote_url).with('origin', resource.value(:source)).and_return false
        expect(provider).to receive(:git).with('branch', '-a').and_return(branch_a_list(resource.value(:revision)))
        expect(provider).to receive(:git).with('checkout', '--force', resource.value(:revision))
        provider.create
      end
    end

    context "with an ensure of present - with a remote not named 'origin'" do
      it "executes 'git clone --origin not_origin" do
        resource[:remote] = 'not_origin'
        expect(Dir).to receive(:chdir).with('/').once.and_yield
        expect(Dir).to receive(:chdir).with('/tmp/test').at_least(:once).and_yield
        expect(provider).to receive(:git).with('clone', '--origin', 'not_origin', resource.value(:source), resource.value(:path))
        expect(provider).to receive(:update_submodules)
        expect(provider).to receive(:update_remote_url).with('not_origin', resource.value(:source)).and_return false
        expect(provider).to receive(:git).with('branch', '-a').and_return(branch_a_list(resource.value(:revision)))
        expect(provider).to receive(:git).with('checkout', '--force', resource.value(:revision))
        provider.create
      end
    end

    context 'when with an ensure of present - with shallow clone enable' do
      it "executes 'git clone --depth 1'" do
        resource[:revision] = 'only/remote'
        resource[:depth] = 1
        expect(Dir).to receive(:chdir).with('/').once.and_yield
        expect(Dir).to receive(:chdir).with('/tmp/test').at_least(:once).and_yield
        expect(provider).to receive(:git).with('clone', '--depth', '1', '--branch', resource.value(:revision), resource.value(:source), resource.value(:path))
        expect(provider).to receive(:update_submodules)
        expect(provider).to receive(:update_remote_url).with('origin', resource.value(:source)).and_return false
        expect(provider).to receive(:git).with('branch', '-a').and_return(branch_a_list(resource.value(:revision)))
        expect(provider).to receive(:git).with('checkout', '--force', resource.value(:revision))
        provider.create
      end
    end

    context 'when with an ensure of present - with a revision that is not a remote branch' do
      it "executes 'git clone' and 'git reset --hard'" do
        resource[:revision] = 'a-commit-or-tag'
        expect(Dir).to receive(:chdir).with('/').once.and_yield
        expect(Dir).to receive(:chdir).with('/tmp/test').at_least(:once).and_yield
        expect(provider).to receive(:git).with('clone', resource.value(:source), resource.value(:path))
        expect(provider).to receive(:update_submodules)
        expect(provider).to receive(:update_remote_url).with('origin', resource.value(:source)).and_return false
        expect(provider).to receive(:git).with('branch', '-a').and_return(branch_a_list(resource.value(:revision)))
        expect(provider).to receive(:git).with('checkout', '--force', resource.value(:revision))
        provider.create
      end

      it "executes 'git clone' and submodule commands" do
        resource.delete(:revision)
        expect(provider).to receive(:git).with('clone', resource.value(:source), resource.value(:path))
        expect(provider).to receive(:update_submodules)
        expect(provider).to receive(:update_remotes)
        provider.create
      end
    end

    context 'when with an ensure of present - when a source is not given - when the path does not exist' do
      it "executes 'git init'" do
        resource[:ensure] = :present
        resource.delete(:source)
        expect_mkdir
        expect_chdir
        expect_directory?(false)
        expect(provider).to receive(:git).with('init')
        provider.create
      end
    end

    context 'when with an ensure of present - when a source is not given - when the path is not empty and not a repository' do
      it 'raises an exception' do
        expect(provider).to receive(:path_exists?).and_return(true)
        expect(provider).to receive(:path_empty?).and_return(false)
        expect { provider.create }.to raise_error(Puppet::Error)
      end
    end

    context 'when with an ensure of bare - with revision' do
      it 'raises an error' do
        resource[:ensure] = :bare
        expect { provider.create }.to raise_error(RuntimeError, %r{cannot set a revision.+bare}i)
      end
    end
    context 'when with an ensure of bare - without revision' do
      it "justs execute 'git clone --bare'" do
        resource[:ensure] = :bare
        resource.delete(:revision)
        expect(provider).to receive(:git).with('clone', '--bare', resource.value(:source), resource.value(:path))
        expect(provider).to receive(:update_remotes)
        provider.create
      end
    end
    context 'when with an ensure of bare - without a source' do
      it "executes 'git init --bare'" do
        resource[:ensure] = :bare
        resource.delete(:source)
        resource.delete(:revision)
        expect(File).to receive(:directory?).with(File.join(resource.value(:path), '.git'))
        expect_chdir
        expect_mkdir
        expect_directory?(false)
        expect(provider).to receive(:git).with('init', '--bare')
        provider.create
      end
    end

    context 'when with an ensure of mirror - with revision' do
      it 'raises an error' do
        resource[:ensure] = :mirror
        expect { provider.create }.to raise_error(RuntimeError, %r{cannot set a revision.+bare}i)
      end
    end
    context 'when with an ensure of mirror - without revision' do
      it "justs execute 'git clone --mirror'" do
        resource[:ensure] = :mirror
        resource.delete(:revision)
        expect(Dir).to receive(:chdir).with('/').once.and_yield
        expect(provider).to receive(:git).with('clone', '--mirror', resource.value(:source), resource.value(:path))
        expect(provider).to receive(:update_remotes)
        provider.create
      end
    end

    context 'when with an ensure of mirror - without a source' do
      it 'raises an exeption' do
        resource[:ensure] = :mirror
        resource.delete(:source)
        resource.delete(:revision)
        expect { provider.create }.to raise_error(RuntimeError, %r{cannot init repository with mirror.+try bare}i)
      end
    end

    context 'when with an ensure of mirror - with multiple remotes' do
      it "executes 'git clone --mirror' and set all remotes to mirror" do
        resource[:ensure] = :mirror
        resource[:source] = { 'origin' => 'git://git@foo.com/bar.git', 'other' => 'git://git@foo.com/baz.git' }
        resource.delete(:revision)
        expect(Dir).to receive(:chdir).with('/').once.and_yield
        expect(provider).to receive(:git).with('clone', '--mirror', resource.value(:source)['origin'], resource.value(:path))
        expect(provider).to receive(:update_remotes)
        expect_chdir
        expect(provider).to receive(:git).with('config', 'remote.origin.mirror', 'true')
        expect(provider).to receive(:git).with('config', 'remote.other.mirror', 'true')
        provider.create
      end
    end
  end

  context 'when with an ensure of mirror - when the path is a working copy repository' do
    it 'clones overtop it using force' do
      resource[:force] = true
      expect(Dir).to receive(:chdir).with('/').once.and_yield
      expect(Dir).to receive(:chdir).with('/tmp/test').at_least(:once).and_yield
      expect(provider).to receive(:path_exists?).and_return(true)
      expect(provider).to receive(:path_empty?).and_return(false)
      provider.destroy
      expect(provider).to receive(:git).with('clone', resource.value(:source), resource.value(:path))
      expect(provider).to receive(:update_submodules)
      expect(provider).to receive(:update_remote_url).with('origin', resource.value(:source)).and_return false
      expect(provider).to receive(:git).with('branch', '-a').and_return(branch_a_list(resource.value(:revision)))
      expect(provider).to receive(:git).with('checkout', '--force', resource.value(:revision))
      provider.create
    end
  end

  context 'when with an ensure of mirror - when the path is not empty and not a repository' do
    it 'raises an exception' do
      expect(provider).to receive(:path_exists?).and_return(true)
      expect(provider).to receive(:path_empty?).and_return(false)
      expect { provider.create }.to raise_error(Puppet::Error)
    end
  end

  context 'when converting repo type' do
    context 'when with working copy to bare' do
      it 'converts the repo' do
        resource[:ensure] = :bare
        expect(provider).to receive(:working_copy_exists?).and_return(true)
        expect(provider).to receive(:bare_exists?).and_return(false)
        expect(FileUtils).to receive(:mv).and_return(true)
        expect(FileUtils).to receive(:rm_rf).and_return(true)
        expect(FileUtils).to receive(:mv).and_return(true)
        expect_chdir
        expect(provider).to receive(:git).with('config', '--local', '--bool', 'core.bare', 'true')
        provider.instance_eval { convert_working_copy_to_bare }
      end
    end

    context 'when with working copy to mirror' do
      it 'converts the repo' do
        resource[:ensure] = :mirror
        expect(provider).to receive(:working_copy_exists?).and_return(true)
        expect(provider).to receive(:bare_exists?).and_return(false)
        expect(FileUtils).to receive(:mv).and_return(true)
        expect(FileUtils).to receive(:rm_rf).and_return(true)
        expect(FileUtils).to receive(:mv).and_return(true)
        expect_chdir
        expect(provider).to receive(:git).with('config', '--local', '--bool', 'core.bare', 'true')
        expect(provider).to receive(:git).with('config', 'remote.origin.mirror', 'true')
        provider.instance_eval { convert_working_copy_to_bare }
      end
    end

    context 'when with bare copy to working copy' do
      it 'converts the repo' do
        expect(FileUtils).to receive(:mv).and_return(true)
        expect(FileUtils).to receive(:mkdir).and_return(true)
        expect(FileUtils).to receive(:mv).and_return(true)
        expect_chdir
        expect(provider).to receive(:commits?).and_return(true)
        # If you forget to stub these out you lose 3 hours of rspec work.
        expect(provider).to receive(:git)
          .with('config', '--local', '--bool', 'core.bare', 'false').and_return(true)
        expect(provider).to receive(:reset).with('HEAD').and_return(true)
        expect(provider).to receive(:git_with_identity).with('checkout', '--force').and_return(true)
        expect(provider).to receive(:update_owner_and_excludes).and_return(true)
        expect(provider).to receive(:mirror?).and_return(false)
        provider.instance_eval { convert_bare_to_working_copy }
      end
    end

    context 'when with mirror to working copy' do
      it 'converts the repo' do
        expect(FileUtils).to receive(:mv).and_return(true)
        expect(FileUtils).to receive(:mkdir).and_return(true)
        expect(FileUtils).to receive(:mv).and_return(true)
        expect_chdir
        expect(provider).to receive(:commits?).and_return(true)
        expect(provider).to receive(:git)
          .with('config', '--local', '--bool', 'core.bare', 'false').and_return(true)
        expect(provider).to receive(:reset).with('HEAD').and_return(true)
        expect(provider).to receive(:git_with_identity).with('checkout', '--force').and_return(true)
        expect(provider).to receive(:update_owner_and_excludes).and_return(true)
        expect(provider).to receive(:git).with('config', '--unset', 'remote.origin.mirror')
        expect(provider).to receive(:mirror?).and_return(true)
        provider.instance_eval { convert_bare_to_working_copy }
      end
    end
  end

  context 'when destroying' do
    it 'removes the directory' do
      expect_rm_rf
      provider.destroy
    end
  end

  context 'when checking the revision property' do
    before(:each) do
      expect_chdir('/tmp/test')
      resource[:source] = 'http://example.com'
      allow(provider).to receive(:git).with('config', 'remote.origin.url').and_return('')
      allow(provider).to receive(:git).with('fetch', 'origin') # FIXME
      allow(provider).to receive(:git).with('fetch', '--tags', 'origin')
      allow(provider).to receive(:git).with('rev-parse', 'HEAD').and_return('currentsha')
      allow(provider).to receive(:git).with('tag', '-l').and_return('Hello')
    end

    context 'when its a SHA and is not different than the current SHA' do
      it 'and_return the current SHA' do
        resource[:revision] = 'currentsha'
        allow(provider).to receive(:git).with('branch', '-a').and_return(branch_a_list)
        expect(provider).to receive(:git).with('rev-parse', '--revs-only', resource.value(:revision)).never
        expect(provider).to receive(:update_references).never
        expect(provider.revision).to eq(resource.value(:revision))
      end
    end

    context 'when its a SHA and is different than the current SHA' do
      it 'and_return the current SHA' do
        resource[:revision] = 'othersha'
        allow(provider).to receive(:git).with('branch', '-a').and_return(branch_a_list)
        expect(provider).to receive(:git).with('rev-parse', '--revs-only', resource.value(:revision)).and_return('othersha')
        expect(provider).to receive(:update_references)
        expect(provider.revision).to eq('currentsha')
      end
    end

    context 'when its a local branch and is not different than the current SHA' do
      it 'and_return the ref' do
        resource[:revision] = 'localbranch'
        allow(provider).to receive(:git).with('branch', '-a').and_return(branch_a_list('localbranch'))
        expect(provider).to receive(:git).with('rev-parse', resource.value(:revision)).and_return('currentsha')
        expect(provider).to receive(:update_references)
        expect(provider.revision).to eq(resource.value(:revision))
      end
    end

    context 'when its a local branch and is different than the current SHA' do
      it 'and_return the current SHA' do
        resource[:revision] = 'localbranch'
        allow(provider).to receive(:git).with('branch', '-a').and_return(branch_a_list('localbranch'))
        expect(provider).to receive(:git).with('rev-parse', resource.value(:revision)).and_return('othersha')
        expect(provider).to receive(:update_references)
        expect(provider.revision).to eq('currentsha')
      end
    end

    context 'when its a ref to a remote head' do
      it 'and_return the ref' do
        resource[:revision] = 'remotebranch'
        allow(provider).to receive(:git).with('branch', '-a').and_return("  remotes/origin/#{resource.value(:revision)}")
        expect(provider).to receive(:git).with('rev-parse', "origin/#{resource.value(:revision)}").and_return('currentsha')
        expect(provider).to receive(:update_references)
        expect(provider.revision).to eq(resource.value(:revision))
      end
    end

    context 'when its a ref to non existant remote head' do
      it 'fails' do
        resource[:revision] = 'remotebranch'
        allow(provider).to receive(:git).with('branch', '-a').and_return(branch_a_list)
        expect(provider).to receive(:git).with('rev-parse', '--revs-only', resource.value(:revision)).and_return('')
        expect(provider).to receive(:update_references)
        expect { provider.revision }.to raise_error(RuntimeError, %r{not a local or remote ref$})
      end
    end

    context "when there's no source" do
      it 'and_return the revision' do
        resource[:revision] = 'localbranch'
        resource.delete(:source)
        allow(provider).to receive(:git).with('branch', '-a').and_return(branch_a_list('localbranch'))
        expect(provider).to receive(:update_references).never
        expect(provider).to receive(:git).with('status')
        expect(provider).to receive(:git).with('rev-parse', resource.value(:revision)).and_return('currentsha')
        expect(provider.revision).to eq(resource.value(:revision))
      end
    end
  end

  context 'when setting the revision property' do
    before(:each) do
      expect_chdir
    end
    context "when it's an existing local branch" do
      it "uses 'git fetch' and 'git reset'" do
        resource[:revision] = 'feature/foo'
        expect(provider).to receive(:update_submodules)
        expect(provider).to receive(:git).with('branch', '-a').at_least(:once).and_return(branch_a_list(resource.value(:revision)))
        expect(provider).to receive(:git).with('checkout', '--force', resource.value(:revision))
        expect(provider).to receive(:git).with('reset', '--hard', "origin/#{resource.value(:revision)}")
        provider.revision = resource.value(:revision)
      end
    end
    context "when it's a remote branch" do
      it "uses 'git fetch' and 'git reset'" do
        resource[:revision] = 'only/remote'
        expect(provider).to receive(:update_submodules)
        expect(provider).to receive(:git).with('branch', '-a').at_least(:once).and_return(resource.value(:revision))
        expect(provider).to receive(:git).with('checkout', '--force', resource.value(:revision))
        expect(provider).to receive(:git).with('reset', '--hard', "origin/#{resource.value(:revision)}")
        provider.revision = resource.value(:revision)
      end
    end
    context "when it's a commit or tag" do
      it "uses 'git fetch' and 'git reset'" do
        resource[:revision] = 'a-commit-or-tag'
        expect(provider).to receive(:git).with('branch', '-a').once.and_return(fixture(:git_branch_a))
        expect(provider).to receive(:git).with('checkout', '--force', resource.value(:revision))
        expect(provider).to receive(:git).with('branch', '-a').and_return(fixture(:git_branch_a))
        expect(provider).to receive(:git).with('branch', '-a').and_return(fixture(:git_branch_a))
        expect(provider).to receive(:git).with('submodule', 'update', '--init', '--recursive')
        provider.revision = resource.value(:revision)
      end
    end
  end

  context 'when checking the source property' do
    before(:each) do
      expect_chdir('/tmp/test')
      allow(provider).to receive(:git).with('config', 'remote.origin.url').and_return('')
      allow(provider).to receive(:git).with('fetch', 'origin') # FIXME
      allow(provider).to receive(:git).with('fetch', '--tags', 'origin')
      allow(provider).to receive(:git).with('rev-parse', 'HEAD').and_return('currentsha')
      allow(provider).to receive(:git).with('branch', '-a').and_return(branch_a_list(resource.value(:revision)))
      allow(provider).to receive(:git).with('tag', '-l').and_return('Hello')
    end

    context "when there's a single remote 'origin'" do
      it 'and_return the URL for the remote' do
        resource[:source] = 'http://example.com'
        expect(provider).to receive(:git).with('remote').and_return("origin\n")
        expect(provider).to receive(:git).with('config', '--get', 'remote.origin.url').and_return('http://example.com')
        expect(provider.source).to eq(resource.value(:source))
      end
    end

    context "when there's more than one remote" do
      it 'and_return the remotes as a hash' do
        resource[:source] = { 'origin' => 'git://git@foo.com/bar.git', 'other' => 'git://git@foo.com/baz.git' }
        expect(provider).to receive(:git).with('remote').and_return("origin\nother\n")
        expect(provider).to receive(:git).with('config', '--get', 'remote.origin.url').and_return('git://git@foo.com/bar.git')
        expect(provider).to receive(:git).with('config', '--get', 'remote.other.url').and_return('git://git@foo.com/baz.git')
        expect(provider.source).to eq(resource.value(:source))
      end
    end
  end

  context 'when updating remotes' do
    context 'when with string to string' do
      it 'fails' do
        resource[:source] = 'git://git@foo.com/bar.git'
        resource[:force] = false

        expect(provider).to receive(:source).and_return('git://git@foo.com/foo.git')
        expect(provider).to receive(:path_exists?).and_return(true)
        expect(provider).to receive(:path_empty?).and_return(false)
        expect { provider.source = resource.value(:source) }.to raise_error(Puppet::Error)
      end
    end

    context 'when with hash to hash' do
      it 'adds any new remotes, update any existing remotes, remove deleted remotes' do
        expect_chdir
        resource[:source] = { 'origin' => 'git://git@foo.com/bar.git', 'new_remote' => 'git://git@foo.com/baz.git' }
        expect(provider).to receive(:source).and_return(
          'origin' => 'git://git@foo.com/foo.git',
          'old_remote' => 'git://git@foo.com/old.git',
        )
        expect(provider).to receive(:git).once.with('config', '-l').and_return("remote.old_remote.url=git://git@foo.com/old.git\n", "remote.origin.url=git://git@foo.com/foo.git\n")
        expect(provider).to receive(:git).with('remote', 'remove', 'old_remote')
        expect(provider).to receive(:git).with('remote', 'set-url', 'origin', 'git://git@foo.com/bar.git')
        expect(provider).to receive(:git).with('remote', 'add', 'new_remote', 'git://git@foo.com/baz.git')
        expect(provider).to receive(:git).with('remote', 'update')
        provider.source = resource.value(:source)
      end
    end

    context 'when with string to hash' do
      it 'adds any new remotes, update origin remote' do
        expect_chdir
        resource[:source] = { 'origin' => 'git://git@foo.com/bar.git', 'new_remote' => 'git://git@foo.com/baz.git' }
        expect(provider).to receive(:source).and_return('git://git@foo.com/foo.git')
        expect(provider).to receive(:git).at_least(:once).with('config', '-l').and_return("remote.origin.url=git://git@foo.com/foo.git\n")
        expect(provider).to receive(:git).with('remote', 'set-url', 'origin', 'git://git@foo.com/bar.git')
        expect(provider).to receive(:git).with('remote', 'add', 'new_remote', 'git://git@foo.com/baz.git')
        expect(provider).to receive(:git).with('remote', 'update')
        provider.source = resource.value(:source)
      end
    end

    context 'when with hash to string' do
      it 'updates origin remote, remove deleted remotes' do
        expect_chdir
        resource[:source] = 'git://git@foo.com/baz.git'
        expect(provider).to receive(:source).and_return(
          'origin' => 'git://git@foo.com/foo.git',
          'old_remote' => 'git://git@foo.com/old.git',
        )
        expect(provider).to receive(:git).with('remote', 'remove', 'old_remote')
        expect(provider).to receive(:git).with('config', '-l').at_most(:twice).and_return("remote.origin.url=git://git@foo.com/foo.git\n", "remote.other.url=git://git@foo.com/bar.git\n")
        expect(provider).to receive(:git).with('remote', 'set-url', 'origin', 'git://git@foo.com/baz.git')
        expect(provider).to receive(:git).with('remote', 'update')
        provider.source = resource.value(:source)
      end
    end
  end

  # rubocop:enable RSpec/ExampleLength

  context 'when updating references' do
    it "uses 'git fetch --tags'" do
      resource.delete(:source)
      expect_chdir
      expect(provider).to receive(:git).with('fetch', 'origin')
      expect(provider).to receive(:git).with('fetch', '--tags', 'origin')
      provider.update_references
    end
  end

  describe 'latest?' do
    context 'when true' do
      it do
        expect(provider).to receive(:revision).and_return('testrev')
        expect(provider).to receive(:latest_revision).and_return('testrev')
        expect(provider).to be_latest
      end
    end
    context 'when false' do
      it do
        expect(provider).to receive(:revision).and_return('master')
        expect(provider).to receive(:latest_revision).and_return('testrev')
        expect(provider).not_to be_latest
      end
    end
  end

  describe 'trust_server_cert' do
    context 'when true' do
      before :each do
        resource[:trust_server_cert] = true
      end

      it 'raises error with git 1.7.0' do
        allow(provider).to receive(:git).with('--version').and_return '1.7.0'
        expect { provider.create }.to raise_error RuntimeError, %r{Can't set sslVerify to false}
      end
      it 'compiles with git 2.13.0' do
        resource[:revision] = 'only/remote'
        expect(Dir).to receive(:chdir).with('/').once.and_yield
        expect(Dir).to receive(:chdir).with('/tmp/test').at_least(:once).and_yield
        expect(provider).to receive(:git).with('-c', 'http.sslVerify=false', 'clone', resource.value(:source), resource.value(:path))
        expect(provider).to receive(:update_submodules)
        expect(provider).to receive(:update_remote_url).with('origin', resource.value(:source)).and_return false
        expect(provider).to receive(:git).with('-c', 'http.sslVerify=false', 'branch', '-a').and_return(branch_a_list(resource.value(:revision)))
        expect(provider).to receive(:git).with('-c', 'http.sslVerify=false', 'checkout', '--force', resource.value(:revision))

        allow(provider).to receive(:git).with('--version').and_return '2.13.0'
        expect { provider.create }.not_to raise_error
      end
    end
  end
end
