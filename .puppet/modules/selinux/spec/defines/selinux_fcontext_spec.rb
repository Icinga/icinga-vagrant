require 'spec_helper'

describe 'selinux::fcontext' do
  let(:title) { 'myfile' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'ordering' do
        let(:params) do
          {
            pathspec: '/tmp/file1',
            seltype: 'user_home_dir_t'
          }
        end

        it { is_expected.to contain_selinux__fcontext('myfile').that_requires('Anchor[selinux::module post]') }
        it { is_expected.to contain_selinux__fcontext('myfile').that_comes_before('Anchor[selinux::end]') }
      end
      context 'removal ordering' do
        let(:params) do
          {
            ensure: 'absent',
            pathspec: '/tmp/file1',
            seltype: 'user_home_dir_t'
          }
        end

        it { is_expected.to contain_selinux__fcontext('myfile').that_requires('Anchor[selinux::start]') }
        it { is_expected.to contain_selinux__fcontext('myfile').with(ensure: 'absent') }
        it { is_expected.to contain_selinux__fcontext('myfile').that_comes_before('Anchor[selinux::module pre]') }
      end

      context 'invalid filetype' do
        let(:params) do
          {
            pathspec: '/tmp/file1',
            filetype: 'X',
            seltype: 'user_home_dir_t'
          }
        end

        it { expect { is_expected.to compile }.to raise_error(%r{"filetype" must be one of: a,f,d,c,b,s,l,p - see "man semanage-fcontext"}) }
      end
      context 'invalid multiple filetype' do
        let(:params) do
          {
            pathspec: '/tmp/file1',
            filetype: 'afdcbslp',
            seltype: 'user_home_dir_t'
          }
        end

        it { expect { is_expected.to compile }.to raise_error(%r{"filetype" must be one of: a,f,d,c,b,s,l,p - see "man semanage-fcontext"}) }
      end
      context 'set filemode and context' do
        let(:params) do
          {
            pathspec: '/tmp/file1',
            filetype: 'a',
            seltype: 'user_home_dir_t'
          }
        end

        it { is_expected.to contain_selinux_fcontext('/tmp/file1_a').with(pathspec: '/tmp/file1', seltype: 'user_home_dir_t', file_type: 'a') }
      end
      context 'set context' do
        let(:params) do
          {
            pathspec: '/tmp/file1',
            seltype: 'user_home_dir_t'
          }
        end

        it { is_expected.to contain_selinux_fcontext('/tmp/file1_a').with(pathspec: '/tmp/file1', seltype: 'user_home_dir_t', file_type: 'a') }
      end
    end
  end
end
