require 'spec_helper_acceptance'

tmpdir = default.tmpdir('vcsrepo')

describe 'remove a repo' do
  pp = <<-MANIFEST
    vcsrepo { "#{tmpdir}/testrepo_deleted":
      ensure => present,
      provider => git,
    }
  MANIFEST
  it 'creates a blank repo' do
    apply_manifest(pp, catch_failures: true)
  end

  pp_noop_remove = <<-MANIFEST
    vcsrepo { "#{tmpdir}/testrepo_deleted":
      ensure   => absent,
      provider => git,
      force    => true,
    }
  MANIFEST
  context 'when ran with noop' do
    it 'does not remove a repo' do
      apply_manifest(pp_noop_remove, catch_failures: true, noop: true, verbose: false)
    end

    describe file("#{tmpdir}/testrepo_deleted") do
      it { is_expected.to be_directory }
    end
  end

  pp_remove = <<-MANIFEST
    vcsrepo { "#{tmpdir}/testrepo_deleted":
      ensure => absent,
      provider => git,
    }
  MANIFEST
  context 'when ran without noop' do
    it 'removes a repo' do
      apply_manifest(pp_remove, catch_failures: true)
    end

    describe file("#{tmpdir}/testrepo_deleted") do
      it { is_expected.not_to be_directory }
    end
  end
end
