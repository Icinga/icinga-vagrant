require 'spec_helper_acceptance'

tmpdir = default.tmpdir('vcsrepo')

describe 'clones a remote repo', unless: only_supports_weak_encryption do
  before(:all) do
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
    shell("mkdir -p #{tmpdir}") # win test
  end

  after(:all) do
    shell("rm -rf #{tmpdir}/vcsrepo")
  end

  context 'with clone with single remote' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/vcsrepo":
          ensure   => present,
          provider => git,
          source   => "https://github.com/puppetlabs/puppetlabs-vcsrepo.git",
      }
    MANIFEST
    it 'clones from default remote' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'git config output should contain the remote' do
      shell("/usr/bin/git config -l -f #{tmpdir}/vcsrepo/.git/config") do |r|
        expect(r.stdout).to match(%r{remote.origin.url=https://github.com/puppetlabs/puppetlabs-vcsrepo.git})
      end
    end

    after(:all) do
      shell("rm -rf #{tmpdir}/vcsrepo")
    end
  end

  context 'with clone with multiple remotes' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/vcsrepo":
          ensure   => present,
          provider => git,
          source   => {"origin" => "https://github.com/puppetlabs/puppetlabs-vcsrepo.git", "test1" => "https://github.com/puppetlabs/puppetlabs-vcsrepo.git"},
      }
    MANIFEST
    it 'clones from default remote and adds 2 remotes to config file' do
      idempotent_apply(default, pp)
    end

    it 'git config output should contain the remotes - origin' do
      shell("/usr/bin/git config -l -f #{tmpdir}/vcsrepo/.git/config") do |r|
        expect(r.stdout).to match(%r{remote.origin.url=https://github.com/puppetlabs/puppetlabs-vcsrepo.git})
      end
    end
    it 'git config output should contain the remotes - test1' do
      shell("/usr/bin/git config -l -f #{tmpdir}/vcsrepo/.git/config") do |r|
        expect(r.stdout).to match(%r{remote.test1.url=https://github.com/puppetlabs/puppetlabs-vcsrepo.git})
      end
    end

    after(:all) do
      shell("rm -rf #{tmpdir}/vcsrepo")
    end
  end
end
