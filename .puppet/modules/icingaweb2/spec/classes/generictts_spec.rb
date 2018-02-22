require 'spec_helper'

describe('icingaweb2::module::generictts', :type => :class) do
  let(:pre_condition) { [
      "class { 'icingaweb2': }"
  ] }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context "#{os} with git_revision 'v2.0.0'" do
        let(:params) { { :git_revision => 'v2.0.0', } }

        it { is_expected.to contain_icingaweb2__module('generictts')
          .with_install_method('git')
          .with_git_revision('v2.0.0')
        }
      end

      context "#{os} with a ticketsystem" do
        let(:params) { {
            :git_revision => 'v2.0.0',
            :ticketsystems => {
                'foo' => {
                    'pattern' => 'foobar',
                    'url' => 'barfoo'
                }
            }
        } }

        it { is_expected.to contain_icingaweb2__module__generictts__ticketsystem('foo')
          .with_pattern('foobar')
          .with_url('barfoo')
        }

        it { is_expected.to contain_icingaweb2__inisection('generictts-ticketsystem-foo')
          .with_section_name('foo')
          .with_target('/etc/icingaweb2/modules/generictts/config.ini')
          .with_settings( {'pattern' => 'foobar', 'url' => 'barfoo'} )
        }

        it { is_expected.to contain_icingaweb2__module('generictts')
          .with_install_method('git')
          .with_git_revision('v2.0.0')
        }
      end
    end
  end
end
