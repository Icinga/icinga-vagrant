require 'spec_helper'

describe('icingaweb2::module::graphite', :type => :class) do
  let(:pre_condition) { [
      "class { 'icingaweb2': }"
  ] }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context "#{os} with git_revision 'v0.9.0'" do
        let(:params) { { :git_revision => 'v0.9.0', :url => 'http://localhost' } }

        it { is_expected.to contain_icingaweb2__module('graphite')
                                .with_install_method('git')
                                .with_git_revision('v0.9.0')
        }

        it { is_expected.to contain_icingaweb2__inisection('module-graphite-graphite')
                                .with_section_name('graphite')
                                .with_target('/etc/icingaweb2/modules/graphite/config.ini')
                                .with_settings( {'url' => 'http://localhost'} )
        }
      end

      context "#{os} with all parameters set" do
        let(:params) { {
            :git_revision                          => 'v0.9.0',
            :url                                   => 'http://localhost',
            :user                                  => 'foo',
            :password                              => 'bar',
            :graphite_writer_host_name_template    => 'foobar',
            :graphite_writer_service_name_template => 'barfoo'
        } }

        it { is_expected.to contain_icingaweb2__module('graphite')
                                .with_install_method('git')
                                .with_git_revision('v0.9.0')
        }

        it { is_expected.to contain_icingaweb2__inisection('module-graphite-graphite')
                                .with_section_name('graphite')
                                .with_target('/etc/icingaweb2/modules/graphite/config.ini')
                                .with_settings( {'url' => 'http://localhost', 'user' => 'foo', 'password' => 'bar'} )
        }

        it { is_expected.to contain_icingaweb2__inisection('module-graphite-icinga')
                                .with_section_name('icinga')
                                .with_target('/etc/icingaweb2/modules/graphite/config.ini')
                                .with_settings( {'graphite_writer_host_name_template' => 'foobar',
                                                 'graphite_writer_service_name_template' => 'barfoo'} )
        }
      end
    end
  end
end