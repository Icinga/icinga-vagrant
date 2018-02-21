require 'spec_helper'

# Provide a dummy Selinux module for the test
module Selinux
  def selinux_file_context_subs_path
    'spec_dummy'
  end
end

semanage_provider = Puppet::Type.type(:selinux_fcontext_equivalence).provider(:semanage)
fc_equiv = Puppet::Type.type(:selinux_fcontext_equivalence)

fcontext_equivs = <<-EOS
/foobar /var/lib/whatever
/opt/my/other/app /var/lib/whatever
/opt/foo /usr/share/wordpress
EOS

describe semanage_provider do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with three custom equivalences' do
        before do
          Selinux.expects(:selinux_file_context_subs_path).returns('spec_dummy')
          File.expects(:exist?).with('spec_dummy').returns(true)
          File.expects(:readlines).with('spec_dummy').returns(fcontext_equivs.split("\n"))
        end
        it 'returns three resources' do
          expect(described_class.instances.size).to eq(3)
        end
        it 'equivalences get parsed properly' do
          expect(described_class.instances[0].instance_variable_get('@property_hash')).to eq(
            ensure: :present,
            name: '/foobar',
            target: '/var/lib/whatever'
          )
        end
      end
      context 'with no equivalences file' do
        before do
          Selinux.expects(:selinux_file_context_subs_path).returns('spec_dummy')
          File.expects(:exist?).with('spec_dummy').returns(false)
        end
        it 'returns no resources' do
          expect(described_class.instances.size).to eq(0)
        end
      end
      context 'Creating' do
        let(:resource) do
          res = fc_equiv.new(name: '/foobar', ensure: :present, target: '/something')
          res.provider = semanage_provider.new
          res
        end

        it 'runs semanage fcontext -a -e' do
          described_class.expects(:semanage).with('fcontext', '-a', '-e', '/something', '/foobar')
          resource.provider.create
        end
      end
      context 'Deleting' do
        let(:provider) do
          semanage_provider.new(name: '/foobar', ensure: :present, target: '/something')
        end

        it 'runs semanage fcontext -d -e' do
          described_class.expects(:semanage).with('fcontext', '-d', '-e', '/something', '/foobar')
          provider.destroy
        end
      end
      context 'With resources differing from the catalog' do
        let(:resources) do
          return { '/opt/myapp' => fc_equiv.new(
            name: '/opt/myapp',
            target: '/usr/share/wordpress'
          ),
                   '/foobar' => fc_equiv.new(
                     name: '/foobar',
                     target: '/somewhere_else'
                   ) }
        end

        before do
          # prefetch should find the provider parsed from this:
          Selinux.expects(:selinux_file_context_subs_path).returns('spec_dummy')
          File.expects(:exist?).with('spec_dummy').returns(true)
          File.expects(:readlines).with('spec_dummy').returns(fcontext_equivs.split("\n"))
          semanage_provider.prefetch(resources)
        end
        it 'finds provider for /foobar' do
          p = resources['/foobar'].provider
          expect(p).not_to eq(nil)
        end
        context 'has the correct target' do
          let(:p) { resources['/foobar'].provider }

          it { expect(p.target).to eq('/var/lib/whatever') }
        end
        it 'can change target by doing a non-reloading delete' do
          p = resources['/foobar'].provider
          described_class.expects(:semanage).with('fcontext', '-N', '-d', '-e', '/var/lib/whatever', '/foobar')
          described_class.expects(:semanage).with('fcontext', '-a', '-e', '/somewhere_else', '/foobar')
          p.target = '/somewhere_else'
        end
      end
    end
  end
end
