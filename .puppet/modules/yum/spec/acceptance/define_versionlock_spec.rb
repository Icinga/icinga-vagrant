require 'spec_helper_acceptance'

describe 'yum::versionlock define' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'must work idempotently with no errors' do
      pp = <<-EOS
      yum::versionlock{ '0:bash-4.1.2-9.el6_2.*':
        ensure => present,
      }
      yum::versionlock{ '0:tcsh-3.1.2-9.el6_2.*':
        ensure => present,
      }
      EOS
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes:  true)
    end
    describe file('/etc/yum/pluginconf.d/versionlock.list') do
      it { is_expected.to be_file }
      it { is_expected.to contain '0:bash-4.1.2-9.el6_2.*' }
      it { is_expected.to contain '0:tcsh-3.1.2-9.el6_2.*' }
    end
  end
  it 'must work if clean is specified' do
    shell('yum repolist', acceptable_exit_codes: [0])
    pp = <<-EOS
    class{yum::plugin::versionlock:
      clean => true,
    }
    yum::versionlock{ '0:bash-3.1.2-9.el6_2.*':
      ensure  => present,
    }
    EOS
    # Run it twice and test for idempotency
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes:  true)
    # Check the cache is really empty.
    # all repos will have 0 packages.
    shell('yum -C repolist -d0 | grep -v "repo id"  | awk "{print $NF}" FS=  | grep -v 0', acceptable_exit_codes: [1])
  end
end
