require 'spec_helper'

describe 'yum::gpgkey' do
  context 'with no parameters' do
    let(:title) { '/test-key' }

    it { is_expected.to raise_error(Puppet::PreformattedError, %r{Missing params: \$content or \$source must be specified}) }
  end

  context 'with content provided' do
    let(:title) { '/test-key' }
    let(:params) { { content: 'a_non_empty_string' } }

    context 'with ensure = present' do
      let(:params) do
        super().merge(ensure: 'present')
      end

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_exec("rpm-import-#{title}").with(
          'path'    => '/bin:/usr/bin:/sbin/:/usr/sbin',
          'command' => "rpm --import #{title}",
          'unless'  => "rpm -q gpg-pubkey-$(gpg --with-colons #{title} | head -n 1 | cut -d: -f5 | cut -c9-16 | tr '[A-Z]' '[a-z]')",
          'require' => "File[#{title}]"
        )
      }
    end

    context 'with ensure = absent' do
      let(:params) do
        super().merge(ensure: 'absent')
      end

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_exec("rpm-delete-#{title}").with(
          'path'    => '/bin:/usr/bin:/sbin/:/usr/sbin',
          'command' => "rpm -e gpg-pubkey-$(gpg --with-colons #{title} | head -n 1 | cut -d: -f5 | cut -c9-16 | tr '[A-Z]' '[a-z]')",
          'onlyif'  => ["test -f #{title}", "rpm -q gpg-pubkey-$(gpg --with-colons #{title} | head -n 1 | cut -d: -f5 | cut -c9-16 | tr '[A-Z]' '[a-z]')"],
          'before' => "File[#{title}]"
        )
      }
    end
  end

  context 'with a source specified' do
    let(:title) { '/test-key' }
    let(:params) { { source: 'puppet:///files/test-key' } }

    it { is_expected.to compile.with_all_deps }
  end

  context 'when both content and source are specified' do
    let(:title) { '/test-key' }
    let(:params) do
      {
        content: 'a_non_empty_string',
        source: 'puppet:///files/test-key'
      }
    end

    it { is_expected.to raise_error(Puppet::PreformattedError, %r{You cannot specify more than one of content, source}) }
  end
end
