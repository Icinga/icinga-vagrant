require 'spec_helper_acceptance'

tmpdir = default.tmpdir('vcsrepo')

describe 'create a repo' do
  context 'with without a source' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_blank_repo":
        ensure => present,
        provider => git,
      }
    MANIFEST
    it 'creates a blank repo' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end

    describe file("#{tmpdir}/testrepo_blank_repo/") do
      it 'has zero files' do
        shell("ls -1 #{tmpdir}/testrepo_blank_repo | wc -l") do |r|
          expect(r.stdout).to match(%r{^0\n$})
        end
      end
    end

    describe file("#{tmpdir}/testrepo_blank_repo/.git") do
      it { is_expected.to be_directory }
    end
  end

  context 'with no source but revision provided' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_blank_with_revision_repo":
        ensure   => present,
        provider => git,
        revision => 'master'
      }
    MANIFEST
    it 'does not fail (MODULES-2125)' do
      # Run it twice and test for idempotency
      idempotent_apply(default, pp)
    end
  end

  context 'with bare repo' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_bare_repo":
        ensure => bare,
        provider => git,
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
  end

  context 'with bare repo with a revision' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_bare_repo_rev":
        ensure => bare,
        provider => git,
        revision => 'master',
      }
    MANIFEST
    it 'does not create a bare repo when a revision is defined' do
      apply_manifest(pp, expect_failures: true)
    end

    describe file("#{tmpdir}/testrepo_bare_repo_rev") do
      it { is_expected.not_to be_directory }
    end
  end

  context 'with mirror repo' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/testrepo_mirror_repo":
        ensure => mirror,
        provider => git,
      }
    MANIFEST
    it 'does not create a mirror repo' do
      apply_manifest(pp, expect_failures: true)
    end

    describe file("#{tmpdir}/testrepo_mirror_repo") do
      it { is_expected.not_to be_directory }
    end
  end
end
