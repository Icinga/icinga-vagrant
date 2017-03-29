require 'json'

shared_examples 'kibana plugin provider' do
  describe 'instances' do
    it 'should have an instance method' do
      expect(described_class).to respond_to :instances
    end

    context 'without plugins' do
      before do
        allow(Dir).to receive(:[]).and_return %w(. ..)
      end

      it 'should return no resources' do
        expect(described_class.instances.size).to eq(0)
      end
    end

    context 'with one plugin' do
      before do
        allow(Dir).to receive(:[]).and_return [File.join(plugin_path, plugin_one[:name])]
        allow(File).to receive(:read)
          .with(File.join(plugin_path, plugin_one[:name], 'package.json'))
          .and_return JSON.dump({:name => plugin_one[:name], :version => plugin_one[:version]})
        allow(File).to receive(:exist?)
          .with(File.join(plugin_path, plugin_one[:name], 'package.json'))
          .and_return true
      end

      subject { described_class.instances.first }

      it { expect(subject.exists?).to be_truthy }
      it { expect(subject.name).to eq(plugin_one[:name]) }
      it { expect(subject.version).to eq(plugin_one[:version]) }
    end

    context 'with multiple plugins' do
      before do
        allow(Dir).to receive(:[])
          .and_return [plugin_one, plugin_two].map { |p| File.join(plugin_path, p[:name]) }
        [plugin_one, plugin_two].each do |plugin|
          allow(File).to receive(:read)
            .with(File.join(plugin_path, plugin[:name], 'package.json'))
            .and_return JSON.dump({:name => plugin[:name], :verison => plugin[:version]})
          allow(File).to receive(:exist?)
            .with(File.join(plugin_path, plugin[:name], 'package.json'))
            .and_return true
        end
      end

      it 'should return two resources' do
        expect(described_class.instances.length).to eq(2)
      end
    end
  end # of describe instances

  describe 'prefetch' do
    it 'should have a prefetch method' do
      expect(described_class).to respond_to :prefetch
    end
  end

  describe 'flush' do
    before do
      described_class
        .stubs(:command).with(:plugin)
        .returns executable
      @install_name = if resource[:organization].nil?
                        resource[:name]
                      else
                        [resource[:organization], resource[:name], resource[:version]].join('/')
                      end
    end

    it 'installs plugins' do
      provider
        .expects(:execute)
        .with(
          [executable] + install_args + [@install_name],
          :uid => 'kibana', :gid => 'kibana'
        )
      resource[:ensure] = :present
      provider.create
      provider.flush
    end

    it 'removes plugins' do
      provider
        .expects(:execute)
        .with(
          [executable] + remove_args + [resource[:name]],
          :uid => 'kibana', :gid => 'kibana'
        )
      resource[:ensure] = :absent
      provider.destroy
      provider.flush
    end

    it 'updates plugins' do
      provider
        .expects(:execute)
        .with(
          [executable] + install_args + [@install_name],
          :uid => 'kibana', :gid => 'kibana'
        )
      provider
        .expects(:execute)
        .with(
          [executable] + remove_args + [resource[:name]],
          :uid => 'kibana', :gid => 'kibana'
        )
      resource[:ensure] = :present
      provider.version = plugin_one[:version]
      provider.flush
    end
  end
end
