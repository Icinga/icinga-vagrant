require 'spec_helper'

describe Puppet::Type.type(:vcsrepo).provider(:hg) do
  let(:resource) do
    Puppet::Type.type(:vcsrepo).new(name: 'test',
                                    ensure: :present,
                                    provider: :hg,
                                    path: '/tmp/vcsrepo')
  end

  let(:provider) { resource.provider }

  before :each do
    allow(Puppet::Util).to receive(:which).with('hg').and_return('/usr/bin/hg')
  end

  describe 'creating' do
    context 'with source and revision' do
      it "executes 'hg clone -u' with the revision" do
        resource[:source] = 'something'
        resource[:revision] = '1'
        expect(Puppet::Util::Execution).to receive(:execute).with("hg clone -u #{resource.value(:revision)} #{resource.value(:source)} #{resource.value(:path)}", sensitive: false)
        provider.create
      end
    end

    context 'without revision' do
      it "justs execute 'hg clone' without a revision" do
        resource[:source] = 'something'
        expect(Puppet::Util::Execution).to receive(:execute).with("hg clone #{resource.value(:source)} #{resource.value(:path)}", sensitive: false)
        provider.create
      end
    end

    context 'when a source is not given' do
      it "executes 'hg init'" do
        expect(Puppet::Util::Execution).to receive(:execute).with("hg init #{resource.value(:path)}", sensitive: false)
        provider.create
      end
    end

    context 'when basic auth is used' do
      it "executes 'hg clone'" do
        resource[:source] = 'something'
        resource[:basic_auth_username] = 'user'
        resource[:basic_auth_password] = 'pass'

        command = "hg clone #{resource.value(:source)} #{resource.value(:path)} --config auth.x.prefix=#{resource.value(:source)} "\
        "--config auth.x.username=#{resource.value(:basic_auth_username)} --config auth.x.password=#{resource.value(:basic_auth_password)} "\
        "--config 'auth.x.schemes=http https'"\

        expect(Puppet::Util::Execution).to receive(:execute).with(command, sensitive: false)
        provider.create
      end
    end

    context 'when basic auth is used with Sensitive basic_auth_password' do
      let(:resource) do
        Puppet::Type.type(:vcsrepo).new(name: 'test',
                                        ensure: :present,
                                        provider: :hg,
                                        path: '/tmp/vcsrepo',
                                        source: 'something',
                                        sensitive_parameters: [:basic_auth_password],
                                        basic_auth_username: 'user',
                                        basic_auth_password: Puppet::Pops::Types::PSensitiveType::Sensitive.new('pass'))
      end

      it "executes 'hg clone'" do
        command = "hg clone #{resource.value(:source)} #{resource.value(:path)} --config auth.x.prefix=#{resource.value(:source)} "\
        "--config auth.x.username=#{resource.value(:basic_auth_username)} --config auth.x.password=#{resource.value(:basic_auth_password).unwrap} "\
        "--config 'auth.x.schemes=http https'"\

        expect(Puppet::Util::Execution).to receive(:execute).with(command, sensitive: true)
        provider.create
      end
    end
  end

  describe 'destroying' do
    it 'removes the directory' do
      expect_rm_rf
      provider.destroy
    end
  end

  describe 'checking existence' do
    it 'checks for the directory' do
      expect_directory?(true, resource.value(:path))
      expect(Puppet::Util::Execution).to receive(:execute).with("hg status #{resource.value(:path)}", sensitive: false)
      provider.exists?
    end
  end

  describe 'checking the revision property' do
    before(:each) do
      expect_chdir
    end

    context 'when given a non-SHA as the resource revision' do
      before(:each) do
        allow(Puppet::Util::Execution).to receive(:execute).with('hg parents', sensitive: false).and_return(fixture(:hg_parents))
        allow(Puppet::Util::Execution).to receive(:execute).with('hg tags', sensitive: false).and_return(fixture(:hg_tags))
      end

      it 'when its sha is not different from the current SHA it and_return the ref' do
        resource[:revision] = '0.6'
        expect(provider.revision).to eq('0.6')
      end

      it 'when its SHA is different than the current SHA it and_return the current SHA' do
        resource[:revision] = '0.5.3'
        expect(provider.revision).to eq('34e6012c783a')
      end
    end
    context 'when given a SHA as the resource revision' do
      before(:each) do
        allow(Puppet::Util::Execution).to receive(:execute).with('hg parents', sensitive: false).and_return(fixture(:hg_parents))
      end

      it 'when it is the same as the current SHA it and_return it' do
        resource[:revision] = '34e6012c783a'
        expect(Puppet::Util::Execution).to receive(:execute).with('hg tags', sensitive: false).and_return(fixture(:hg_tags))
        expect(provider.revision).to eq(resource.value(:revision))
      end

      it 'when it is not the same as the current SHA it and_return the current SHA' do
        resource[:revision] = 'not-the-same'
        expect(Puppet::Util::Execution).to receive(:execute).with('hg tags', sensitive: false).and_return(fixture(:hg_tags))
        expect(provider.revision).to eq('34e6012c783a')
      end
    end
  end

  describe 'setting the revision property' do
    let(:revision) { '6aa99e9b3ab1' }

    it "uses 'hg update ---clean -r'" do
      expect_chdir
      expect(provider).to receive(:hg_wrapper).with('pull', remote: true)
      expect(provider).to receive(:hg_wrapper).with('merge')
      expect(provider).to receive(:hg_wrapper).with('update', '--clean', '-r', revision)
      provider.revision = revision
    end
  end

  describe 'checking the source property' do
    it 'and_return the default path' do
      resource[:source] = 'http://selenic.com/hg'
      expect_chdir
      expect(provider).to receive(:hg_wrapper).with('paths').and_return('default = http://selenic.com/hg')
      expect(provider.source).to eq(resource.value(:source))
    end
  end

  describe 'setting the source property' do
    it "calls 'create'" do
      resource[:source] = 'some-example'
      expect(provider).to receive(:create)
      provider.source = resource.value(:source)
    end
  end
end
