require 'beaker-pe'
require 'beaker-puppet'
require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper
configure_type_defaults_on(hosts)
install_ca_certs unless ENV['PUPPET_INSTALL_TYPE'] =~ %r{pe}i
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # ensure test dependencies are available on all hosts
    hosts.each do |host|
      case fact_on(host, 'osfamily')
      when 'RedHat'
        if fact_on(host, 'operatingsystemmajrelease') == '5'
          will_install_git = on(host, 'which git', acceptable_exit_codes: [0, 1]).exit_code == 1

          if will_install_git
            on(host, 'rpm -ivh http://repository.it4i.cz/mirrors/repoforge/redhat/el5/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm', acceptable_exit_codes: [0])
            on(host, 'yum install -y git', acceptable_exit_codes: [0])
          end

        end

        install_package(host, 'git')
        install_package(host, 'subversion')

      when 'Debian'
        install_package(host, 'git-core')
        install_package(host, 'subversion')

      else
        unless check_for_package(host, 'git')
          puts 'Git package is required for this module'
          exit
        end
        unless check_for_package(host, 'subversion')
          puts 'Subversion package is required for this module'
          exit
        end
      end
      on host, 'git config --global user.email "root@localhost"'
      on host, 'git config --global user.name "root"'
    end
  end
end

def idempotent_apply(hosts, manifest, opts = {}, &block)
  block_on hosts, opts do |host|
    file_path = host.tmpfile('apply_manifest.pp')
    create_remote_file(host, file_path, manifest + "\n")

    puppet_apply_opts = { :verbose => nil, 'detailed-exitcodes' => nil }
    on_options = { acceptable_exit_codes: [0, 2] }
    on host, puppet('apply', file_path, puppet_apply_opts), on_options, &block
    puppet_apply_opts2 = { :verbose => nil, 'detailed-exitcodes' => nil }
    on_options2 = { acceptable_exit_codes: [0] }
    on host, puppet('apply', file_path, puppet_apply_opts2), on_options2, &block
  end
end

# git with 3.18 changes the maximum enabled TLS protocol version, older OSes will fail these tests
def only_supports_weak_encryption
  return_val = (os[:family] == 'redhat' && os[:release].start_with?('5') ||
               (host_inventory['facter']['os']['name'] == 'OracleLinux' && os[:release].start_with?('6')))
  return_val
end
