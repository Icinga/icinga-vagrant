require 'spec_helper_acceptance'

tmpdir = default.tmpdir('vcsrepo')

describe 'clones a remote repo' do
  before(:all) do
    my_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    shell("mkdir -p #{tmpdir}") # win test
    scp_to(default, "#{my_root}/acceptance/files/create_git_repo.sh", tmpdir)
    shell("cd #{tmpdir} && ./create_git_repo.sh")
  end

  after(:all) do
    shell("rm -rf #{tmpdir}/testrepo.git")
  end

  context 'with get the current master HEAD' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo":
        ensure => present,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
      }
    MANIFEST
    it 'clones a repo' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/testrepo/.git") do
      it { is_expected.to be_directory }
    end

    describe file("#{tmpdir}/testrepo/.git/HEAD") do
      it { is_expected.to contain 'ref: refs/heads/master' }
    end
  end

  context 'with using a https source on github', unless: only_supports_weak_encryption do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/httpstestrepo":
        ensure => present,
        provider => git,
        source => "https://github.com/puppetlabs/puppetlabs-vcsrepo.git",
      }
    MANIFEST
    it 'clones a repo' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/httpstestrepo/.git") do
      it { is_expected.to be_directory }
    end

    describe file("#{tmpdir}/httpstestrepo/.git/HEAD") do
      it { is_expected.to contain 'ref: refs/heads/master' }
    end
  end

  context 'with using a commit SHA' do
    let(:sha) do
      shell("git --git-dir=#{tmpdir}/testrepo.git rev-list HEAD | tail -1").stdout.chomp
    end

    after(:all) do
      shell("rm -rf #{tmpdir}/testrepo_sha")
    end

    it 'clones a repo' do
      pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_sha":
        ensure => present,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
        revision => "#{sha}",
      }
      MANIFEST
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/testrepo_sha/.git") do
      it { is_expected.to be_directory }
    end

    describe file("#{tmpdir}/testrepo_sha/.git/HEAD") do
      it { is_expected.to contain sha }
    end
  end

  context 'with using a tag' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_tag":
        ensure => present,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
        revision => '0.0.2',
      }
    MANIFEST
    it 'clones a repo' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/testrepo_tag/.git") do
      it { is_expected.to be_directory }
    end

    it 'has the tag as the HEAD' do
      shell("git --git-dir=#{tmpdir}/testrepo_tag/.git name-rev HEAD | grep '0.0.2'")
    end
  end

  context 'with using a branch name' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_branch":
        ensure => present,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
        revision => 'a_branch',
      }
    MANIFEST
    it 'clones a repo' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/testrepo_branch/.git") do
      it { is_expected.to be_directory }
    end

    describe file("#{tmpdir}/testrepo_branch/.git/HEAD") do
      it { is_expected.to contain 'ref: refs/heads/a_branch' }
    end
  end

  context 'with ensure latest with branch specified' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_latest":
        ensure => latest,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
        revision => 'a_branch',
      }
    MANIFEST
    it 'clones a repo' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    it 'verifies the HEAD commit SHA on remote and local match' do
      remote_commit = shell("git ls-remote file://#{tmpdir}/testrepo_latest HEAD | head -1").stdout
      local_commit = shell("git --git-dir=#{tmpdir}/testrepo_latest/.git rev-parse HEAD").stdout.chomp
      expect(remote_commit).to include(local_commit)
    end
  end

  context 'with ensure latest with branch unspecified' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_latest":
        ensure => latest,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
      }
    MANIFEST
    it 'clones a repo' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    it 'verifies the HEAD commit SHA on remote and local match' do
      remote_commit = shell("git ls-remote file://#{tmpdir}/testrepo_latest HEAD | head -1").stdout
      local_commit = shell("git --git-dir=#{tmpdir}/testrepo_latest/.git rev-parse HEAD").stdout.chomp
      expect(remote_commit).to include(local_commit)
    end
  end

  context 'with with shallow clone' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_shallow":
        ensure => present,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
        depth => '1',
      }
    MANIFEST
    it 'does a shallow clone' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/testrepo_shallow/.git/shallow") do
      it { is_expected.to be_file }
    end
  end

  context 'with path is not empty and not a repository' do
    before(:all) do
      shell("mkdir #{tmpdir}/not_a_repo", acceptable_exit_codes: [0, 1])
      shell("touch #{tmpdir}/not_a_repo/file1.txt", acceptable_exit_codes: [0, 1])
    end

    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/not_a_repo":
        ensure => present,
        provider => git
        source => "file://#{tmpdir}/testrepo.git",
      }
    MANIFEST
    it 'raises an exception' do
      apply_manifest(pp, expect_failures: true)
    end
  end

  context 'with with an owner' do
    pp = <<-MANIFEST
    user { 'vagrant':
      ensure => present,
    }
    MANIFEST

    apply_manifest(pp, catch_failures: true)
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_owner":
        ensure => present,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
        owner => 'vagrant',
      }
    MANIFEST
    it 'clones a repo' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/testrepo_owner") do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'vagrant' }
    end
  end

  context 'with with a group' do
    pp = <<-MANIFEST
    group { 'vagrant':
      ensure => present,
    }
    MANIFEST

    apply_manifest(pp, catch_failures: true)

    pp = <<-MANIFEST
      vcsrepo { "/#{tmpdir}/testrepo_group":
        ensure => present,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
        group => 'vagrant',
      }
    MANIFEST
    it 'clones a repo' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/testrepo_group") do
      it { is_expected.to be_directory }
      it { is_expected.to be_grouped_into 'vagrant' }
    end
  end

  context 'with with excludes' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_excludes":
        ensure => present,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
        excludes => ['exclude1.txt', 'exclude2.txt'],
      }
    MANIFEST
    it 'clones a repo' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/testrepo_excludes/.git/info/exclude") do
      subject { super().content }

      it { is_expected.to match %r{exclude1.txt} }
    end

    describe file("#{tmpdir}/testrepo_excludes/.git/info/exclude") do
      subject { super().content }

      it { is_expected.to match %r{exclude2.txt} }
    end
  end

  context 'with with force' do
    before(:all) do
      shell("mkdir -p #{tmpdir}/testrepo_force/folder")
      shell("touch #{tmpdir}/testrepo_force/temp.txt")
    end
    it 'applies the manifest' do
      pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_force":
        ensure => present,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
        force => true,
      }
      MANIFEST

      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/testrepo_force/folder") do
      it { is_expected.not_to be_directory }
    end

    describe file("#{tmpdir}/testrepo_force/temp.txt") do
      it { is_expected.not_to be_file }
    end

    describe file("#{tmpdir}/testrepo_force/.git") do
      it { is_expected.to be_directory }
    end

    context 'with and noop' do
      before(:all) do
        shell("mkdir #{tmpdir}/testrepo_already_exists")
        shell("cd #{tmpdir}/testrepo_already_exists && git init")
        shell("cd #{tmpdir}/testrepo_already_exists && touch a && git add a && git commit -m 'a'")
      end
      after(:all) do
        shell("rm -rf #{tmpdir}/testrepo_already_exists")
      end

      pp = <<-MANIFEST
        vcsrepo { "#{tmpdir}/testrepo_already_exists":
          ensure   => present,
          source   => "file://#{tmpdir}/testrepo.git",
          provider => git,
          force    => true,
          noop     => true,
        }
      MANIFEST
      it 'applies the manifest' do
        apply_manifest(pp, catch_changes: true)
      end
    end
  end

  context 'with as a user' do
    before(:all) do
      shell("chmod 707 #{tmpdir}")
      pp = <<-MANIFEST
      group { 'testuser':
        ensure => present,
      }
      user { 'testuser':
        ensure => present,
        groups => 'testuser',
      }
      MANIFEST

      apply_manifest(pp, catch_failures: true)
    end

    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_user":
        ensure => present,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
        user => 'testuser',
      }
    MANIFEST
    it 'applies the manifest' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/testrepo_user") do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'testuser' }
    end

    describe file("#{tmpdir}/testrepo_user") do
      it { is_expected.to be_directory }
      it { is_expected.to be_grouped_into 'testuser' }
    end

    after(:all) do
      pp = 'user { "testuser": ensure => absent }'
      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'with non-origin remote name' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_remote":
        ensure => present,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
        remote => 'testorigin',
      }
    MANIFEST
    it 'applies the manifest' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    it 'remote name is "testorigin"' do
      shell("git --git-dir=#{tmpdir}/testrepo_remote/.git remote | grep 'testorigin'")
    end
  end

  context 'with as a user with ssh - includes special characters' do
    before(:all) do
      # create user
      pp = <<-MANIFEST
      group { 'testuser-ssh':
        ensure => present,
      }
      user { 'testuser-ssh':
        ensure => present,
        groups => 'testuser-ssh',
        managehome => true,
      }
      MANIFEST
      apply_manifest(pp, catch_failures: true)

      # create ssh keys
      shell('mkdir -p /home/testuser-ssh/.ssh')
      shell('ssh-keygen -q -t rsa -f /home/testuser-ssh/.ssh/id_rsa -N ""')

      # copy public key to authorized_keys
      shell('cat /home/testuser-ssh/.ssh/id_rsa.pub > /home/testuser-ssh/.ssh/authorized_keys')
      shell('echo -e "Host localhost\n\tStrictHostKeyChecking no\n" > /home/testuser-ssh/.ssh/config')
      shell('chown -R testuser-ssh:testuser-ssh /home/testuser-ssh/.ssh')
    end

    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_user_ssh":
        ensure => present,
        provider => git,
        source => "git+ssh://testuser-ssh@localhost#{tmpdir}/testrepo.git",
        user => 'testuser-ssh',
      }
    MANIFEST
    it 'applies the manifest' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    after(:all) do
      pp = <<-MANIFEST
      user { 'testuser-ssh':
        ensure => absent,
        managehome => true,
      }
      MANIFEST
      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'with using an identity file' do
    before(:all) do
      # create user
      pp = <<-MANIFEST
      user { 'testuser-ssh':
        ensure => present,
        managehome => true,
      }
      MANIFEST
      apply_manifest(pp, catch_failures: true)

      # create ssh keys
      shell('mkdir -p /home/testuser-ssh/.ssh')
      shell('ssh-keygen -q -t rsa -f /home/testuser-ssh/.ssh/id_rsa -N ""')

      # copy public key to authorized_keys
      shell('cat /home/testuser-ssh/.ssh/id_rsa.pub > /home/testuser-ssh/.ssh/authorized_keys')
      shell('echo -e "Host localhost\n\tStrictHostKeyChecking no\n" > /home/testuser-ssh/.ssh/config')
      shell('chown -R testuser-ssh:testuser-ssh /home/testuser-ssh/.ssh')
    end

    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_user_ssh_id":
        ensure => present,
        provider => git,
        source => "testuser-ssh@localhost:#{tmpdir}/testrepo.git",
        identity => '/home/testuser-ssh/.ssh/id_rsa',
      }
    MANIFEST
    it 'applies the manifest' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end
  end

  context 'with bare repo' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_bare_repo":
        ensure => bare,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
      }
    MANIFEST
    it 'creates a bare repo' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/testrepo_bare_repo/config") do
      it { is_expected.to contain 'bare = true' }
    end
    describe file("#{tmpdir}/testrepo_bare_repo/.git") do
      it { is_expected.not_to be_directory }
    end
    describe file("#{tmpdir}/testrepo_bare_repo/HEAD") do
      it { is_expected.to contain 'ref: refs/heads/master' }
    end
  end

  context 'with mirror repo' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_mirror_repo":
        ensure => mirror,
        provider => git,
        source => "file://#{tmpdir}/testrepo.git",
      }
    MANIFEST
    it 'creates a mirror repo' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/testrepo_mirror_repo/config") do
      it { is_expected.to contain 'bare = true' }
      it { is_expected.to contain 'mirror = true' }
    end
    describe file("#{tmpdir}/testrepo_mirror_repo/.git") do
      it { is_expected.not_to be_directory }
    end
    describe file("#{tmpdir}/testrepo_mirror_repo/HEAD") do
      it { is_expected.to contain 'ref: refs/heads/master' }
    end
  end
end
