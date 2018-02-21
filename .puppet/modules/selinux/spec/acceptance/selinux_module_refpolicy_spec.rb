require 'spec_helper_acceptance'

#
# Test if refpolicy builder can build module A and B
# where module B depends on an interface provided by
# module A.
#
describe 'selinux module refpolicy' do
  let(:pp) do
    <<-EOS
      class { 'selinux': }

      file {'/tmp/selinux_test_a.te':
        ensure  => 'file',
        content => @("EOF")
          policy_module(puppet_test_a, 1.0.0)
          gen_tunable(puppet_test_a_bool, false)
          type puppet_test_a_t;
          type puppet_test_a_exec_t;
          init_daemon_domain(puppet_test_a_t, puppet_test_a_exec_t)
          type puppet_test_a_port_t;
          corenet_port(puppet_test_a_port_t)
        | EOF
      } ->
      file {'/tmp/selinux_test_a.if':
        ensure  => 'file',
        content => @(EOF)
          interface(`puppet_test_a_domtrans',`
            gen_require(`
              type puppet_test_a_t, puppet_test_a_exec_t;
            ')

            corecmd_search_bin($1)
            domtrans_pattern($1, puppet_test_a_exec_t, puppet_test_a_t)
          ')
          | EOF
      } ->
      file {'/tmp/selinux_test_b.te':
        ensure  => 'file',
        content => @("EOF")
          policy_module(puppet_test_b, 1.0.0)
          type puppet_test_b_t;
          application_type(puppet_test_b_t)
          puppet_test_a_domtrans(puppet_test_b_t)
          | EOF
      } ->
      selinux::module { 'puppet_test_a':
        source_te   => 'file:///tmp/selinux_test_a.te',
        source_if   => 'file:///tmp/selinux_test_a.if',
        builder     => 'refpolicy',
      } ->
      selinux::module { 'puppet_test_b':
        source_te   => 'file:///tmp/selinux_test_b.te',
        builder     => 'refpolicy',
      }
    EOS
  end

  it_behaves_like 'a idempotent resource'
end
