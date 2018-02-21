require 'spec_helper'

describe 'yum::versionlock' do
  let(:facts) { { os: { release: { major: 7 } } } }

  context 'with a simple, well-formed title' do
    let(:title) { '0:bash-4.1.2-9.el6_2.x86_64' }

    context 'and no parameters' do
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_concat__fragment('versionlock_header').with_content("# File managed by puppet\n") }
      it 'contains a well-formed Concat::Fragment' do
        is_expected.to contain_concat__fragment("yum-versionlock-#{title}").with_content("#{title}\n")
      end
    end

    context 'and ensure set to present' do
      let(:params) { { ensure: 'present' } }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_concat__fragment('versionlock_header').with_content("# File managed by puppet\n") }
      it 'contains a well-formed Concat::Fragment' do
        is_expected.to contain_concat__fragment("yum-versionlock-#{title}").with_content("#{title}\n")
      end
    end

    context 'and ensure set to absent' do
      let(:params) { { ensure: 'absent' } }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_concat__fragment('versionlock_header').with_content("# File managed by puppet\n") }
      it 'contains a well-formed Concat::Fragment' do
        is_expected.not_to contain_concat__fragment("yum-versionlock-#{title}")
      end
    end
  end

  context 'with a trailing wildcard title' do
    let(:title) { '0:bash-4.1.2-9.el6_2.*' }

    it { is_expected.to compile.with_all_deps }
    it 'contains a well-formed Concat::Fragment' do
      is_expected.to contain_concat__fragment("yum-versionlock-#{title}").with_content("#{title}\n")
    end
  end

  context 'with a complex wildcard title' do
    let(:title) { '0:bash-4.*-*.el6' }

    it 'contains a well-formed Concat::Fragment' do
      is_expected.to contain_concat__fragment("yum-versionlock-#{title}").with_content("#{title}\n")
    end
  end

  context 'with a release containing dots' do
    let(:title) { '1:java-1.7.0-openjdk-1.7.0.121-2.6.8.0.el7_3.x86_64' }

    it 'contains a well-formed Concat::Fragment' do
      is_expected.to contain_concat__fragment("yum-versionlock-#{title}").with_content("#{title}\n")
    end
  end

  context 'with an invalid title' do
    let(:title) { 'bash-4.1.2' }

    it { is_expected.to raise_error(Puppet::PreformattedError, %r(%\{EPOCH\}:%\{NAME\}-%\{VERSION\}-%\{RELEASE\}\.%\{ARCH\})) }
  end

  context 'with an invalid wildcard pattern' do
    let(:title) { '0:bash-4.1.2*' }

    it { is_expected.to raise_error(Puppet::PreformattedError, %r(%\{EPOCH\}:%\{NAME\}-%\{VERSION\}-%\{RELEASE\}\.%\{ARCH\})) }
  end
end
