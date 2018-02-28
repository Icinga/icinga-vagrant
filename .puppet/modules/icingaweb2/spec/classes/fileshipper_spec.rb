require 'spec_helper'

describe('icingaweb2::module::fileshipper', :type => :class) do
  let(:pre_condition) { [
      "class { 'icingaweb2': }"
  ] }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context "#{os} with git_revision 'v1.0.0'" do
        let(:params) { { :git_revision => 'v1.0.0', } }

        it { is_expected.to contain_icingaweb2__module('fileshipper')
                                .with_install_method('git')
                                .with_git_revision('v1.0.0')
        }
      end

      context "#{os} with a base directory" do
        let(:params) { {
            :git_revision => 'v1.0.0',
            :base_directories => {
                'temp' => '/tmp'
            }
        } }

        it { is_expected.to contain_icingaweb2__module('fileshipper')
                                .with_install_method('git')
                                .with_git_revision('v1.0.0')
        }

        it { is_expected.to contain_icingaweb2__module__fileshipper__basedir('temp')
                                .with_basedir('/tmp')
        }

        it { is_expected.to contain_icingaweb2__inisection('fileshipper-basedir-temp')
                                .with_section_name('temp')
                                .with_target('/etc/icingaweb2/modules/fileshipper/imports.ini')
                                .with_settings( {'basedir' => '/tmp'} )
        }
      end

      context "#{os} with a directory" do
        let(:params) { {
            :git_revision => 'v1.0.0',
            :directories => {
                'test' => {
                    'source'     => '/tmp/source',
                    'target'     => '/tmp/target',
                    'extensions' => '.foobar'
                }
            }
        } }

        it { is_expected.to contain_icingaweb2__module('fileshipper')
                                .with_install_method('git')
                                .with_git_revision('v1.0.0')
        }

        it { is_expected.to contain_icingaweb2__module__fileshipper__directory('test')
                                .with_source('/tmp/source')
                                .with_target('/tmp/target')
                                .with_extensions('.foobar')
        }

        it { is_expected.to contain_icingaweb2__inisection('fileshipper-directory-test')
                                .with_section_name('test')
                                .with_target('/etc/icingaweb2/modules/fileshipper/directories.ini')
                                .with_settings( {'source' => '/tmp/source', 'target' => '/tmp/target', 'extensions' => '.foobar'} )
        }
      end
    end
  end
end