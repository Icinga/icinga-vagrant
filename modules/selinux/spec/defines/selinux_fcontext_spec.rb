require 'spec_helper'

describe 'selinux::fcontext' do
  let(:title) { 'myfile' }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'invalid pathname' do
        it { expect { is_expected.to compile }.to raise_error(%r{Must pass pathname to | expects a value for parameter 'pathname'}) }
      end

      context 'equal requires destination' do
        let(:params) do
          {
            pathname: '/tmp/file1',
            equals: true
          }
        end
        it { expect { is_expected.to compile }.to raise_error(%r{is not an absolute path}) }
      end

      context 'invalid filemode with filetype false' do
        let(:params) do
          {
            pathname: '/tmp/file1',
            filetype: false,
            filemode: 'X',
            context: 'user_home_dir_t'
          }
        end
        it { expect { is_expected.to compile }.to raise_error(%r{"filemode" must be one of: a,f,d,c,b,s,l,p - see "man semanage-fcontext"}) }
      end
      context 'invalid filetype' do
        let(:params) do
          {
            pathname: '/tmp/file1',
            filetype: true,
            filemode: 'X',
            context: 'user_home_dir_t'
          }
        end
        it { expect { is_expected.to compile }.to raise_error(%r{"filemode" must be one of: a,f,d,c,b,s,l,p - see "man semanage-fcontext"}) }
      end
      context 'invalid multiple filetype' do
        let(:params) do
          {
            pathname: '/tmp/file1',
            filetype: true,
            filemode: 'afdcbslp',
            context: 'user_home_dir_t'
          }
        end
        it { expect { is_expected.to compile }.to raise_error(%r{"filemode" must be one of: a,f,d,c,b,s,l,p - see "man semanage-fcontext"}) }
      end
      context 'equals and filetype' do
        let(:params) do
          {
            pathname: '/tmp/file1',
            equals: true,
            filetype: true,
            filemode: 'a',
            context: 'user_home_dir_t',
            destination: '/tmp/file2'
          }
        end
        it { expect { is_expected.to compile }.to raise_error(%r{cannot contain both "equals" and "filetype" options}) }
      end
      context 'substituting fcontext' do
        let(:params) do
          {
            pathname: '/tmp/file1',
            equals: true,
            destination: '/tmp/file2'
          }
        end
        it { is_expected.to contain_exec('add_/tmp/file2_/tmp/file1').with(command: 'semanage fcontext -a -e /tmp/file2 /tmp/file1') }
        it { is_expected.to contain_exec('restorecond add_/tmp/file2_/tmp/file1').with(command: 'restorecon /tmp/file1') }
      end
      context 'set filemode and context' do
        let(:params) do
          {
            pathname: '/tmp/file1',
            filetype: true,
            filemode: 'a',
            context: 'user_home_dir_t'
          }
        end
        if (facts[:osfamily] == 'RedHat') && (facts[:operatingsystemmajrelease] == '6')
          it { is_expected.to contain_exec('add_user_home_dir_t_/tmp/file1_type_a').with(command: 'semanage fcontext -a -f "all files" -t user_home_dir_t /tmp/file1') }
        else
          it { is_expected.to contain_exec('add_user_home_dir_t_/tmp/file1_type_a').with(command: 'semanage fcontext -a -f a -t user_home_dir_t /tmp/file1') }
        end
        it { is_expected.to contain_exec('restorecond add_user_home_dir_t_/tmp/file1_type_a').with(command: 'restorecon /tmp/file1') }
      end

      context 'set context' do
        let(:params) do
          {
            pathname: '/tmp/file1',
            context: 'user_home_dir_t'
          }
        end
        if (facts[:osfamily] == 'RedHat') && (facts[:operatingsystemmajrelease] == '6')
          it { is_expected.to contain_exec('add_user_home_dir_t_/tmp/file1_type_a').with(command: 'semanage fcontext -a -f "all files" -t user_home_dir_t /tmp/file1') }
        else
          it { is_expected.to contain_exec('add_user_home_dir_t_/tmp/file1_type_a').with(command: 'semanage fcontext -a -f a -t user_home_dir_t /tmp/file1') }
        end
        it { is_expected.to contain_exec('restorecond add_user_home_dir_t_/tmp/file1_type_a').with(command: 'restorecon /tmp/file1') }
      end

      context 'with restorecon disabled' do
        let(:params) do
          {
            pathname: '/tmp/file1',
            context: 'user_home_dir_t',
            restorecond: false
          }
        end
        it { is_expected.not_to contain_exec('restorecond add_user_home_dir_t_/tmp/file1_type_a').with(command: %r{restorecon}) }
      end
      context 'with restorecon specific path' do
        let(:params) do
          {
            pathname: '/tmp/file1',
            context: 'user_home_dir_t',
            restorecond_path: '/tmp/file1/different'
          }
        end
        if (facts[:osfamily] == 'RedHat') && (facts[:operatingsystemmajrelease] == '6')
          it { is_expected.to contain_exec('add_user_home_dir_t_/tmp/file1_type_a').with(command: 'semanage fcontext -a -f "all files" -t user_home_dir_t /tmp/file1') }
        else
          it { is_expected.to contain_exec('add_user_home_dir_t_/tmp/file1_type_a').with(command: 'semanage fcontext -a -f a -t user_home_dir_t /tmp/file1') }
        end
        it { is_expected.to contain_exec('restorecond add_user_home_dir_t_/tmp/file1_type_a').with(command: 'restorecon /tmp/file1/different') }
      end
      context 'with restorecon recurse specific path' do
        let(:params) do
          {
            pathname: '/tmp/file1',
            context: 'user_home_dir_t',
            restorecond_path: '/tmp/file1/different',
            restorecond_recurse: true
          }
        end
        if (facts[:osfamily] == 'RedHat') && (facts[:operatingsystemmajrelease] == '6')
          it { is_expected.to contain_exec('add_user_home_dir_t_/tmp/file1_type_a').with(command: 'semanage fcontext -a -f "all files" -t user_home_dir_t /tmp/file1') }
          it { is_expected.to contain_exec('add_user_home_dir_t_/tmp/file1_type_a').with(unless: "semanage fcontext -E | grep -Fx \"fcontext -a -f 'all files' -t user_home_dir_t '/tmp/file1'\"") }
        else
          it { is_expected.to contain_exec('add_user_home_dir_t_/tmp/file1_type_a').with(command: 'semanage fcontext -a -f a -t user_home_dir_t /tmp/file1') }
          it { is_expected.to contain_exec('add_user_home_dir_t_/tmp/file1_type_a').with(unless: "semanage fcontext -E | grep -Fx \"fcontext -a -f a -t user_home_dir_t '/tmp/file1'\"") }
        end
        it { is_expected.to contain_exec('restorecond add_user_home_dir_t_/tmp/file1_type_a').with(command: 'restorecon -R /tmp/file1/different') }
      end
      context 'with restorecon path with quotation' do
        let(:params) do
          {
            pathname: '/tmp/"$HOME"/"$PATH"/[^ \'\\\#\`]+(?:.*)',
            context: 'user_home_dir_t'
          }
        end
        if (facts[:osfamily] == 'RedHat') && (facts[:operatingsystemmajrelease] == '6')
          it { is_expected.to contain_exec('add_user_home_dir_t_/tmp/"$HOME"/"$PATH"/[^ \'\\\#\`]+(?:.*)_type_a').with(command: 'semanage fcontext -a -f "all files" -t user_home_dir_t "/tmp/\\"\\$HOME\\"/\\"\\$PATH\\"/[^ \'\\\\\\\\#\\\\\`]+(?:.*)"') }
        else
          it { is_expected.to contain_exec('add_user_home_dir_t_/tmp/"$HOME"/"$PATH"/[^ \'\\\#\`]+(?:.*)_type_a').with(command: 'semanage fcontext -a -f a -t user_home_dir_t "/tmp/\\"\\$HOME\\"/\\"\\$PATH\\"/[^ \'\\\\\\\\#\\\\\`]+(?:.*)"') }
        end
        it { is_expected.to contain_exec('restorecond add_user_home_dir_t_/tmp/"$HOME"/"$PATH"/[^ \'\\\#\`]+(?:.*)_type_a').with(command: 'restorecon "/tmp/\\"\\$HOME\\"/\\"\\$PATH\\"/[^ \'\\\\\\\\#\\\\\`]+(?:.*)"') }
      end
    end
  end
end
